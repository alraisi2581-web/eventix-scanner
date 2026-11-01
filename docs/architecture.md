# Architecture

Eventix Scanner is a Flutter app (Android and iOS) that door staff use to check
guests in by scanning the QR code on their invitation. It works against the
existing Eventix server, and it keeps working when the venue's network does not.

## System diagram

```mermaid
flowchart LR
    subgraph Phone["Phone · Eventix Scanner (Flutter)"]
        UI["Screens<br/>sign-in · events · scanner<br/>search by name · activity"]
        CS["CheckinService<br/>decides each scan locally"]
        SS["SyncService<br/>uploads the outbox,<br/>refreshes the list"]
        DB[("SQLite (Drift)<br/>events · guests (token SHA-256)<br/>checkins = outbox")]
        KS[["Keychain / Android Keystore<br/>bearer token"]]
        CAM(["Camera<br/>mobile_scanner:<br/>ML Kit (Android) · Vision (iOS)"])
        CAM --> UI
        UI --> CS --> DB
        UI --> SS
        SS --> DB
        SS -. token .- KS
    end

    subgraph Server["Eventix server (existing, PHP 8.3 + MySQL 8, nginx)"]
        API["api/scanner/*.php<br/>login · logout · events<br/>guests · checkins"]
        AUTH["users · password hashes · roles<br/>user_event_permissions<br/>(shared with the website)"]
        TBL[("guests.checkin_status / checkin_time<br/>api_tokens · scanner_checkins<br/>audit_logs")]
        WEB["Website: web scanner,<br/>admin dashboards, live board"]
        API --> AUTH
        API --> TBL
        WEB --> TBL
    end

    SS == "HTTPS · Bearer token · JSON" ==> API
```

The phone never asks the server whether to let someone in. It decides from the
guest list it downloaded, records the check-in locally, and uploads it in the
background. The server has the final word on who was first.

## Components

| Layer | Files | Responsibility |
|---|---|---|
| Screens | `lib/ui/*` | Sign-in, events, scanner, search by name, activity. Loading, empty and error states; English and Arabic (right-to-left). |
| State | `lib/providers.dart` | Riverpod providers that wire everything together: session, sync status, database streams. |
| Check-in logic | `lib/services/checkin_service.dart` | Turns one scan into an outcome (checked in, already in, not on the list, wrong event, not an invitation) and writes the outbox row in the same transaction. |
| Sync | `lib/services/sync_service.dart` | Uploads pending check-ins in batches of 100, applies the server's answers, re-downloads the open guest list every minute while online, backs off when offline. |
| Storage | `lib/data/db/database.dart` | Drift (SQLite) tables and queries. |
| Session | `lib/data/session_store.dart` | Token in secure storage; language choice. |
| API client | `lib/data/api/` | The Eventix scanner API; errors become typed exceptions. |
| QR parsing | `lib/core/qr.dart` | Reads `https://…/qr/scan.php?t=<token>` (or a bare token) and hashes the token. |

## Data on the phone

```mermaid
erDiagram
    EVENTS ||--o{ GUESTS : "guest list (downloaded)"
    EVENTS ||--o{ CHECKINS : "made on this phone"
    GUESTS ||--o| CHECKINS : "at most one per guest"
    EVENTS { int id PK  int userId  text titleEn  text titleAr  text startsLabel  datetime listDownloadedAt }
    GUESTS { int id PK  int eventId  text nameEn  text nameAr  text rsvp  text tableNumber  text tokenSha256  bool serverCheckedIn  text serverCheckedInLabel }
    CHECKINS { text clientId PK  int userId  int eventId  int guestId  datetime scannedAt  enum state  int attempts  datetime syncedAt  text serverLabel  bool seen }
```

- **Guests** hold each QR token only as its SHA-256. The token is also the
  guest's RSVP link, so a lost phone must not hold it. The phone hashes what it
  scans and looks that up. No phone numbers or emails are downloaded.
- **Checkins** is an outbox. A row is `pending` until the server answers, then
  becomes `confirmed`, `conflict` (someone else reached the server first) or
  `rejected`. A unique key on (event, guest) means the first scan of a guest on
  this phone is the one kept. Later scans there only report it.
- The token is kept outside SQLite, in the Keychain or Keystore.

## How a scan flows

