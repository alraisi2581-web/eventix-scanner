// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Eventix Scanner';

  @override
  String get signInTitle => 'Sign in to check guests in';

  @override
  String get signInHint => 'Use the scanner account Eventix gave you.';

  @override
  String get username => 'Username';

  @override
  String get password => 'Password';

  @override
  String get showPassword => 'Show password';

  @override
  String get hidePassword => 'Hide password';

  @override
  String get signIn => 'Sign in';

  @override
  String get usernameRequired => 'Enter your username';

  @override
  String get usernameTooLong => 'That username is too long';

  @override
  String get passwordRequired => 'Enter your password';

  @override
  String pendingFromBefore(int count, String username) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count check-ins by $username are waiting to upload.',
      one: '1 check-in by $username is waiting to upload.',
    );
    return '$_temp0 Sign in as $username to send them.';
  }

  @override
  String get errorWrongPassword => 'Wrong username or password.';

  @override
  String get errorRoleNotAllowed =>
      'This account can\'t check guests in. Sign in with a scanner account.';

  @override
  String get errorPasswordChange =>
      'Your password is temporary. Sign in once at eventix.om/login to choose your own, then sign in here with it.';

  @override
  String get errorTooManyAttempts =>
      'Too many failed sign-ins. Try again in 30 minutes.';

  @override
  String get errorNetwork =>
      'No connection to Eventix. Check the Wi-Fi or mobile data and try again.';

  @override
  String get errorRateLimited =>
      'Too many requests. Wait a minute and try again.';

  @override
  String get errorForbidden => 'You don\'t have access to this event.';

  @override
  String get errorServer => 'Eventix couldn\'t answer. Try again in a moment.';

  @override
  String get yourEvents => 'Your events';

  @override
  String signedInAs(String username) {
    return 'Signed in as $username';
  }

  @override
  String get noEventsTitle => 'No events yet';

  @override
  String get noEventsBody =>
      'Your account isn\'t assigned to an event. Ask an Eventix admin to give you access, then pull down to refresh.';

  @override
  String get offlineSavedList =>
      'Offline — showing what\'s saved on this phone.';

  @override
  String get retry => 'Try again';

  @override
  String guestCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count guests',
      one: '1 guest',
    );
    return '$_temp0';
  }

  @override
  String get listSaved => 'Saved on this phone';

  @override
  String get listNotSaved => 'Not downloaded yet';

  @override
  String get downloadingList => 'Downloading the guest list…';

  @override
  String get downloadNeedsNetwork =>
      'Connect to the internet once to download this event\'s guest list. After that, scanning works offline.';

  @override
  String get signOut => 'Sign out';

  @override
  String get signOutPendingTitle => 'Check-ins not uploaded yet';

  @override
  String signOutPendingBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count check-ins haven\'t reached Eventix.',
      one: '1 check-in hasn\'t reached Eventix.',
    );
    return '$_temp0 They stay on this phone and upload when you sign in again. Sign out anyway?';
  }

  @override
  String get cancel => 'Cancel';

  @override
  String get ok => 'OK';

  @override
  String get language => 'Language';

  @override
  String get english => 'English';

  @override
  String get arabic => 'العربية';

  @override
  String get statusAllUploaded => 'Online · all uploaded';

  @override
  String get statusUploading => 'Uploading…';

  @override
  String statusWaiting(int count) {
    return '$count waiting to upload';
  }

  @override
  String statusOffline(int count) {
    return 'Offline · $count waiting';
  }

  @override
  String get statusOfflineNoneWaiting => 'Offline';

  @override
  String get statusSignIn => 'Sign in again to upload';

  @override
  String get statusConnecting => 'Connecting…';

  @override
  String checkedInOf(int checked, int total) {
    return '$checked of $total in';
  }

  @override
  String get resultCheckedIn => 'Checked in';

  @override
  String get resultAlready => 'Already checked in';

  @override
  String resultAlreadyAt(String time) {
    return 'Already checked in · $time';
  }

  @override
  String resultScannedHere(String time) {
    return 'Scanned on this phone at $time';
  }

  @override
  String get resultNotOnList => 'Not on the guest list';

  @override
  String get resultNotOnListHint =>
      'This invitation isn\'t for this event, or the guest was removed from the list.';

  @override
  String get resultWrongEvent => 'Invitation for another event';

  @override
  String resultWrongEventHint(String event) {
    return 'This QR is for “$event”.';
  }

  @override
  String get resultNotInvitation => 'Not an Eventix invitation';

  @override
  String get resultNotInvitationHint =>
      'Ask the guest for the QR code on their invitation.';

  @override
  String get rsvpNotAttending => 'RSVP: not attending';

  @override
  String get rsvpNoReply => 'RSVP: no reply';

  @override
  String get rsvpMaybe => 'RSVP: maybe';

  @override
  String table(String table) {
    return 'Table $table';
  }

  @override
  String get tapToContinue => 'Tap to continue';

  @override
  String get searchByName => 'Search by name';

  @override
  String get activity => 'Check-ins on this phone';

  @override
  String get torch => 'Torch';

  @override
  String get cameraDeniedTitle => 'Camera access is off';

  @override
  String get cameraDeniedBody =>
      'The scanner needs the camera to read invitation QR codes. Turn on camera access for Eventix Scanner in Settings, or check guests in by name.';

  @override
  String get openSettings => 'Open Settings';

  @override
  String get cameraErrorTitle => 'The camera couldn\'t start';

  @override
  String get cameraErrorBody =>
      'Close other apps using the camera and try again, or check guests in by name.';

  @override
  String get searchHint => 'Name or table number';

  @override
  String get searchTooShort => 'Type at least 2 letters, or a table number';

  @override
  String searchNoMatch(String query) {
    return 'No guest matches “$query”';
  }

  @override
  String checkInConfirm(String name) {
    return 'Check in $name?';
  }

  @override
  String get checkIn => 'Check in';

  @override
  String get badgeIn => 'In';

  @override
  String get activityEmpty => 'No check-ins on this phone yet.';

  @override
  String get statePending => 'Waiting to upload';

  @override
  String stateConfirmed(String time) {
    return 'Uploaded · checked in $time';
  }

  @override
  String stateConflict(String time) {
    return 'Already checked in at $time — this phone\'s scan didn\'t count';
  }

  @override
  String stateRejected(String reason) {
    return 'Not accepted by Eventix: $reason';
  }

  @override
  String conflictBanner(String name, String time) {
    return '$name was already checked in at $time. This phone\'s scan didn\'t count.';
  }

  @override
  String rejectedBanner(String name, String reason) {
    return '$name\'s check-in wasn\'t accepted: $reason';
  }

  @override
  String get reasonRemoved => 'the guest is no longer on the list';

  @override
  String get undoHint => 'To undo a check-in, ask an Eventix admin.';

  @override
  String get uploadNow => 'Upload now';

  @override
  String get earlierTime => 'earlier';

  @override
  String get footer => 'Eventix by Thermo Tech';

  @override
  String get scanHint => 'Point the camera at the QR code on the invitation';

  @override
  String get openScanner => 'Open scanner';

  @override
  String eventProgress(int checked, int total, int pct) {
    return '$checked / $total checked in ($pct%)';
  }

  @override
  String get summaryUploaded => 'Uploaded';

  @override
  String get summaryWaiting => 'Waiting';

  @override
  String get summaryNotCounted => 'Didn\'t count';

  @override
  String get badgeUploaded => 'Uploaded';

  @override
  String get badgeNotCounted => 'Didn\'t count';

  @override
  String checkedInAtTime(String time) {
    return 'Checked in at $time';
  }
}
