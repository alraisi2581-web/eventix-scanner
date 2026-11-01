import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'data/api/eventix_api.dart';
import 'data/db/database.dart';
import 'data/session_store.dart';
import 'services/checkin_service.dart';
import 'services/sync_service.dart';

/// Overridden in main() with the real database (and in tests with one in memory).
final databaseProvider =
    Provider<AppDatabase>((ref) => throw UnimplementedError('databaseProvider'));
final apiProvider = Provider<EventixApi>((ref) => EventixApi());
final sessionStoreProvider = Provider<SessionStore>((ref) => SessionStore());

// ── Sign-in ─────────────────────────────────────────────────────────────────

/// The signed-in user, or null. Works offline: a saved token is trusted until
/// the server refuses it.
class AuthController extends AsyncNotifier<Session?> {
  @override
  Future<Session?> build() => ref.read(sessionStoreProvider).read();

  Session? get current => state.valueOrNull;

  /// Throws [ApiException] for the sign-in screen to explain.
  Future<void> signIn(String username, String password) async {
    final result = await ref.read(apiProvider).login(
          username: username,
          password: password,
          deviceName: _deviceName(),
        );
    final session = Session(
      token: result.token,
      userId: result.user.id,
      username: result.user.username,
      role: result.user.role,
      expiresAt: result.expiresAt,
    );
    final db = ref.read(databaseProvider);
    final previous = await ref.read(sessionStoreProvider).lastUsername();
    if (previous != null && previous != session.username) {
      await db.clearAfterSignOut(); // another person's lists don't stay on the phone
    }
    await ref.read(sessionStoreProvider).write(session);
    ref.invalidate(lastUsernameProvider);
    state = AsyncData(session);
  }

  /// Signs out. Pending check-ins stay on the phone and upload when this user
  /// signs in again; downloaded guest lists are removed.
  Future<void> signOut() async {
    final s = current;
    if (s != null) unawaited(ref.read(apiProvider).logout(s.token));
    await ref.read(sessionStoreProvider).clear();
    await ref.read(databaseProvider).clearAfterSignOut();
    ref.invalidate(lastUsernameProvider);
    state = const AsyncData(null);
  }

  /// The server refused the token: back to the sign-in screen, keeping
  /// everything on the phone so uploads resume after signing in again.
  Future<void> sessionEnded() async {
    await ref.read(sessionStoreProvider).clear();
    state = const AsyncData(null);
  }

  /// Shown to admins next to the token ("Android 14 …"), so a lost phone can
  /// be told apart. No hardware ids.
  static String _deviceName() {
    final os = Platform.isIOS
        ? 'iOS'
        : (Platform.isAndroid ? 'Android' : Platform.operatingSystem);
    final name = '$os ${Platform.operatingSystemVersion}';
    return name.length > 60 ? name.substring(0, 60) : name;
  }
}

final authProvider =
    AsyncNotifierProvider<AuthController, Session?>(AuthController.new);

final lastUsernameProvider = FutureProvider<String?>(
    (ref) => ref.read(sessionStoreProvider).lastUsername());

// ── Language ────────────────────────────────────────────────────────────────

class LanguageController extends Notifier<Locale?> {
  @override
  Locale? build() {
    ref.read(sessionStoreProvider).language().then((code) {
      if (code != null) state = Locale(code);
    });
    return null; // the phone's language until a choice is loaded
  }

  Future<void> set(String code) async {
    state = Locale(code);
    await ref.read(sessionStoreProvider).setLanguage(code);
  }
}

final languageProvider =
    NotifierProvider<LanguageController, Locale?>(LanguageController.new);

// ── Check-ins and sync ──────────────────────────────────────────────────────

final checkinServiceProvider =
    Provider<CheckinService>((ref) => CheckinService(ref.watch(databaseProvider)));

class SyncController extends Notifier<SyncStatus> {
  late final SyncService service;
  StreamSubscription<List<ConnectivityResult>>? _net;

  @override
  SyncStatus build() {
    service = SyncService(
      db: ref.watch(databaseProvider),
      api: ref.watch(apiProvider),
      session: () => ref.read(authProvider).valueOrNull,
      onSignedOut: () => ref.read(authProvider.notifier).sessionEnded(),
      onStatus: (s) => state = s,
    );
    service.start();
    // a network change is only a hint; a request that works is the real test
    _net = Connectivity().onConnectivityChanged.listen((r) {
      if (!r.contains(ConnectivityResult.none)) service.kick(refreshList: true);
    });
    ref.onDispose(() {
      service.stop();
      _net?.cancel();
    });
    // signing in again resumes uploads at once
    ref.listen(authProvider, (prev, next) {
      if (next.valueOrNull != null) service.kick(refreshList: true);
    });
    return service.status;
  }

  void kick({bool refreshList = false}) => service.kick(refreshList: refreshList);
  Future<void> syncNow({bool refreshList = false}) =>
      service.syncNow(refreshList: refreshList);
  set activeEventId(int? id) => service.activeEventId = id;
}

final syncProvider =
    NotifierProvider<SyncController, SyncStatus>(SyncController.new);

final pendingCountProvider = StreamProvider<int>((ref) {
  final s = ref.watch(authProvider).valueOrNull;
  if (s == null) return Stream.value(0);
  return ref.watch(databaseProvider).watchPendingCount(s.userId);
});

// ── Events and guest lists ──────────────────────────────────────────────────

/// The event list from the phone, refreshed from the server when online.
final eventsProvider = StreamProvider<List<EventRow>>((ref) {
  final s = ref.watch(authProvider).valueOrNull;
  if (s == null) return Stream.value(const []);
  return ref.watch(databaseProvider).watchEvents(s.userId);
});

/// Downloads the event list. Throws [ApiException] (the screen shows it and
/// keeps the saved list).
Future<void> refreshEvents(WidgetRef ref) async {
  final s = ref.read(authProvider).valueOrNull;
  if (s == null) return;
  try {
    final list = await ref.read(apiProvider).events(s.token);
    await ref.read(databaseProvider).replaceEvents(s.userId, list);
  } on UnauthorizedException {
    await ref.read(authProvider.notifier).sessionEnded();
    rethrow;
  }
}

/// Downloads one event's guest list to the phone.
Future<void> downloadGuestList(WidgetRef ref, int eventId) async {
  final s = ref.read(authProvider).valueOrNull;
  if (s == null) return;
  try {
    final requestedAt = DateTime.now();
    final list = await ref.read(apiProvider).guests(s.token, eventId);
    await ref
        .read(databaseProvider)
        .replaceGuestList(s.userId, list, requestedAt: requestedAt);
  } on UnauthorizedException {
    await ref.read(authProvider.notifier).sessionEnded();
    rethrow;
  }
}

final eventProvider = StreamProvider.family<EventRow?, int>(
    (ref, id) => ref.watch(databaseProvider).watchEvent(id));

final countsProvider =
    StreamProvider.family<({int total, int checkedIn}), int>(
        (ref, id) => ref.watch(databaseProvider).watchCounts(id));

final activityProvider = StreamProvider.family<List<CheckinRow>, int>(
    (ref, id) => ref.watch(databaseProvider).watchCheckins(id));

final unseenProvider = StreamProvider.family<List<CheckinRow>, int>(
    (ref, id) => ref.watch(databaseProvider).watchUnseen(id));
