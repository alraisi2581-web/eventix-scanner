# Real-device evidence

Recordings and screenshots from real phones, one set per platform, following
the checklist in [../testing.md](../testing.md#real-device-evidence-checklist).

Suggested names: `android-03-online-checkin.mp4`, `ios-10-two-phones.mp4`.
Keep clips short (under 50 MB each). For anything larger, attach it to a
GitHub release and link it here.

## Screenshots (Android, 2 November 2026)

Samsung Galaxy S20 Ultra (SM-G988B), Android 13, against the live server and
the test event. Shots 01–02 are from a debug build; the rest are from the
release build.

| File | Shows |
|---|---|
| [android-01-camera-denied.png](screenshots/android-01-camera-denied.png) | Camera access denied: explanation, Open Settings, Search by name |
| [android-02-camera-allowed-after-settings.png](screenshots/android-02-camera-allowed-after-settings.png) | After allowing the camera in Settings: the scanner starts without leaving the screen |
| [android-03-events.png](screenshots/android-03-events.png) | Events: the list saved on the phone, check-in progress |
| [android-04-scanner.png](screenshots/android-04-scanner.png) | Scanner: scan window, upload status, Search by name |
| [android-05-search-by-name.png](screenshots/android-05-search-by-name.png) | Search by name: results with table, RSVP and "In" badges |
| [android-06-confirm-check-in.png](screenshots/android-06-confirm-check-in.png) | Confirming a check-in by name |
| [android-07-already-checked-in-arabic.png](screenshots/android-07-already-checked-in-arabic.png) | Amber "Already checked in · time", in Arabic |
| [android-08-dark-mode.png](screenshots/android-08-dark-mode.png) | Dark mode |
| [android-09-activity.png](screenshots/android-09-activity.png) | Check-ins on this phone and their upload state |

## Recordings

Before recording, check that no real guest data is on screen. Use a scanner
account assigned only to the test event (event 7), never an admin account.

| # | Scenario | Android | iOS |
|---|---|---|---|
| 1 | First launch, camera permission | | |
| 2 | Permission denied → Settings / search by name | | |
| 3 | Online check-in | | |
| 4 | RSVP warning | | |
| 5 | Already checked in | | |
| 6 | Refused codes | | |
| 7 | Offline scans queue | | |
| 8 | Back online: upload, no duplicates | | |
| 9 | App killed while offline | | |
| 10 | Two phones, same guest | | |
| 11 | Search by name | | |
| 12 | Arabic | | |
| 13 | Sign-in errors | | |
| 14 | Sign out with pending | | |
