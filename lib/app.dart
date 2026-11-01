import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'l10n/app_localizations.dart';
import 'providers.dart';
import 'ui/common.dart';
import 'ui/events_screen.dart';
import 'ui/login_screen.dart';

class EventixScannerApp extends ConsumerStatefulWidget {
  const EventixScannerApp({super.key});
  @override
  ConsumerState<EventixScannerApp> createState() => _EventixScannerAppState();
}

class _EventixScannerAppState extends ConsumerState<EventixScannerApp> {
  final _navigator = GlobalKey<NavigatorState>();
  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    // Back in the foreground: upload anything waiting and refresh the open list.
    // Nothing is needed on pause: every check-in is already committed to SQLite.
    _lifecycle = AppLifecycleListener(onResume: () {
      if (ref.read(authProvider).valueOrNull != null) {
        ref.read(syncProvider.notifier).kick(refreshList: true);
      }
    });
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(languageProvider);
    // signed out (or the server ended the sign-in): close the scan screens
    ref.listen(authProvider, (prev, next) {
      if (prev?.valueOrNull != null && next.valueOrNull == null) {
        _navigator.currentState?.popUntil((r) => r.isFirst);
      }
    });

    return MaterialApp(
      navigatorKey: _navigator,
      onGenerateTitle: (c) => AppLocalizations.of(c).appTitle,
      theme: eventixTheme(),
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const _AuthGate(),
    );
  }
}

/// Sign-in screen or the app, depending on whether a session is saved.
class _AuthGate extends ConsumerWidget {
  const _AuthGate();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(authProvider).when(
          loading: () => const Scaffold(body: LoadingView()),
          error: (_, _) => const LoginScreen(),
          data: (s) => s == null ? const LoginScreen() : const EventsScreen(),
        );
  }
}
