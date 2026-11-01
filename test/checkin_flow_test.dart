import 'package:eventix_scanner/data/db/database.dart';
import 'package:eventix_scanner/data/session_store.dart';
import 'package:eventix_scanner/services/checkin_service.dart';
import 'package:eventix_scanner/services/sync_service.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fakes.dart';

/// One phone at the door: its own database, check-in service and sync engine,
/// talking to a shared [FakeEventixServer].
class Phone {
  Phone(this.server, this.session) : db = memoryDb() {
    checkins = CheckinService(db);
    sync = SyncService(
      db: db,
      api: server.apiFor(),
      session: () => signedIn ? session : null,
      onSignedOut: () => signedOut++,
      onStatus: (s) => status = s,
    )..activeEventId = server.eventId;
  }

  final FakeEventixServer server;
  final Session session;
  final AppDatabase db;
  late final CheckinService checkins;
  late final SyncService sync;
  SyncStatus status = const SyncStatus();
  bool signedIn = true;
  int signedOut = 0;

  Future<void> download() async {
    final at = DateTime.now();
    final list = await server.apiFor().guests(session.token, server.eventId);
    await db.replaceGuestList(session.userId, list, requestedAt: at);
  }

  Future<ScanOutcome> scan(int guestId) =>
      checkins.scan(session, server.eventId, server.qrFor(guestId));

  Future<CheckinRow?> rowFor(int guestId) =>
      db.checkinFor(server.eventId, guestId);

  Future<int> pending() => db.watchPendingCount(session.userId).first;
}