```mermaid
sequenceDiagram
    autonumber
    actor Staff as Door staff
    participant Cam as Camera
    participant CS as CheckinService
    participant DB as SQLite
    participant Sync as SyncService
    participant API as Eventix API
    Staff->>Cam: points at the guest's QR
    Cam->>CS: rawValue "https://eventix.om/qr/scan.php?t=…"
    CS->>DB: find guest by SHA-256(token)
    CS->>DB: (one transaction) no check-in yet → insert outbox row "pending"
    CS-->>Staff: GREEN "Checked in" (no network involved)
    CS->>Sync: kick()
    alt online
        Sync->>API: POST checkins.php [{client_id, guest_id, scanned_at}]
        API-->>Sync: checked_in / already_checked_in (+ time)
        Sync->>DB: confirmed / conflict
    else offline or timeout
        Sync-->>Sync: keep "pending", retry in 5 s, 10 s … 60 s,<br/>on network change, on app resume
    end
```

### Two scanners, one guest

```mermaid
sequenceDiagram
    participant B as Phone B (offline)
    participant A as Phone A (online)
    participant API as Eventix API
    B->>B: 19:01 scans Aisha → green, queued
    A->>A: 19:03 scans Aisha → green, queued
    A->>API: upload (client_id a1)
    API->>API: lock Aisha's row → not in → check in (19:03)
    API-->>A: checked_in · 7:03 pm
    B->>API: upload when back online (client_id b1)
    API->>API: lock Aisha's row → already in
    API-->>B: already_checked_in · 7:03 pm
    B->>B: banner "Aisha was already checked in at 7:03 pm.<br/>This phone's scan didn't count."
```

The first check-in to **reach the server** wins, as required. Phone B's own
record (its 19:01 scan) stays on B, marked as a conflict. B is told clearly
that the guest is already checked in, with the time but not who did it. That
matches the web scanner (owner's decision).

### Never lost, never doubled

- **Not lost.** The outbox row is written in the same SQLite transaction that
  decides the scan. It is uploaded until the server answers it. Signing out,
  an expired sign-in and app restarts all keep pending rows.
- **Not doubled.** Every check-in carries a UUID made on the phone
  (`client_id`). If an upload reaches the server but the reply is lost, the
  phone sends the same `client_id` again. The server answers from
  `scanner_checkins` and changes nothing.
- **Races on the server.** The server locks the guest's row (`SELECT … FOR
  UPDATE`). Sixteen phones racing for one guest get exactly one
  `checked_in` (tested; removing the lock makes the test fail).

## App lifecycle

| Moment | What happens |
|---|---|
| Cold start | The session is read from secure storage. With a saved token the app opens on the events screen even with no network, showing the saved events. |
| Events screen | Refreshes the event list from the server; on failure keeps the saved list and shows "Offline". |
| Opening an event | Downloads its guest list the first time (needs the network once). |
| Scanner open | The sync engine knows the open event and re-downloads its list every 60 s while online, so this phone learns about other scanners' check-ins and web undos. |
| A scan | Decided and stored locally. An upload is started at once. |
| App goes inactive (call, app switcher) | The camera stops. Nothing needs saving: every check-in is already committed to SQLite. |
| App resumes | The camera restarts, including after camera access was granted in Settings. The outbox uploads and the list refreshes. |
| Network comes back | `connectivity_plus` reports it and an upload starts. A request that succeeds is the real test of being online. |
| In the background | Nothing runs (iOS doesn't allow it reliably). Pending check-ins upload the next time the app is in front. |
| App killed or phone dies | Check-ins already shown on screen are in SQLite and upload on the next start. |
| Server refuses the token (expired, revoked, password changed) | The app returns to sign-in with the username filled in. Pending check-ins wait and upload as soon as the same user signs in again. |
| Sign-out | The token is revoked if online. Downloaded guest lists are deleted. Pending check-ins stay, and the app asks first if any are waiting. |

## Security and privacy

- Sign-in uses the existing Eventix accounts: same password hashes, roles and
  event permissions. Only `scanner` and `admin` accounts can sign in. A
  temporary password is refused until the user chooses their own on the website.
- The bearer token is 256 bits of randomness. The server stores only its
  SHA-256. On the phone it lives in the Keychain or Keystore. It expires after
  14 days, and stops working on sign-out, a password change or a role change.
- Android `allowBackup=false`: the token and guest lists never go to cloud
  backups.
- The guest list on the phone has names, RSVP and table only. QR tokens are
  stored as hashes.
- All traffic is HTTPS to `eventix.om`. API responses are marked uncacheable
  (`X-Accel-Expires: 0`) because the server's 1-second nginx microcache keys
  on the URL alone.
