# Testing and evidence

## Automated tests

```bash
flutter test
```

On Windows, `flutter test` needs a `sqlite3.dll` for the in-memory database
tests. Point `SQLITE3_DLL` at one (Python ships one in its `DLLs` folder).
macOS has SQLite built in; on Linux install `libsqlite3-dev`. The same tests run
in CI on every push ([.github/workflows/android.yml](../.github/workflows/android.yml)).

| File | What it proves |
|---|---|
| `test/qr_test.dart` (5) | Invitation QRs and bare tokens are read the way the web scanner reads them, and anything else is refused. The hash matches PHP's `hash('sha256')`. |
| `test/checkin_flow_test.dart` (15) | Two phones against a fake server that follows the real server's rules:<br/>• scans decided offline;<br/>• second scan on the same phone keeps the first;<br/>• offline queue uploads later with nothing lost;<br/>• a lost reply is resent and not counted twice;<br/>• 230 check-ins go up in three batches;<br/>• first to the server wins and the other phone gets a conflict;<br/>• a refreshed list warns before scanning;<br/>• a web undo allows a re-scan;<br/>• an expired sign-in keeps the queue;<br/>• sign-out keeps pending check-ins. |
| `test/screens_test.dart` (11) | Sign-in:<br/>• validation;<br/>• each server refusal explained;<br/>• offline restart shows the saved events;<br/>• empty state.<br/>Also: Arabic right-to-left; the green, amber and red results with the RSVP warning; search by name with validation and check-in; the conflict banner until acknowledged. |

The server side has its own suite in the Eventix repository:
`evals/scanner_api_test.sh` runs 71 checks over real HTTP, against a sandbox
copy served by `php -S` with 8 workers. The checks include:
- 16 phones racing for one guest (exactly one wins);
- the same upload sent 12 times at once (stored once);
- tokens ending on sign-out, password change and role change;
- no phone numbers, emails or raw tokens in responses.

Removing the row lock makes the race check fail. That was tried, to prove the
test can catch the bug. The existing Eventix unit suite (780 checks) still
passes with the changes.

## Test data on the live server

- **Event 7**, "TEST - Scanner app (fake guests)": 40 made-up guests, every one
  marked *do not contact* (no invitation can be sent).
- One guest, Saif Test-Alpha, is already checked in from the web, for the
  "already checked in" case. Some have RSVP *Not Attending* or *No Reply*.
- A printable QR sheet for event 7 is kept outside Git: the QR codes are real
  RSVP links, even for fake guests. It holds every guest's QR plus two that
  must be refused ("not on the list", "not an Eventix QR").
- Scanner accounts for testing are created by an admin in Eventix
  (`admin/users.php`) and assigned to event 7 only. Don't use an admin account
  for recordings: admins see every event, including the live one.

## Real-device evidence checklist

Hardware features need recordings on real phones. Record each row on **both**
an Android phone and an iPhone. Save clips in `docs/evidence/` (or link them
from a release if they are large). Write the device model and OS version in
the table.

| # | Scenario | Steps | Expected | Android | iOS |
|---|---|---|---|---|---|
| 1 | First launch, camera permission | Fresh install → sign in → open event 7 → scanner | The OS asks for the camera; after Allow the preview starts | | |
| 2 | Permission denied | Deny the camera (or turn it off in Settings) → open the scanner | "Camera access is off" with Open Settings and Search by name. Turning access on in Settings and returning restarts the camera. | | |
| 3 | Online check-in | Scan a guest | Green "Checked in", name in both languages, table; chip "Online · all uploaded"; the guest shows as checked in on the website within seconds | | |
| 4 | RSVP warning | Scan a *Not Attending* guest | Green with "RSVP: not attending" | | |
| 5 | Already in | Scan Saif Test-Alpha, or rescan any guest | Amber "Already checked in · time" | | |
| 6 | Refused codes | Scan "Not on the list" and "Not an Eventix QR" | Red, with what to do | | |
| 7 | Offline | Airplane mode → scan 3 guests | Each green at once; chip "Offline · 3 waiting"; Activity shows them waiting | | |
| 8 | Back online | Turn airplane mode off | Uploads by themselves; chip "Online · all uploaded"; website shows all 3 once, with no duplicates (event dashboard count) | | |
| 9 | App killed while offline | Offline → scan → swipe the app away → reopen → go online | The check-in is still there and uploads | | |
| 10 | Two phones, same guest | Phone B offline scans guest X; phone A online scans X; B goes online | A green; B shows the banner "X was already checked in at … This phone's scan didn't count."; Activity marks it | | |
| 11 | Search by name | Search by name → type 1 letter → type a name → check in | Validation message, then results, then confirm, then green | | |
| 12 | Arabic | Language → العربية | Right-to-left layout, Arabic texts and names | | |
| 13 | Sign-in errors | Wrong password; a temporary-password account | Clear messages | | |
| 14 | Sign out with pending | Offline → scan → sign out | Warned first; after signing in again, the check-in uploads | | |

Tip for #10: the web scanner's live board (`admin/checkin_live`) shows
check-ins arriving, which is useful in the same recording.