void main() {
  late FakeEventixServer server;
  late Phone a;
  late Phone b;

  setUp(() async {
    server = FakeEventixServer();
    a = Phone(server, sessionFor(1, 'token-a', username: 'scanner1'));
    b = Phone(server, sessionFor(2, 'token-b', username: 'scanner2'));
    await a.download();
    await b.download();
  });

  tearDown(() async {
    a.sync.stop();
    b.sync.stop();
    await a.db.close();
    await b.db.close();
  });

  group('scanning on the phone', () {
    test('a guest on the list is checked in at once, with no network call', () async {
      server.offline = true;
      final out = await a.scan(1);
      expect(out, isA<CheckedIn>());
      expect((await a.rowFor(1))!.state, CheckinState.pending);
      expect(server.uploads, 0);
    });

    test('the second scan on the same phone keeps the first one', () async {
      await a.scan(1);
      final first = await a.rowFor(1);
      final again = await a.scan(1);
      expect(again, isA<AlreadyCheckedIn>());
      expect((again as AlreadyCheckedIn).onThisPhone, isTrue);
      expect((await a.rowFor(1))!.clientId, first!.clientId);
      expect(await a.pending(), 1);
    });

    test('a QR not on this list, and a code that is not an invitation', () async {
      expect(await a.checkins.scan(a.session, server.eventId,
          'https://eventix.om/qr/scan.php?t=unknowntoken123'), isA<NotOnList>());
      expect(await a.checkins.scan(a.session, server.eventId,
          'https://example.com/'), isA<NotAnInvitation>());
    });

    test('a guest already checked in on the server (per the list) is reported', () async {
      server.guests[2]!['checked_in'] = true;
      server.guests[2]!['label'] = '6:55 pm';
      await a.download();
      final out = await a.scan(2);
      expect(out, isA<AlreadyCheckedIn>());
      expect((out as AlreadyCheckedIn).timeLabel, '6:55 pm');
      expect(out.onThisPhone, isFalse);
      expect(await a.pending(), 0);
    });

    test('the RSVP travels with the result (Not Attending is warned about)', () async {
      final out = await a.scan(5);
      expect((out as CheckedIn).guest.rsvp, 'Not Attending');
    });
  });

  group('uploading', () {
    test('online: the check-in reaches the server and is confirmed', () async {
      await a.scan(1);
      await a.sync.syncNow();
      expect((await a.rowFor(1))!.state, CheckinState.confirmed);
      expect(server.guests[1]!['checked_in'], isTrue);
      expect(a.status.online, isTrue);
      expect(await a.pending(), 0);
    });

    test('offline: check-ins wait, nothing is lost, and all go up later', () async {
      server.offline = true;
      for (final g in [1, 2, 3]) {
        await a.scan(g);
      }
      await a.sync.syncNow();
      expect(a.status.online, isFalse);
      expect(await a.pending(), 3);

      server.offline = false;
      await a.sync.syncNow();
      expect(await a.pending(), 0);
      expect(server.applied, hasLength(3));
      for (final g in [1, 2, 3]) {
        expect((await a.rowFor(g))!.state, CheckinState.confirmed);
      }
    });

    test('an answer lost on the way back: the resend is not counted twice', () async {
      await a.scan(1);
      server.dropNextAnswer = true; // the server applies it, the phone never hears
      await a.sync.syncNow();
      expect(await a.pending(), 1);
      expect(server.applied, hasLength(1));

      await a.sync.syncNow(); // same client_id again
      expect(await a.pending(), 0);
      expect(server.applied, hasLength(1), reason: 'applied once only');
      expect((await a.rowFor(1))!.state, CheckinState.confirmed);
    });

    test('a refused token stops uploads and keeps the queue for after sign-in', () async {
      await a.scan(1);
      server.validTokens.remove('token-a');
      await a.sync.syncNow();
      expect(a.signedOut, 1);
      expect(a.status.needsSignIn, isTrue);
      expect(await a.pending(), 1);

      server.validTokens.add('token-a'); // signed in again
      await a.sync.syncNow();
      expect(await a.pending(), 0);
    });

    test('more than one upload batch (100) goes up in order', () async {
      final big = FakeEventixServer(guests: 230);
      final p = Phone(big, sessionFor(1, 'token-a'));
      await p.download();
      big.offline = true;
      for (var g = 1; g <= 230; g++) {
        await p.scan(g);
      }
      big.offline = false;
      await p.sync.syncNow();
      expect(await p.pending(), 0);
      expect(big.uploads, 3);
      expect(big.applied, hasLength(230));
      p.sync.stop();
      await p.db.close();
    });
  });

  group('two phones, one guest', () {
    test('the first to reach the server wins; the other is told "already checked in"', () async {
      server.offline = true;
      await b.scan(3); // B scanned first, but offline
      await a.scan(3); // A scanned second
      server.offline = false;

      await a.sync.syncNow(); // A reaches the server first
      await b.sync.syncNow();

      expect((await a.rowFor(3))!.state, CheckinState.confirmed);
      final lost = (await b.rowFor(3))!;
      expect(lost.state, CheckinState.conflict);
      expect(lost.serverLabel, server.guests[3]!['label']);
      expect(lost.seen, isFalse, reason: 'B is shown the conflict');
      expect(await b.db.watchUnseen(server.eventId).first, hasLength(1));
      expect(server.applied, hasLength(1));
    });

    test('B\'s offline scan stays recorded on B even after losing', () async {
      server.offline = true;
      await b.scan(3);
      final scannedAt = (await b.rowFor(3))!.scannedAt;
      server.offline = false;
      await a.scan(3);
      await a.sync.syncNow();
      await b.sync.syncNow();
      final row = (await b.rowFor(3))!;
      expect(row.scannedAt, scannedAt);
      final again = await b.scan(3);
      expect(again, isA<AlreadyCheckedIn>());
      expect((again as AlreadyCheckedIn).timeLabel, server.guests[3]!['label']);
    });

    test('a refreshed list tells B about A\'s check-in before B scans', () async {
      await a.scan(4);
      await a.sync.syncNow();
      await b.sync.syncNow(refreshList: true);
      final out = await b.scan(4);
      expect(out, isA<AlreadyCheckedIn>());
      expect(await b.pending(), 0);
    });
  });

  test('a check-in undone by an admin on the web can be scanned again', () async {
    await a.scan(1);
    await a.sync.syncNow();
    server.undoOnWeb(1);
    await Future<void>.delayed(const Duration(milliseconds: 5));
    await a.sync.syncNow(refreshList: true);
    expect(await a.scan(1), isA<CheckedIn>());
    await a.sync.syncNow();
    expect(server.applied, hasLength(2));
  });

  test('signing out removes guest lists but keeps check-ins not yet uploaded', () async {
    server.offline = true;
    await a.scan(1);
    await a.db.clearAfterSignOut();
    expect(await a.db.guestById(1), isNull);
    expect(await a.pending(), 1);
  });
}
