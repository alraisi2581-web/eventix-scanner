# Operation: running the door with Eventix Scanner

A runbook for event teams.
- **The admin** works on the Eventix website: <https://eventix.om/login>.
- **Door staff** use the app.

## Before the event (admin)

1. **Create one scanner account per door phone** (Admin → Users → role
   *scanner*) and assign it **only** to this event. An admin account sees every
   event, so don't use one at the door.
2. The password you set is temporary. Each person **signs in once at
   eventix.om/login** to choose their own; the app refuses a temporary
   password and says so.
3. Lock the guest list and generate the QR invitations as usual. A guest added
   after a phone downloaded the list is unknown to that phone until its next
   refresh.

## Before doors open (each phone)

1. Install the app: the APK from the
   [latest release](https://github.com/alraisi2581-web/eventix-scanner/releases/latest)
   on Android, or a build from Xcode on iPhone.
2. **While online**, sign in and open the event once. The guest list downloads,
   and from then on the phone can scan without a network.
3. Check that the chip at the top says **Online · all uploaded**. Allow the
   camera when asked.

## At the door

| On screen | Meaning | What to do |
|---|---|---|
| **Green: Checked in** | First scan of this guest | Let them in. A table number, if any, is shown. |
| Green with **RSVP: not attending / no reply** | On the list but didn't confirm | Follow the host's policy. The check-in still counts. |
| **Amber: Already checked in · time** | Someone already scanned this guest | Ask for ID or the host's decision. |
| **Red: Not on the guest list** | An Eventix QR for someone not on this list | Check the name with the host. |
| **Red: Invitation for another event** | The QR is for a different event | Point the guest to the right event. |
| **Red: Not an Eventix invitation** | Any other QR | Ask for the invitation's QR. |

- **Search by name** (the gold button) finds a guest by name in English or
  Arabic, or by table number. Use it for guests without their QR, or if the
  camera fails.
- **The torch** button is at the top right, and **Activity** (the clock icon)
  lists everything this phone checked in.

## When the network drops

- **Keep scanning.** Answers come from the phone. The chip shows **Offline · N
  waiting**.
- **Nothing is lost.** Check-ins are saved on the phone as they happen, even if
  the app is closed or the phone restarts.
- **When the network returns,** uploads start by themselves. Tap the chip to
  try at once.

## When two phones check in the same guest

The first check-in to reach Eventix counts. The other phone shows a banner,
"*Name* was already checked in at *time*. This phone's scan didn't count.",
until someone taps **OK**. Nothing needs to be done; the guest is checked in
once.

## "Sign in again to upload"

The phone's sign-in ended: the password was changed, the role changed, or
14 days passed. **Sign in again with the same account.** Waiting check-ins
upload then. They're never discarded.

## Undo a check-in

On the website only, not in the app. Sign in at eventix.om, open **Scanner →
Manual check-in**, find the guest and tap **Undo**. Admin and scanner accounts
can do this. Phones pick up the change within a minute while scanning, and the
guest can then be scanned in again.

## After the event

1. On each phone, wait for **Online · all uploaded**, or open Activity and tap
   **Upload now**.
2. **Sign out.** The app warns if anything is still waiting. Signing out
   deletes the downloaded guest lists from the phone.
3. Remove or disable the scanner accounts on the website.

## Lost phone

Change that scanner account's password on the website. The phone's sign-in
ends at its next request. Guest lists on the phone hold names, RSVP and table
only, with no phone numbers, emails or usable QR codes.

## Troubleshooting

| Symptom | Cause | Fix |
|---|---|---|
| "Your password is temporary" at sign-in | An admin set or reset the password | Sign in once at eventix.om/login and choose a new one |
| "This account can't check guests in" | Not a scanner or admin account | Use a scanner account |
| "No events yet" | The account isn't assigned to the event | Assign it on the website, then pull down to refresh |
| "Too many failed sign-ins" | 10 wrong passwords in 30 minutes, for that username on this network | Wait 30 minutes; others on the same Wi-Fi are not blocked |
| "Camera access is off" | The camera permission was denied | Open Settings and allow the camera, or use Search by name |
| The chip stays "Offline" with Wi-Fi on | A captive portal, or no internet behind the Wi-Fi | Open a browser to sign in to the Wi-Fi, or switch to mobile data. Scanning continues meanwhile. |
| "Not on the guest list" for a known guest | Added after this phone's download | Keep the scanner open while online (the list refreshes every minute), or use Search by name after that, or check them in on the website |
