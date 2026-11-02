# Backend: the Eventix scanner API

The app needs these endpoints on the existing Eventix server. They are part of
the Eventix code base (private repository `eventix`, branch `scanner-api`,
commit `ee2d7b8`). They went live on `https://eventix.om` on 2026-11-01. The
source is copied in [../backend/](../backend/), at the same paths.

| File (Eventix repo) | Purpose |
|---|---|
| `app/api/scanner/login.php` | Sign in with an Eventix account → bearer token |
| `app/api/scanner/logout.php` | Revoke the token |
| `app/api/scanner/events.php` | Events this user may scan for |
| `app/api/scanner/guests.php` | One event's guest list |
| `app/api/scanner/checkins.php` | Upload check-ins (idempotent) |
| `app/includes/scanner_api.php` | Shared code: token checks, JSON answers, the check-in transaction |
| `app/db_migrations/030_scanner_api.sql` | Tables `api_tokens`, `scanner_checkins` (`.down.sql` to undo) |
| `evals/scanner_api_test.sh` + `evals/harness/scanner_api.php` | 71 end-to-end checks over real HTTP |

## What was checked on the real system before building

These were verified against the live server and code, not assumed:

| Question | Finding | Consequence |
|---|---|---|
| How does Eventix sign people in? | A PHP session cookie (`PHPSESSID`, Secure, HttpOnly, SameSite=Lax) set by a form POST to `/login`, which answers with a 302 redirect. No JSON login and no API auth existed. | A new JSON sign-in was needed. |
| How long does a session last? | `session.gc_maxlifetime = 1440`: sessions die after **24 idle minutes**, and a cleanup job deletes them every 30 minutes. | A door phone quiet for half an hour would be signed out mid-event, so the app uses a 14-day bearer token instead. It is checked against the same accounts. |
| Can new API responses be cached? | nginx caches PHP answers for 1 s, keyed on `scheme+method+host+URI` only. It skips the cache only for POST, a `PHPSESSID` cookie or certain paths, and `/api/` isn't one of them. Confirmed live: `/api/pricing.php` returned MISS, then HIT. | A token-authenticated GET could reach another user, so every API answer sends `X-Accel-Expires: 0`. |
| Who checked a guest in? | `guests` has only `checkin_status` and `checkin_time`. The web endpoints read, then write, without a lock (two scanners can both get "OK"). | The API locks the guest row. "Who" isn't shown (owner's decision). It goes to `audit_logs`. |
| What is in the QR? | `https://eventix.om/qr/scan.php?t=<64-hex token>`. The token is also the guest's RSVP link. | Only SHA-256 hashes of tokens go to phones. |
| What time zone are times in? | Stored in Muscat time. Events can be elsewhere (the London event). | ISO 8601 times with an offset, plus labels in the event's zone. |
| Temporary passwords? | Migration 029: `must_change_password`. | The app refuses them and points to the website. |

## Authentication

```
POST /api/scanner/login.php
{"username": "door1", "password": "…", "device_name": "Android 14"}

200 {"token": "<64 hex>", "token_type": "Bearer", "expires_at": "2026-11-15T06:14:00+04:00",
     "user": {"id": 21, "username": "door1", "role": "scanner"}}
400 invalid_request · 401 invalid_credentials · 403 role_not_allowed · 403 password_change_required
429 too_many_attempts   (10 failures per username + IP in 30 minutes)
```

Every other call sends `Authorization: Bearer <token>`. A token stops working
when it expires (14 days), on sign-out, when the user changes their password,
when an admin sets a temporary password, or when the user is no longer a
scanner or admin. These requests start no PHP session and set no cookie.

## Guest list

```
GET /api/scanner/guests.php?event_id=7
200 {"event": {"id": 7, "title_en": "…", "title_ar": "…", "starts_at": "2026-11-20T19:00:00+04:00",
               "starts_label": "Fri 20 Nov 2026, 7:00 pm", "timezone": "Asia/Muscat",
               "guest_count": 40, "checked_in_count": 1, …},
     "generated_at": "…",
     "guests": [{"id": 1201, "name_en": "Aisha Test-Alpha", "name_ar": "عائشة تجربة أ",
                 "rsvp": "Attending", "table_number": "1",
                 "token_sha256": "9f2c…", "checked_in": false,
                 "checked_in_at": null, "checked_in_label": null}, …]}
403 forbidden · 404 event_not_found
```

Demo guests are left out. No phone numbers or emails are included.

## Check-ins

```
POST /api/scanner/checkins.php
{"checkins": [{"client_id": "1b4e28ba-2fa1-4d3b-a3f5-ef19b5a7633b", "guest_id": 1201,
               "scanned_at": "2026-11-20T15:03:10Z"}]}          (1–100 per request)

200 {"results": [{"client_id": "1b4e…", "guest_id": 1201, "status": "checked_in",
                  "checked_in_at": "2026-11-20T19:03:12+04:00", "checked_in_label": "7:03 pm"}]}
```

| status | meaning |
|---|---|
| `checked_in` | This upload checked the guest in. |
| `already_checked_in` | Someone reached the server first. `checked_in_at` is their time. |
| `not_found` | The guest was removed, or is a demo guest. |
| `forbidden` | The guest's event isn't assigned to this user. |
| `invalid` | Malformed item, or a `client_id` already used for another guest or user. |

`"replayed": true` means this `client_id` was answered before. The result is
the first answer, and nothing was changed.

## Rate limits

Reads: 60 a minute per user. Uploads: 120 requests a minute per user. Each
answer is JSON with status 429 and `Retry-After: 60`. Limits are per user, not
per IP, because the door team shares one Wi-Fi.

## Deploying and rolling back

Deployed 2026-11-01:
1. Backup of the replaced files: `~/eventix_backups/pre-scanner-api-<timestamp>.tgz` on the server.
2. Migration 030 (adds two tables; nothing existing changes).
3. The 12 files, each copied to `.new` and moved into place.

Production was checked to match commit `ee2d7b8` file by file. Before that, the
code already running in production was committed as a baseline (`777f8f5`,
`8b07694`).

To roll back: restore the backup archive, delete `app/api/scanner/` and
`app/includes/scanner_api.php`, then run `030_scanner_api.down.sql`.
Check-ins already made stay on the guests.
