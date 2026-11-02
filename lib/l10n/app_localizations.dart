import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Eventix Scanner'**
  String get appTitle;

  /// No description provided for @signInTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to check guests in'**
  String get signInTitle;

  /// No description provided for @signInHint.
  ///
  /// In en, this message translates to:
  /// **'Use the scanner account Eventix gave you.'**
  String get signInHint;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @showPassword.
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get showPassword;

  /// No description provided for @hidePassword.
  ///
  /// In en, this message translates to:
  /// **'Hide password'**
  String get hidePassword;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// No description provided for @usernameRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter your username'**
  String get usernameRequired;

  /// No description provided for @usernameTooLong.
  ///
  /// In en, this message translates to:
  /// **'That username is too long'**
  String get usernameTooLong;

  /// No description provided for @passwordRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get passwordRequired;

  /// No description provided for @pendingFromBefore.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 check-in by {username} is waiting to upload.} other{{count} check-ins by {username} are waiting to upload.}} Sign in as {username} to send them.'**
  String pendingFromBefore(int count, String username);

  /// No description provided for @errorWrongPassword.
  ///
  /// In en, this message translates to:
  /// **'Wrong username or password.'**
  String get errorWrongPassword;

  /// No description provided for @errorRoleNotAllowed.
  ///
  /// In en, this message translates to:
  /// **'This account can\'t check guests in. Sign in with a scanner account.'**
  String get errorRoleNotAllowed;

  /// No description provided for @errorPasswordChange.
  ///
  /// In en, this message translates to:
  /// **'Your password is temporary. Sign in once at eventix.om/login to choose your own, then sign in here with it.'**
  String get errorPasswordChange;

  /// No description provided for @errorTooManyAttempts.
  ///
  /// In en, this message translates to:
  /// **'Too many failed sign-ins. Try again in 30 minutes.'**
  String get errorTooManyAttempts;

  /// No description provided for @errorNetwork.
  ///
  /// In en, this message translates to:
  /// **'No connection to Eventix. Check the Wi-Fi or mobile data and try again.'**
  String get errorNetwork;

  /// No description provided for @errorRateLimited.
  ///
  /// In en, this message translates to:
  /// **'Too many requests. Wait a minute and try again.'**
  String get errorRateLimited;

  /// No description provided for @errorForbidden.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have access to this event.'**
  String get errorForbidden;

  /// No description provided for @errorServer.
  ///
  /// In en, this message translates to:
  /// **'Eventix couldn\'t answer. Try again in a moment.'**
  String get errorServer;

  /// No description provided for @yourEvents.
  ///
  /// In en, this message translates to:
  /// **'Your events'**
  String get yourEvents;

  /// No description provided for @signedInAs.
  ///
  /// In en, this message translates to:
  /// **'Signed in as {username}'**
  String signedInAs(String username);

  /// No description provided for @noEventsTitle.
  ///
  /// In en, this message translates to:
  /// **'No events yet'**
  String get noEventsTitle;

  /// No description provided for @noEventsBody.
  ///
  /// In en, this message translates to:
  /// **'Your account isn\'t assigned to an event. Ask an Eventix admin to give you access, then pull down to refresh.'**
  String get noEventsBody;

  /// No description provided for @offlineSavedList.
  ///
  /// In en, this message translates to:
  /// **'Offline — showing what\'s saved on this phone.'**
  String get offlineSavedList;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get retry;

  /// No description provided for @guestCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 guest} other{{count} guests}}'**
  String guestCount(int count);

  /// No description provided for @listSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved on this phone'**
  String get listSaved;

  /// No description provided for @listNotSaved.
  ///
  /// In en, this message translates to:
  /// **'Not downloaded yet'**
  String get listNotSaved;

  /// No description provided for @downloadingList.
  ///
  /// In en, this message translates to:
  /// **'Downloading the guest list…'**
  String get downloadingList;

  /// No description provided for @downloadNeedsNetwork.
  ///
  /// In en, this message translates to:
  /// **'Connect to the internet once to download this event\'s guest list. After that, scanning works offline.'**
  String get downloadNeedsNetwork;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// No description provided for @signOutPendingTitle.
  ///
  /// In en, this message translates to:
  /// **'Check-ins not uploaded yet'**
  String get signOutPendingTitle;

  /// No description provided for @signOutPendingBody.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 check-in hasn\'t reached Eventix.} other{{count} check-ins haven\'t reached Eventix.}} They stay on this phone and upload when you sign in again. Sign out anyway?'**
  String signOutPendingBody(int count);

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @arabic.
  ///
  /// In en, this message translates to:
  /// **'العربية'**
  String get arabic;

  /// No description provided for @statusAllUploaded.
  ///
  /// In en, this message translates to:
  /// **'Online · all uploaded'**
  String get statusAllUploaded;

  /// No description provided for @statusUploading.
  ///
  /// In en, this message translates to:
  /// **'Uploading…'**
  String get statusUploading;

  /// No description provided for @statusWaiting.
  ///
  /// In en, this message translates to:
  /// **'{count} waiting to upload'**
  String statusWaiting(int count);

  /// No description provided for @statusOffline.
  ///
  /// In en, this message translates to:
  /// **'Offline · {count} waiting'**
  String statusOffline(int count);

  /// No description provided for @statusOfflineNoneWaiting.
  ///
  /// In en, this message translates to:
  /// **'Offline · scanning still works'**
  String get statusOfflineNoneWaiting;

  /// No description provided for @statusSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in again to upload'**
  String get statusSignIn;

  /// No description provided for @statusConnecting.
  ///
  /// In en, this message translates to:
  /// **'Connecting…'**
  String get statusConnecting;

  /// No description provided for @checkedInOf.
  ///
  /// In en, this message translates to:
  /// **'{checked} of {total} in'**
  String checkedInOf(int checked, int total);

  /// No description provided for @resultCheckedIn.
  ///
  /// In en, this message translates to:
  /// **'Checked in'**
  String get resultCheckedIn;

  /// No description provided for @resultAlready.
  ///
  /// In en, this message translates to:
  /// **'Already checked in'**
  String get resultAlready;

  /// No description provided for @resultAlreadyAt.
  ///
  /// In en, this message translates to:
  /// **'Already checked in · {time}'**
  String resultAlreadyAt(String time);

  /// No description provided for @resultScannedHere.
  ///
  /// In en, this message translates to:
  /// **'Scanned on this phone at {time}'**
  String resultScannedHere(String time);

  /// No description provided for @resultNotOnList.
  ///
  /// In en, this message translates to:
  /// **'Not on the guest list'**
  String get resultNotOnList;

  /// No description provided for @resultNotOnListHint.
  ///
  /// In en, this message translates to:
  /// **'This invitation isn\'t for this event, or the guest was removed from the list.'**
  String get resultNotOnListHint;

  /// No description provided for @resultWrongEvent.
  ///
  /// In en, this message translates to:
  /// **'Invitation for another event'**
  String get resultWrongEvent;

  /// No description provided for @resultWrongEventHint.
  ///
  /// In en, this message translates to:
  /// **'This QR is for “{event}”.'**
  String resultWrongEventHint(String event);

  /// No description provided for @resultNotInvitation.
  ///
  /// In en, this message translates to:
  /// **'Not an Eventix invitation'**
  String get resultNotInvitation;

  /// No description provided for @resultNotInvitationHint.
  ///
  /// In en, this message translates to:
  /// **'Ask the guest for the QR code on their invitation.'**
  String get resultNotInvitationHint;

  /// No description provided for @rsvpNotAttending.
  ///
  /// In en, this message translates to:
  /// **'RSVP: not attending'**
  String get rsvpNotAttending;

  /// No description provided for @rsvpNoReply.
  ///
  /// In en, this message translates to:
  /// **'RSVP: no reply'**
  String get rsvpNoReply;

  /// No description provided for @rsvpMaybe.
  ///
  /// In en, this message translates to:
  /// **'RSVP: maybe'**
  String get rsvpMaybe;

  /// No description provided for @table.
  ///
  /// In en, this message translates to:
  /// **'Table {table}'**
  String table(String table);

  /// No description provided for @tapToContinue.
  ///
  /// In en, this message translates to:
  /// **'Tap to continue'**
  String get tapToContinue;

  /// No description provided for @searchByName.
  ///
  /// In en, this message translates to:
  /// **'Search by name'**
  String get searchByName;

  /// No description provided for @activity.
  ///
  /// In en, this message translates to:
  /// **'Check-ins on this phone'**
  String get activity;

  /// No description provided for @torch.
  ///
  /// In en, this message translates to:
  /// **'Torch'**
  String get torch;

  /// No description provided for @cameraDeniedTitle.
  ///
  /// In en, this message translates to:
  /// **'Camera access is off'**
  String get cameraDeniedTitle;

  /// No description provided for @cameraDeniedBody.
  ///
  /// In en, this message translates to:
  /// **'The scanner needs the camera to read invitation QR codes. Turn on camera access for Eventix Scanner in Settings, or check guests in by name.'**
  String get cameraDeniedBody;

  /// No description provided for @openSettings.
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get openSettings;

  /// No description provided for @cameraErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'The camera couldn\'t start'**
  String get cameraErrorTitle;

  /// No description provided for @cameraErrorBody.
  ///
  /// In en, this message translates to:
  /// **'Close other apps using the camera and try again, or check guests in by name.'**
  String get cameraErrorBody;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Name or table number'**
  String get searchHint;

  /// No description provided for @searchTooShort.
  ///
  /// In en, this message translates to:
  /// **'Type at least 2 letters, or a table number'**
  String get searchTooShort;

  /// No description provided for @searchNoMatch.
  ///
  /// In en, this message translates to:
  /// **'No guest matches “{query}”'**
  String searchNoMatch(String query);

  /// No description provided for @checkInConfirm.
  ///
  /// In en, this message translates to:
  /// **'Check in {name}?'**
  String checkInConfirm(String name);

  /// No description provided for @checkIn.
  ///
  /// In en, this message translates to:
  /// **'Check in'**
  String get checkIn;

  /// No description provided for @badgeIn.
  ///
  /// In en, this message translates to:
  /// **'In'**
  String get badgeIn;

  /// No description provided for @activityEmpty.
  ///
  /// In en, this message translates to:
  /// **'No check-ins on this phone yet.'**
  String get activityEmpty;

  /// No description provided for @statePending.
  ///
  /// In en, this message translates to:
  /// **'Waiting to upload'**
  String get statePending;

  /// No description provided for @stateConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Uploaded · checked in {time}'**
  String stateConfirmed(String time);

  /// No description provided for @stateConflict.
  ///
  /// In en, this message translates to:
  /// **'Already checked in at {time} — this phone\'s scan didn\'t count'**
  String stateConflict(String time);

  /// No description provided for @stateRejected.
  ///
  /// In en, this message translates to:
  /// **'Not accepted by Eventix: {reason}'**
  String stateRejected(String reason);

  /// No description provided for @conflictBanner.
  ///
  /// In en, this message translates to:
  /// **'{name} was already checked in at {time}. This phone\'s scan didn\'t count.'**
  String conflictBanner(String name, String time);

  /// No description provided for @rejectedBanner.
  ///
  /// In en, this message translates to:
  /// **'{name}\'s check-in wasn\'t accepted: {reason}'**
  String rejectedBanner(String name, String reason);

  /// No description provided for @reasonRemoved.
  ///
  /// In en, this message translates to:
  /// **'the guest is no longer on the list'**
  String get reasonRemoved;

  /// No description provided for @undoHint.
  ///
  /// In en, this message translates to:
  /// **'To undo a check-in, ask an Eventix admin.'**
  String get undoHint;

  /// No description provided for @uploadNow.
  ///
  /// In en, this message translates to:
  /// **'Upload now'**
  String get uploadNow;

  /// No description provided for @earlierTime.
  ///
  /// In en, this message translates to:
  /// **'earlier'**
  String get earlierTime;

  /// No description provided for @footer.
  ///
  /// In en, this message translates to:
  /// **'Eventix by Thermo Tech'**
  String get footer;

  /// No description provided for @scanHint.
  ///
  /// In en, this message translates to:
  /// **'Point the camera at the QR code on the invitation'**
  String get scanHint;

  /// No description provided for @openScanner.
  ///
  /// In en, this message translates to:
  /// **'Open scanner'**
  String get openScanner;

  /// No description provided for @eventProgress.
  ///
  /// In en, this message translates to:
  /// **'{checked} / {total} checked in ({pct}%)'**
  String eventProgress(int checked, int total, int pct);

  /// No description provided for @summaryUploaded.
  ///
  /// In en, this message translates to:
  /// **'Uploaded'**
  String get summaryUploaded;

  /// No description provided for @summaryWaiting.
  ///
  /// In en, this message translates to:
  /// **'Waiting'**
  String get summaryWaiting;

  /// No description provided for @summaryNotCounted.
  ///
  /// In en, this message translates to:
  /// **'Didn\'t count'**
  String get summaryNotCounted;

  /// No description provided for @badgeUploaded.
  ///
  /// In en, this message translates to:
  /// **'Uploaded'**
  String get badgeUploaded;

  /// No description provided for @badgeNotCounted.
  ///
  /// In en, this message translates to:
  /// **'Didn\'t count'**
  String get badgeNotCounted;

  /// No description provided for @checkedInAtTime.
  ///
  /// In en, this message translates to:
  /// **'Checked in at {time}'**
  String checkedInAtTime(String time);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
