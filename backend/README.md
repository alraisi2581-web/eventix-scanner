# Backend: the Eventix scanner API (source)

This is the server code the app talks to: the scanner API added to the existing
Eventix server (PHP 8.3, MySQL 8, nginx). Eventix's own code base is private.
This folder copies the files written for this project, with their paths as they
are inside Eventix.

- **Copied from:** the Eventix repository, branch `scanner-api`, commit
  `42bb323` (API at `ee2d7b8`).
- **Live:** on `https://eventix.om` since 2026-11-01.
- **Contract and design reasons:** the request/response contract, what was
  checked on the real server first, and how it was deployed and can be rolled
  back are in [../docs/backend-api.md](../docs/backend-api.md).

## Files

| Path (as in Eventix) | What it does |
|---|---|
| `app/api/scanner/login.php` | Signs in with an Eventix username + password, returns a 14-day bearer token |
| `app/api/scanner/logout.php` | Revokes the token |
| `app/api/scanner/events.php` | The events this account may check guests in for |
| `app/api/scanner/guests.php` | One event's guest list: names, RSVP and table; QR tokens only as SHA-256; no phones or emails |
| `app/api/scanner/checkins.php` | Uploads 1–100 check-ins; the first to reach the server wins; a repeated `client_id` gets its first answer back and changes nothing |
| `app/includes/scanner_api.php` | Shared code: token checks, JSON answers, no caching (`X-Accel-Expires: 0`), and the check-in transaction (`SELECT … FOR UPDATE`) |
| `app/includes/rate_limit.php` | Eventix's rate limiter, with `rate_limit_exceeded()` split out so the API can answer 429 in JSON |
| `app/db_migrations/030_scanner_api.sql` (+ `.down.sql`) | Tables `api_tokens` (token hashes) and `scanner_checkins` (one row per uploaded check-in) |
| `patches/eventix-core.diff` | The only change to Eventix's core files: `EVX_STATELESS`, so API requests start no PHP session and set no cookie |
| `evals/harness/scanner_api.php` | 71 end-to-end checks over real HTTP |
| `evals/scanner_api_test.sh` | Runs them on a sandbox server (never production), then removes everything it made |

## What it relies on in Eventix (not included here)

The API reuses Eventix's sign-in rather than adding a second one, so it doesn't
run on its own. It needs:
- `config/db.php`: the PDO helpers `fetch_one`, `fetch_all`, `execute_query`
  and `insert_query`.
- `includes/auth.php`: `user_has_event_access()` and `log_audit()`. These read
  `$_SESSION`, which the API fills in memory from the token.
- `includes/event_time.php`: event time zones (`event_moment`,
  `event_staff_time`).
- The tables `users` (password hashes, roles, `must_change_password`,
  `password_changed_at`), `events`, `guests`, `user_event_permissions`,
  `audit_logs` and `login_attempts`.

## Installing it in Eventix

1. Copy `app/…` into the Eventix web root, at the same paths.
2. Apply `patches/eventix-core.diff`: two guards, in `config/config.php` and
   `includes/auth.php`.
3. Run `030_scanner_api.sql`. It only adds two tables and is safe to run twice.
4. Nothing to change in nginx. `/api/*.php` is already served, and every answer
   sends `X-Accel-Expires: 0`.

To undo: remove `app/api/scanner/` and `app/includes/scanner_api.php`, then run
`030_scanner_api.down.sql`.

## Tests

`evals/scanner_api_test.sh` copies the app to a sandbox server and gives it a
database of its own, built from the Eventix schema. That schema isn't included
here. The script then serves it with `php -S` and 8 workers, so parallel
requests really run at once, runs the checks, and removes everything. It covers:
- sign-in and lock-out;
- permissions;
- privacy of the guest list;
- replays after a lost answer;
- 16 phones checking in one guest at the same moment (exactly one wins);
- 12 identical uploads at once (stored once);
- tokens ending on sign-out, password change and role change.

The race check was shown to catch the bug: removing the row lock makes it fail.

```bash
EVX_KEY=~/.ssh/eval_key EVX_HOST=user@eval-server bash evals/scanner_api_test.sh
```
