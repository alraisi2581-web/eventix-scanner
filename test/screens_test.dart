import 'package:eventix_scanner/app.dart';
import 'package:eventix_scanner/data/api/eventix_api.dart';
import 'package:eventix_scanner/data/db/database.dart';
import 'package:eventix_scanner/l10n/app_localizations.dart';
import 'package:eventix_scanner/data/session_store.dart';
import 'package:eventix_scanner/providers.dart';
import 'package:eventix_scanner/services/checkin_service.dart';
import 'package:eventix_scanner/ui/activity_screen.dart';
import 'package:eventix_scanner/ui/common.dart';
import 'package:eventix_scanner/ui/guest_search_screen.dart';
import 'package:eventix_scanner/ui/scan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fakes.dart';

void main() {
  late FakeEventixServer server;
  late AppDatabase db;

  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
    server = FakeEventixServer();
    db = memoryDb();
  });
  tearDown(() => db.close());

  List<Override> overrides() => [
        databaseProvider.overrideWithValue(db),
        apiProvider.overrideWithValue(server.apiFor()),
        connectivityProvider.overrideWithValue(const Stream.empty()),
      ];

  Future<void> pumpApp(WidgetTester tester) async {
    await tester.pumpWidget(
        ProviderScope(overrides: overrides(), child: const EventixScannerApp()));
    await tester.pumpAndSettle();
  }

  /// Ends the test with the app gone, so its timers stop.
  Future<void> closeApp(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 1));
  }

  Future<void> signIn(WidgetTester tester, String user, String password) async {
    await tester.enterText(find.byType(TextFormField).at(0), user);
    await tester.enterText(find.byType(TextFormField).at(1), password);
    await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
    await tester.pumpAndSettle();
  }

  group('sign-in', () {
    testWidgets('empty fields are refused before any request', (tester) async {
      await pumpApp(tester);
      await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
      await tester.pumpAndSettle();
      expect(find.text('Enter your username'), findsOneWidget);
      expect(find.text('Enter your password'), findsOneWidget);
      await closeApp(tester);
    });

    testWidgets('each server refusal gets its own explanation', (tester) async {
      await pumpApp(tester);
      final cases = {
        ('scanner1', 'wrong'): 'Wrong username or password.',
        ('inviter1', 'right'): "This account can't check guests in. Sign in with a scanner account.",
        ('temp1', 'right'): 'Your password is temporary',
      };
      for (final MapEntry(key: (user, pw), value: text) in cases.entries) {
        await signIn(tester, user, pw);
        expect(find.textContaining(text), findsOneWidget, reason: user);
      }
      server.offline = true;
      await signIn(tester, 'scanner1', 'right');
      expect(find.textContaining('No connection to Eventix'), findsOneWidget);
      await closeApp(tester);
    });

    testWidgets('signing in shows the events, then the list downloads', (tester) async {
      await pumpApp(tester);
      await signIn(tester, 'scanner1', 'right');
      expect(find.text('Your events'), findsOneWidget);
      expect(find.text('Test event'), findsOneWidget);
      expect(find.text('Signed in as scanner1'), findsOneWidget);
      expect(find.textContaining('Guest list not downloaded yet'), findsOneWidget);
      await closeApp(tester);
    });

    testWidgets('signed in offline: the saved events show with a notice', (tester) async {
      await pumpApp(tester);
      await signIn(tester, 'scanner1', 'right');
      await closeApp(tester);

      server.offline = true; // the app restarts with no network
      await pumpApp(tester);
      expect(find.text('Test event'), findsOneWidget);
      expect(find.textContaining('Offline'), findsOneWidget);
      await closeApp(tester);
    });

    testWidgets('no events assigned: an empty state that says what to do', (tester) async {
      await pumpApp(tester);
      await signIn(tester, 'scanner2', 'right');
      expect(find.text('Test event'), findsOneWidget); // the fake gives everyone one
      await db.replaceEvents(2, const []);
      await tester.pumpAndSettle();
      expect(find.text('No events yet'), findsOneWidget);
      await closeApp(tester);
    });
  });

  testWidgets('Arabic: right-to-left with Arabic texts', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.byIcon(Icons.translate));
    await tester.pumpAndSettle();
    await tester.tap(find.text('العربية').last);
    await tester.pumpAndSettle();
    expect(find.text('سجّل الدخول لتسجيل حضور الضيوف'), findsOneWidget);
    expect(Directionality.of(tester.element(find.byType(TextFormField).first)),
        TextDirection.rtl);
    await closeApp(tester);
  });

  group('at the door', () {
    Future<void> withScreen(WidgetTester tester, Widget screen) async {
      await tester.pumpWidget(ProviderScope(
        overrides: overrides(),
        child: MaterialApp(
          theme: eventixTheme(),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: screen,
        ),
      ));
      await tester.pumpAndSettle();
    }

    Future<GuestRow> guest(WidgetTester tester, int id) async {
      return (await tester.runAsync(() async {
        final list = await server.apiFor().guests('token-a', server.eventId);
        await db.replaceGuestList(1, list, requestedAt: DateTime.now());
        return (await db.guestById(id))!;
      }))!;
    }

    testWidgets('green result with the RSVP warning for a declined guest', (tester) async {
      final g = await guest(tester, 5);
      await withScreen(tester, ScanResultView(outcome: CheckedIn(g), onDismiss: () {}));
      expect(find.text('Checked in'), findsOneWidget);
      expect(find.text('Guest 5'), findsOneWidget);
      expect(find.text('ضيف 5'), findsOneWidget);
      expect(find.text('Table 3'), findsOneWidget);
      expect(find.text('RSVP: not attending'), findsOneWidget);
      await closeApp(tester);
    });

    testWidgets('amber result: already checked in, with the time', (tester) async {
      final g = await guest(tester, 1);
      await withScreen(
          tester,
          ScanResultView(
              outcome: AlreadyCheckedIn(g, timeLabel: '7:42 pm', onThisPhone: false),
              onDismiss: () {}));
      expect(find.text('Already checked in · 7:42 pm'), findsOneWidget);
      await closeApp(tester);
    });

    testWidgets('red results say what to do', (tester) async {
      await withScreen(tester,
          ScanResultView(outcome: const NotAnInvitation(), onDismiss: () {}));
      expect(find.text('Not an Eventix invitation'), findsOneWidget);
      expect(find.textContaining('Ask the guest for the QR'), findsOneWidget);
      await closeApp(tester);
    });

    testWidgets('search by name: validation, results, check-in', (tester) async {
      await guest(tester, 1);
      await tester.pumpWidget(ProviderScope(
        overrides: [
          ...overrides(),
          authProvider.overrideWith(() => _SignedIn()),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (c) => Scaffold(
              body: Center(
                child: TextButton(
                  onPressed: () async {
                    final out = await Navigator.of(c).push<ScanOutcome>(
                        MaterialPageRoute(
                            builder: (_) => GuestSearchScreen(eventId: server.eventId)));
                    if (out is CheckedIn && c.mounted) {
                      ScaffoldMessenger.of(c).showSnackBar(
                          SnackBar(content: Text('in: ${out.guest.nameEn}')));
                    }
                  },
                  child: const Text('open'),
                ),
              ),
            ),
          ),
        ),
      ));
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('guest-search')), 'G');
      await tester.pumpAndSettle();
      expect(find.text('Type at least 2 letters, or a table number'), findsWidgets);

      await tester.enterText(find.byKey(const Key('guest-search')), 'zzz');
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();
      expect(find.text('No guest matches “zzz”'), findsOneWidget);

      await tester.enterText(find.byKey(const Key('guest-search')), 'Guest 2');
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ListTile, 'Guest 2'));
      await tester.pumpAndSettle();
      expect(find.text('Check in Guest 2?'), findsOneWidget);
      await tester.tap(find.widgetWithText(FilledButton, 'Check in'));
      // Drift's transaction waits on timers: move the test clock along until it is done
      for (var i = 0; i < 20 && find.text('in: Guest 2').evaluate().isEmpty; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }
      expect(find.text('in: Guest 2'), findsWidgets); // the snack bar animates in
      final row = await tester.runAsync(() => db.checkinFor(server.eventId, 2));
      expect(row!.state, CheckinState.pending);
      await closeApp(tester);
    });

    testWidgets('activity: a conflict is shown until acknowledged', (tester) async {
      final g = await guest(tester, 3);
      await tester.runAsync(() async {
        await CheckinService(db).checkIn(sessionFor(1, 'token-a'), g);
        server.guests[3]!['checked_in'] = true; // another phone got there first
        server.guests[3]!['label'] = '7:05 pm';
        final row = (await db.checkinFor(server.eventId, 3))!;
        final results = await server.apiFor().uploadCheckins('token-a', [
          CheckinUpload(clientId: row.clientId, guestId: row.guestId, scannedAt: row.scannedAt),
        ]);
        await db.applyResult(results.single);
      });

      await withScreen(tester, ActivityScreen(eventId: server.eventId));
      expect(find.textContaining("Already checked in at 7:05 pm"), findsOneWidget);
      await withScreen(tester, Scaffold(body: ConflictBanner(eventId: server.eventId)));
      expect(find.textContaining('Guest 3 was already checked in at 7:05 pm'), findsOneWidget);
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('conflict-banner')), findsNothing);
      await closeApp(tester);
    });
  });
}

class _SignedIn extends AuthController {
  @override
  Future<Session?> build() async => sessionFor(1, 'token-a');
}
