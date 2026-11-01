import 'package:drift/drift.dart' show Value;
import 'package:uuid/uuid.dart';

import '../core/qr.dart';
import '../data/db/database.dart';
import '../data/session_store.dart';

/// The door's answer to one scan. Decided on the phone from the downloaded
/// list and this phone's own check-ins, so it never waits on the network.
sealed class ScanOutcome {
  const ScanOutcome();
}

/// Let them in. [rsvp] is shown as a warning unless it is "Attending".
class CheckedIn extends ScanOutcome {
  const CheckedIn(this.guest);
  final GuestRow guest;
}

/// Already in. [timeLabel] is the server's time (event zone) when known,
/// otherwise this phone's scan time. [onThisPhone]: scanned here before.
class AlreadyCheckedIn extends ScanOutcome {
  const AlreadyCheckedIn(this.guest,
      {required this.timeLabel, this.scannedHereAt, required this.onThisPhone});
  final GuestRow guest;
  final String? timeLabel;
  final DateTime? scannedHereAt;
  final bool onThisPhone;
}

/// An Eventix invitation for another event this phone has a list for.
class WrongEvent extends ScanOutcome {
  const WrongEvent(this.event);
  final EventRow event;
}

/// An Eventix invitation that is not on this event's list.
class NotOnList extends ScanOutcome {
  const NotOnList();
}

/// Not an Eventix invitation at all.
class NotAnInvitation extends ScanOutcome {
  const NotAnInvitation();
}

class CheckinService {
  CheckinService(this._db, {Uuid? uuid, DateTime Function()? clock})
      : _uuid = uuid ?? const Uuid(),
        _now = clock ?? DateTime.now;

  final AppDatabase _db;
  final Uuid _uuid;
  final DateTime Function() _now;

  /// A QR read by the camera.
  Future<ScanOutcome> scan(Session who, int eventId, String raw) async {
    final code = parseScannedCode(raw);
    if (code is! EventixCode) return const NotAnInvitation();
    final guest = await _db.guestByToken(eventId, code.tokenSha256);
    if (guest == null) {
      final other = await _db.otherEventWithToken(eventId, code.tokenSha256);
      return other != null ? WrongEvent(other) : const NotOnList();
    }
    return checkIn(who, guest);
  }

  /// Checks the guest in on this phone (also used by search). The decision
  /// and the outbox row are one transaction: the first scan of a guest on this
  /// phone is the one kept and uploaded; later scans here only report it.
  Future<ScanOutcome> checkIn(Session who, GuestRow guest) {
    return _db.transaction(() async {
      final mine = await _db.checkinFor(guest.eventId, guest.id);
      if (mine != null) {
        final undoneOnWeb = mine.state != CheckinState.pending &&
            mine.state != CheckinState.rejected &&
            !guest.serverCheckedIn &&
            await _listNewerThan(guest.eventId, mine.syncedAt);
        if (undoneOnWeb || mine.state == CheckinState.rejected) {
          await _db.deleteCheckin(mine.clientId); // a new check-in replaces it
        } else {
          return AlreadyCheckedIn(guest,
              timeLabel: mine.serverLabel,
              scannedHereAt: mine.scannedAt,
              onThisPhone: mine.state != CheckinState.conflict);
        }
      } else if (guest.serverCheckedIn) {
        return AlreadyCheckedIn(guest,
            timeLabel: guest.serverCheckedInLabel, onThisPhone: false);
      }

      await _db.insertCheckin(CheckinsCompanion.insert(
        clientId: _uuid.v4(),
        userId: who.userId,
        username: who.username,
        eventId: guest.eventId,
        guestId: guest.id,
        guestNameEn: guest.nameEn,
        guestNameAr: guest.nameAr,
        scannedAt: _now(),
        state: CheckinState.pending,
        attempts: const Value(0),
      ));
      return CheckedIn(guest);
    });
  }

  /// Whether the list was downloaded after [time] (so it reflects an undo
  /// an admin made on the web after this phone's check-in was confirmed).
  Future<bool> _listNewerThan(int eventId, DateTime? time) async {
    if (time == null) return false;
    final event = await _db.watchEvent(eventId).first;
    final at = event?.listDownloadedAt;
    return at != null && at.isAfter(time);
  }
}
