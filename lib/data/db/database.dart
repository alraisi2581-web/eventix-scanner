import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import '../api/api_models.dart';

part 'database.g.dart';

/// The events this user may scan for, as last downloaded.
@DataClassName('EventRow')
class Events extends Table {
  IntColumn get id => integer()();
  IntColumn get userId => integer()();
  TextColumn get titleEn => text()();
  TextColumn get titleAr => text()();
  TextColumn get venueEn => text()();
  TextColumn get venueAr => text()();
  TextColumn get startsLabel => text()();
  TextColumn get timezone => text()();
  IntColumn get guestCount => integer()();
  IntColumn get checkedInCount => integer()();

  /// When this event's guest list was last saved on the phone; null = never.
  DateTimeColumn get listDownloadedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// A downloaded guest list. QR tokens are stored only as SHA-256.
@DataClassName('GuestRow')
@TableIndex(name: 'guests_event_token', columns: {#eventId, #tokenSha256})
class Guests extends Table {
  IntColumn get id => integer()();
  IntColumn get eventId => integer()();
  TextColumn get nameEn => text()();
  TextColumn get nameAr => text()();
  TextColumn get rsvp => text()();
  TextColumn get tableNumber => text().nullable()();
  TextColumn get tokenSha256 => text()();

  /// Checked in on the server as of the last download (by anyone).
  BoolColumn get serverCheckedIn => boolean()();
  TextColumn get serverCheckedInLabel => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

enum CheckinState {
  /// Made on this phone, not yet confirmed by the server.
  pending,

  /// The server checked the guest in with this check-in.
  confirmed,

  /// The server already had the guest checked in from another scanner.
  conflict,

  /// The server refused it (guest removed, no access…).
  rejected,
}

/// The outbox: every check-in made on this phone. A row is written in the same
/// transaction as the scan decision, so a check-in survives the app being
/// killed or the phone dying, and is uploaded until the server has answered it.
/// One row per guest per event: the first scan on this phone is the one kept.
@DataClassName('CheckinRow')
class Checkins extends Table {
  /// UUID v4 made on the phone; the server's idempotency key.
  TextColumn get clientId => text()();
  IntColumn get userId => integer()();
  TextColumn get username => text()();
  IntColumn get eventId => integer()();
  IntColumn get guestId => integer()();
  TextColumn get guestNameEn => text()();
  TextColumn get guestNameAr => text()();
  DateTimeColumn get scannedAt => dateTime()();
  TextColumn get state => textEnum<CheckinState>()();
  IntColumn get attempts => integer().withDefault(const Constant(0))();
  DateTimeColumn get syncedAt => dateTime().nullable()();

  /// The check-in time the server recorded, in the event's zone ("7:42 pm").
  TextColumn get serverLabel => text().nullable()();
  TextColumn get message => text().nullable()();

  /// False until door staff have seen a conflict or refusal.
  BoolColumn get seen => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {clientId};

  @override
  List<Set<Column>> get uniqueKeys => [
        {eventId, guestId},
      ];
}

/// What one guest looks like at the door right now: the server's state from
/// the last download, overlaid with this phone's own check-in, if any.
class GuestAtDoor {
  const GuestAtDoor(this.guest, this.checkin);
  final GuestRow guest;
  final CheckinRow? checkin;

  bool get checkedIn =>
      guest.serverCheckedIn ||
      (checkin != null && checkin!.state != CheckinState.rejected);
}

@DriftDatabase(tables: [Events, Guests, Checkins])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(driftDatabase(name: 'eventix_scanner'));
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 1;

  // ── Events ────────────────────────────────────────────────────────────────

  Stream<List<EventRow>> watchEvents(int userId) => (select(events)
        ..where((e) => e.userId.equals(userId))
        ..orderBy([(e) => OrderingTerm.desc(e.id)]))
      .watch();

  Stream<EventRow?> watchEvent(int id) =>
      (select(events)..where((e) => e.id.equals(id))).watchSingleOrNull();

  /// Saves the server's event list for this user. Events no longer listed are
  /// removed with their guest lists (access was taken away).
  Future<void> replaceEvents(int userId, List<ApiEvent> list) =>
      transaction(() async {
        final keep = list.map((e) => e.id).toSet();
        final gone = await (select(events)
              ..where((e) => e.userId.equals(userId) & e.id.isNotIn(keep)))
            .map((e) => e.id)
            .get();
        await (delete(guests)..where((g) => g.eventId.isIn(gone))).go();
        await (delete(events)..where((e) => e.id.isIn(gone))).go();
        for (final e in list) {
          await into(events).insert(
            _eventCompanion(userId, e),
            onConflict: DoUpdate((_) => _eventCompanion(userId, e)),
          );
        }
      });

  EventsCompanion _eventCompanion(int userId, ApiEvent e) => EventsCompanion(
        id: Value(e.id),
        userId: Value(userId),
        titleEn: Value(e.titleEn),
        titleAr: Value(e.titleAr),
        venueEn: Value(e.venueEn),
        venueAr: Value(e.venueAr),
        startsLabel: Value(e.startsLabel),
        timezone: Value(e.timezone),
        guestCount: Value(e.guestCount),
        checkedInCount: Value(e.checkedInCount),
      );

  // ── Guest lists ───────────────────────────────────────────────────────────

  /// Replaces an event's guest list in one transaction; the outbox is untouched.
  /// [requestedAt]: when the download was asked for — the list shows the server
  /// as of then, so only check-ins confirmed before it are reflected in it.
  Future<void> replaceGuestList(int userId, GuestList list,
          {required DateTime requestedAt}) =>
      transaction(() async {
        final eid = list.event.id;
        await (delete(guests)..where((g) => g.eventId.equals(eid))).go();
        await batch((b) {
          b.insertAll(
            guests,
            list.guests.map((g) => GuestsCompanion.insert(
                  id: Value(g.id),
                  eventId: eid,
                  nameEn: g.nameEn,
                  nameAr: g.nameAr,
                  rsvp: g.rsvp,
                  tableNumber: Value(g.tableNumber),
                  tokenSha256: g.tokenSha256,
                  serverCheckedIn: g.checkedIn,
                  serverCheckedInLabel: Value(g.checkedInLabel),
                )),
          );
        });
        final row = _eventCompanion(userId, list.event)
            .copyWith(listDownloadedAt: Value(requestedAt));
        await into(events).insert(row, onConflict: DoUpdate((_) => row));
      });

  Future<GuestRow?> guestByToken(int eventId, String sha) => (select(guests)
        ..where((g) => g.eventId.equals(eventId) & g.tokenSha256.equals(sha)))
      .getSingleOrNull();

  /// The guest with this token on any other downloaded list (wrong-event scan).
  Future<EventRow?> otherEventWithToken(int eventId, String sha) {
    final q = select(events).join([
      innerJoin(guests, guests.eventId.equalsExp(events.id)),
    ])
      ..where(guests.tokenSha256.equals(sha) & events.id.equals(eventId).not())
      ..limit(1);
    return q.map((r) => r.readTable(events)).getSingleOrNull();
  }

  Future<GuestRow?> guestById(int id) =>
      (select(guests)..where((g) => g.id.equals(id))).getSingleOrNull();

  /// Name / Arabic name / table search for check-in by hand.
  Future<List<GuestAtDoor>> searchGuests(int eventId, String query) {
    final like = '%${query.replaceAll('%', r'\%').replaceAll('_', r'\_')}%';
    final q = select(guests).join([
      leftOuterJoin(checkins, checkins.guestId.equalsExp(guests.id)),
    ])
      ..where(guests.eventId.equals(eventId) &
          (guests.nameEn.like(like) |
              guests.nameAr.like(like) |
              guests.tableNumber.equals(query.trim())))
      ..orderBy([OrderingTerm.asc(guests.nameEn)])
      ..limit(50);
    return q
        .map((r) => GuestAtDoor(r.readTable(guests), r.readTableOrNull(checkins)))
        .get();
  }

  /// Guests on the list and how many are in (server or this phone).
  Stream<({int total, int checkedIn})> watchCounts(int eventId) {
    final total = guests.id.count();
    final inCount = guests.id.count(
        filter: guests.serverCheckedIn.equals(true) |
            (checkins.clientId.isNotNull() &
                checkins.state.equalsValue(CheckinState.rejected).not()));
    final q = selectOnly(guests).join([
      leftOuterJoin(checkins, checkins.guestId.equalsExp(guests.id)),
    ])
      ..addColumns([total, inCount])
      ..where(guests.eventId.equals(eventId));
    return q.watchSingle().map((r) =>
        (total: r.read(total) ?? 0, checkedIn: r.read(inCount) ?? 0));
  }

  // ── Check-ins (the outbox) ────────────────────────────────────────────────

  Future<CheckinRow?> checkinFor(int eventId, int guestId) => (select(checkins)
        ..where((c) => c.eventId.equals(eventId) & c.guestId.equals(guestId)))
      .getSingleOrNull();

  Future<void> insertCheckin(CheckinsCompanion row) =>
      into(checkins).insert(row);

  Future<void> deleteCheckin(String clientId) =>
      (delete(checkins)..where((c) => c.clientId.equals(clientId))).go();

  /// Oldest first, so the server sees them in the order they were made.
  Future<List<CheckinRow>> pendingCheckins(int userId, int limit) =>
      (select(checkins)
            ..where((c) =>
                c.userId.equals(userId) &
                c.state.equalsValue(CheckinState.pending))
            ..orderBy([(c) => OrderingTerm.asc(c.scannedAt)])
            ..limit(limit))
          .get();

  Stream<int> watchPendingCount(int userId) {
    final n = checkins.clientId.count();
    final q = selectOnly(checkins)
      ..addColumns([n])
      ..where(checkins.userId.equals(userId) &
          checkins.state.equalsValue(CheckinState.pending));
    return q.watchSingle().map((r) => r.read(n) ?? 0);
  }

  /// Pending check-ins by other users (signed out before they uploaded).
  Future<List<({String username, int count})>> pendingByOtherUsers(
      int userId) async {
    final n = checkins.clientId.count();
    final q = selectOnly(checkins)
      ..addColumns([checkins.username, n])
      ..where(checkins.userId.equals(userId).not() &
          checkins.state.equalsValue(CheckinState.pending))
      ..groupBy([checkins.username]);
    final rows = await q.get();
    return rows
        .map((r) => (username: r.read(checkins.username)!, count: r.read(n) ?? 0))
        .toList();
  }

  Future<void> markAttempt(Iterable<String> clientIds) => customUpdate(
        'UPDATE checkins SET attempts = attempts + 1 WHERE client_id IN '
        '(${List.filled(clientIds.length, '?').join(',')})',
        variables: [for (final id in clientIds) Variable.withString(id)],
        updates: {checkins},
      );

  /// Records the server's answer for one check-in, and what it says about the
  /// guest (checked in, and when) so the next scan here knows it.
  Future<void> applyResult(CheckinResult r) => transaction(() async {
        final row = await (select(checkins)
              ..where((c) => c.clientId.equals(r.clientId)))
            .getSingleOrNull();
        if (row == null || row.state != CheckinState.pending) return;
        final state = switch (r.status) {
          'checked_in' => CheckinState.confirmed,
          'already_checked_in' => CheckinState.conflict,
          _ => CheckinState.rejected,
        };
        await (update(checkins)..where((c) => c.clientId.equals(r.clientId)))
            .write(CheckinsCompanion(
          state: Value(state),
          syncedAt: Value(DateTime.now()),
          serverLabel: Value(r.checkedInLabel),
          message: Value(r.message),
          seen: Value(state == CheckinState.confirmed),
        ));
        if (state != CheckinState.rejected) {
          await (update(guests)..where((g) => g.id.equals(row.guestId))).write(
              GuestsCompanion(
                  serverCheckedIn: const Value(true),
                  serverCheckedInLabel: Value(r.checkedInLabel)));
        }
      });

  Stream<List<CheckinRow>> watchCheckins(int eventId) => (select(checkins)
        ..where((c) => c.eventId.equals(eventId))
        ..orderBy([(c) => OrderingTerm.desc(c.scannedAt)]))
      .watch();

  /// Conflicts and refusals door staff haven't acknowledged yet.
  Stream<List<CheckinRow>> watchUnseen(int eventId) => (select(checkins)
        ..where((c) => c.eventId.equals(eventId) & c.seen.equals(false))
        ..orderBy([(c) => OrderingTerm.asc(c.syncedAt)]))
      .watch();

  Future<void> markSeen(String clientId) =>
      (update(checkins)..where((c) => c.clientId.equals(clientId)))
          .write(const CheckinsCompanion(seen: Value(true)));

  // ── Sign-out ──────────────────────────────────────────────────────────────

  /// Removes downloaded guest lists (names) and finished check-ins. Pending
  /// check-ins stay, to be uploaded when that user signs in again.
  Future<void> clearAfterSignOut() => transaction(() async {
        await delete(guests).go();
        await delete(events).go();
        await (delete(checkins)
              ..where((c) => c.state.equalsValue(CheckinState.pending).not()))
            .go();
      });
}
