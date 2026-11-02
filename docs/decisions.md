# Decisions

Each decision below lists the options, what was chosen, who chose it, and why.
"Owner" is the Eventix owner, who reviewed every architectural choice. The
evidence behind the backend choices is in [backend-api.md](backend-api.md).

| # | Decision | Options considered | Chosen | By | Why |
|---|---|---|---|---|---|
| 1 | How the app stays signed in | Reuse the website's `PHPSESSID` cookie · a device bearer token checked against the same accounts | **Bearer token** (14 days, revocable, stored hashed) | Owner, on a recommendation | The real server ends sessions after 24 idle minutes. A cookie would sign door staff out before doors open and break offline sync. The token still uses the same accounts, passwords, roles and event permissions. |
| 2 | Where the code lives | Inside the Eventix monorepo · a new repo for the app + a branch in Eventix for the API | **New repo + Eventix branch** | Owner | The Eventix repository holds server details and generated guest QR images, so it can't meet "no private data in Git". This repo can. |
| 3 | Server to build and film against | A staging copy · production with a test event | **Production**, with a new event of made-up guests; everything committed first so rollback is one step | Owner | Real behaviour on the real system. The live event (event 4) is untouched. Its guests are never loaded in demos (use scanner accounts, not admin). |
| 4 | What the losing phone is told | Who checked the guest in · only that they are already in | **"Already checked in" + time**, as the web scanner shows | Owner | Matches what staff already see. No staff names on other phones. |
| 5 | Who wins a double check-in | First scanned (phone clock) · first to reach the server | **First to reach the server**; the losing phone keeps its own record of its scan, marked "didn't count" | Owner (requirement) | Phone clocks can't be trusted. The server decides under a row lock. |
| 6 | State and storage in the app | Riverpod + Drift · Provider + sqflite · Bloc + Drift | **Riverpod + Drift** | Owner, on a recommendation | Typed SQL and transactions. "Decide the scan and queue the upload" is one atomic write, so it survives the app being killed. Providers are testable without widgets. |
| 7 | Languages | English only · English + Arabic | **English + Arabic (RTL)** | Owner | Eventix is bilingual everywhere. |
| 8 | Undo a check-in in the app | Online-only undo · web only | **Web only** (an admin undoes it) | Owner, on a recommendation | Keeps sync one-directional and conflict-free. The app picks up web undos when it refreshes the list. |
| 9 | QR tokens on the phone | Raw tokens · SHA-256 of tokens | **SHA-256 only** | Recommended, implemented | A token is also the guest's RSVP link; a lost phone must not hold them. |
| 10 | Duplicate protection | Server dedup by (guest, time) · phone-made UUID per check-in | **UUID `client_id`**, unique on the server, replayed answers | Recommended, implemented | Makes uploads safe to repeat after a lost reply. Proven by tests, including 12 identical uploads sent at once. |
| 11 | nginx microcache | Change the nginx config · mark responses uncacheable in PHP | **`X-Accel-Expires: 0` in PHP** | Recommended, implemented | Fixes the problem without touching the live web server's config. Verified in the deployed responses. |
| 12 | Sign-in lock-out | Per IP (as the website) · per username + IP | **Per username + IP** | Recommended, implemented | The door team shares one Wi-Fi IP. One person's typos must not lock everyone out. |
| 13 | Minimum OS | — | **Android 7.0 (API 24), iOS 13** | Set by the plugins | `flutter_secure_storage` 11 needs API 24 and iOS 13 — the highest minimums of the plugins used. |
| 14 | Generated code in Git | Commit `*.g.dart` and l10n output · generate at build time | **Committed** | Implemented | Anyone can build with `flutter build` alone; `build_runner` is only needed after schema changes. |
| 15 | Look and feel | A new design for the app · the Eventix web app's design | **The web app's design system**: its tokens (`app/assets/css/eventix.css`) in light and dark with the same toggle, its logo and favicon, its fonts | Owner | One product across web and phone. Door staff recognise it at once. The scan result is the one bold screen: full status colour, the guest's name in Playfair. |
| 16 | Fonts | Download at run time (`google_fonts`) · bundle in the app | **Bundled** (≈0.85 MB, OFL), downloaded once from Google Fonts' repository with the owner's OK | Owner | A door phone may have no network when the app first starts. |
