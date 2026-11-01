/// App-wide settings. The server can be changed at build time, e.g. for a
/// test server: `flutter run --dart-define=EVENTIX_BASE_URL=https://staging.example/`
class AppConfig {
  AppConfig._();

  static const String baseUrl = String.fromEnvironment(
    'EVENTIX_BASE_URL',
    defaultValue: 'https://eventix.om/',
  );

  /// How long one request may take before the phone treats itself as offline.
  static const Duration requestTimeout = Duration(seconds: 12);

  /// While check-ins are waiting, how often an upload is tried again.
  static const Duration syncInterval = Duration(seconds: 20);

  /// While scanning and online, how often the guest list is re-downloaded so
  /// this phone learns about check-ins made by other scanners.
  static const Duration listRefreshInterval = Duration(seconds: 60);

  /// The server accepts at most 100 check-ins per upload.
  static const int uploadBatchSize = 100;

  /// The same code seen again within this time is the camera repeating
  /// itself, not a new scan.
  static const Duration sameCodeCooldown = Duration(seconds: 4);

  /// How long a scan result stays on screen.
  static const Duration resultOnScreen = Duration(milliseconds: 2600);
}
