import 'dart:async';
import 'dart:math';

import '../core/config.dart';
import '../data/api/eventix_api.dart';
import '../data/db/database.dart';
import '../data/session_store.dart';

/// Where uploading stands, for the status chip on the scan screen.
class SyncStatus {
  const SyncStatus({
    this.online,
    this.syncing = false,
    this.lastSyncAt,
    this.needsSignIn = false,
  });

  /// null until the first request: unknown.
  final bool? online;
  final bool syncing;
  final DateTime? lastSyncAt;

  /// The server refused the token: uploads wait until the user signs in again.
  final bool needsSignIn;

  SyncStatus copyWith(
          {bool? online,
          bool? syncing,
          DateTime? lastSyncAt,
          bool? needsSignIn}) =>
      SyncStatus(
        online: online ?? this.online,
        syncing: syncing ?? this.syncing,
        lastSyncAt: lastSyncAt ?? this.lastSyncAt,
        needsSignIn: needsSignIn ?? this.needsSignIn,
      );
}

/// Uploads the outbox and refreshes the open guest list.
///
/// - Every check-in is uploaded until the server has answered it. A request
///   that fails (offline, timeout, server error) leaves the rows pending, and
///   they are resent with the same client ids, so a resend after a lost reply
///   is recognised by the server and never counted twice.
/// - Answers are applied one by one: checked_in → confirmed; already_checked_in
///   → conflict (someone reached the server first; door staff are told).
/// - Runs when a check-in is made, when the network comes back, when the app
///   returns to the foreground, and on a timer; failures back off up to 60 s.
class SyncService {
  SyncService({
    required AppDatabase db,
    required EventixApi api,
    required Session? Function() session,
    required void Function() onSignedOut,
    required void Function(SyncStatus) onStatus,
  })  : _db = db,
        _api = api,
        _session = session,
        _onSignedOut = onSignedOut,
        _onStatus = onStatus;

  final AppDatabase _db;
  final EventixApi _api;
  final Session? Function() _session;
  final void Function() _onSignedOut;
  final void Function(SyncStatus) _onStatus;

  SyncStatus _status = const SyncStatus();
  SyncStatus get status => _status;

  Timer? _timer;
  Timer? _retry;
  int _failures = 0;
  Future<void>? _running;
  bool _again = false;
  DateTime? _listRefreshedAt;

  /// The event being scanned: its list is refreshed while online.
  int? activeEventId;

  void start() {
    _timer ??= Timer.periodic(AppConfig.syncInterval, (_) => kick());
  }

  void stop() {
    _timer?.cancel();
    _retry?.cancel();
    _timer = null;
    _retry = null;
  }

  /// Run soon. Calls while a run is going make it run once more after.
  void kick({bool refreshList = false}) {
    if (refreshList) _listRefreshedAt = null;
    if (_running != null) {
      _again = true;
      return;
    }
    _running = _run().whenComplete(() {
      _running = null;
      if (_again) {
        _again = false;
        kick();
      }
    });
  }

  /// For tests and pull-to-refresh: completes when the current run is done.
  Future<void> syncNow({bool refreshList = false}) async {
    kick(refreshList: refreshList);
    while (_running != null) {
      await _running;
    }
  }

  Future<void> _run() async {
    final session = _session();
    if (session == null) return;
    _set(_status.copyWith(syncing: true, needsSignIn: false));
    try {
      await _upload(session);
      await _maybeRefreshList(session);
      _failures = 0;
      _retry?.cancel();
      _set(_status.copyWith(online: true, lastSyncAt: DateTime.now()));
    } on UnauthorizedException {
      _set(_status.copyWith(needsSignIn: true));
      _onSignedOut();
    } on ApiException {
      _set(_status.copyWith(online: false));
      _scheduleRetry();
    } finally {
      _set(_status.copyWith(syncing: false));
    }
  }

  Future<void> _upload(Session session) async {
    while (true) {
      final batch =
          await _db.pendingCheckins(session.userId, AppConfig.uploadBatchSize);
      if (batch.isEmpty) return;
      await _db.markAttempt(batch.map((c) => c.clientId));
      final results = await _api.uploadCheckins(
        session.token,
        [
          for (final c in batch)
            CheckinUpload(
                clientId: c.clientId, guestId: c.guestId, scannedAt: c.scannedAt),
        ],
      );
      for (final r in results) {
        await _db.applyResult(r);
      }
      // a short batch was the last; an answer missing an item must not loop forever
      if (batch.length < AppConfig.uploadBatchSize || results.isEmpty) return;
    }
  }

  Future<void> _maybeRefreshList(Session session) async {
    final eid = activeEventId;
    if (eid == null) return;
    final last = _listRefreshedAt;
    if (last != null &&
        DateTime.now().difference(last) < AppConfig.listRefreshInterval) {
      return;
    }
    // only after the upload: the downloaded list then includes this phone's check-ins
    final requestedAt = DateTime.now();
    final list = await _api.guests(session.token, eid);
    await _db.replaceGuestList(session.userId, list, requestedAt: requestedAt);
    _listRefreshedAt = DateTime.now();
  }

  void _scheduleRetry() {
    _failures++;
    final seconds = min(60, 5 * pow(2, _failures - 1).toInt());
    _retry?.cancel();
    _retry = Timer(Duration(seconds: seconds), kick);
  }

  void _set(SyncStatus s) {
    _status = s;
    _onStatus(s);
  }
}
