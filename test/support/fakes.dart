import 'dart:convert';
import 'dart:ffi';
import 'dart:io';

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:eventix_scanner/core/qr.dart';
import 'package:eventix_scanner/data/api/eventix_api.dart';
import 'package:eventix_scanner/data/db/database.dart';
import 'package:eventix_scanner/data/session_store.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:sqlite3/open.dart';

/// On Windows the tests need a sqlite3.dll: set SQLITE3_DLL to one (Python
/// ships one in its DLLs folder). macOS and Linux have SQLite built in.
AppDatabase memoryDb() {
  final dll = Platform.environment['SQLITE3_DLL'];
  if (Platform.isWindows && dll != null) {
    open.overrideFor(OperatingSystem.windows, () => DynamicLibrary.open(dll));
  }
  // the two-phone tests open one database per phone, on separate executors
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  return AppDatabase.forTesting(NativeDatabase.memory());
}

Session sessionFor(int userId, String token, {String username = 'scanner'}) =>
    Session(
      token: token,
      userId: userId,
      username: username,
      role: 'scanner',
      expiresAt: DateTime.now().add(const Duration(days: 14)),
    );

/// A stand-in for the Eventix server that follows its rules (see
/// app/includes/scanner_api.php): the first upload of a guest wins, later ones
/// get already_checked_in with the first time, and a client_id seen before is
/// answered as the first time without changing anything.
class FakeEventixServer {
  FakeEventixServer({int guests = 5, this.eventId = 7}) {
    for (var i = 1; i <= guests; i++) {
      this.guests[i] = {
        'id': i,
        'name_en': 'Guest $i',
        'name_ar': 'ضيف $i',
        'rsvp': i == guests ? 'Not Attending' : 'Attending',
        'table_number': '${(i + 1) ~/ 2}',
        'token': 'tok${i.toString().padLeft(10, '0')}',
        'checked_in': false,
        'label': null,
      };
    }
  }

  final int eventId;
  final Map<int, Map<String, Object?>> guests = {};
  final Map<String, Map<String, Object?>> answered = {};
  final Set<String> validTokens = {'token-a', 'token-b'};

  /// Every check-in the server applied, in order (client ids).
  final List<String> applied = [];
  int uploads = 0;
  int clock = 0;

  /// No answer at all (phone offline).
  bool offline = false;

  /// The next upload is applied, but its answer never reaches the phone.
  bool dropNextAnswer = false;

  String qrFor(int guestId) =>
      'https://eventix.om/qr/scan.php?t=${guests[guestId]!['token']}';

  EventixApi apiFor() => EventixApi(
      client: MockClient(_handle), baseUrl: 'https://eventix.test/');

  Future<http.Response> _handle(http.Request req) async {
    if (offline) throw const SocketException('offline');
    final auth = req.headers['Authorization'] ?? '';
    final token = auth.startsWith('Bearer ') ? auth.substring(7) : null;
    if (!validTokens.contains(token)) {
      return _json(401, {
        'error': {'code': 'token_invalid', 'message': 'Sign in again.'}
      });
    }
    final path = req.url.path;
    if (path.endsWith('guests.php')) {
      return _json(200, {
        'event': _event(),
        'generated_at': DateTime.now().toIso8601String(),
        'guests': [
          for (final g in guests.values)
            {
              'id': g['id'],
              'name_en': g['name_en'],
              'name_ar': g['name_ar'],
              'rsvp': g['rsvp'],
              'table_number': g['table_number'],
              'token_sha256': tokenSha256(g['token'] as String),
              'checked_in': g['checked_in'],
              'checked_in_at': null,
              'checked_in_label': g['label'],
            }
        ],
      });
    }
    if (path.endsWith('events.php')) {
      return _json(200, {
        'events': [_event()]
      });
    }
    if (path.endsWith('checkins.php')) {
      uploads++;
      final items = (jsonDecode(req.body) as Map)['checkins'] as List;
      final results = [for (final i in items) _apply(i as Map, token!)];
      if (dropNextAnswer) {
        dropNextAnswer = false;
        throw http.ClientException('connection reset');
      }
      return _json(200, {'results': results});
    }
    return _json(404, {
      'error': {'code': 'not_found', 'message': 'No such endpoint'}
    });
  }

  Map<String, Object?> _apply(Map item, String token) {
    final id = item['client_id'] as String;
    final gid = item['guest_id'] as int;
    final seen = answered[id];
    if (seen != null) return {...seen, 'replayed': true};
    final g = guests[gid];
    if (g == null) {
      return {'client_id': id, 'guest_id': gid, 'status': 'not_found'};
    }
    final String status;
    if (g['checked_in'] == true) {
      status = 'already_checked_in';
    } else {
      clock++;
      g['checked_in'] = true;
      g['label'] = '7:${clock.toString().padLeft(2, '0')} pm';
      applied.add(id);
      status = 'checked_in';
    }
    final r = {
      'client_id': id,
      'guest_id': gid,
      'status': status,
      'checked_in_at': '2026-11-20T19:00:00+04:00',
      'checked_in_label': g['label'],
    };
    answered[id] = r;
    return r;
  }

  /// An admin undoes a check-in on the website.
  void undoOnWeb(int guestId) {
    guests[guestId]!['checked_in'] = false;
    guests[guestId]!['label'] = null;
  }

  Map<String, Object?> _event() => {
        'id': eventId,
        'title_en': 'Test event',
        'title_ar': 'فعالية تجربة',
        'venue_en': 'Hall',
        'venue_ar': 'القاعة',
        'starts_label': 'Fri 20 Nov 2026, 7:00 pm',
        'timezone': 'Asia/Muscat',
        'guest_count': guests.length,
        'checked_in_count':
            guests.values.where((g) => g['checked_in'] == true).length,
      };

  http.Response _json(int status, Object body) => http.Response(
      jsonEncode(body), status,
      headers: {'content-type': 'application/json; charset=utf-8'});
}
