import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    final themeMode = ref.watch(themeModeProvider);
    // signed out (or the server ended the sign-in): close the scan screens
    ref.listen(authProvider, (prev, next) {
      if (prev?.valueOrNull != null && next.valueOrNull == null) {
        _navigator.currentState?.popUntil((r) => r.isFirst);
      }
    });

    return MaterialApp(
      navigatorKey: _navigator,
      debugShowCheckedModeBanner: false,
      onGenerateTitle: (c) => AppLocalizations.of(c).appTitle,
      theme: buildEventixTheme(Brightness.light, arabicUi: false),
      darkTheme: buildEventixTheme(Brightness.dark, arabicUi: false),
      themeMode: themeMode,
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      // In Arabic the interface is set in Noto Naskh Arabic, as the website's [dir=rtl]
      builder: (context, child) {
        final theme = context.isArabic
            ? buildEventixTheme(Theme.of(context).brightness, arabicUi: true)
            : Theme.of(context);
        return Theme(
          data: theme,
          child: AnnotatedRegion<SystemUiOverlayStyle>(
            value: SystemUiOverlayStyle.light, // the navy bars carry white icons
            child: child!,
          ),
        );
      },
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
          loading: () => const _Launch(),
          error: (_, _) => const LoginScreen(),
          data: (s) => s == null ? const LoginScreen() : const EventsScreen(),
        );
  }
}

/// The moment between the native launch screen and the first screen: the same
/// navy and logo, so the hand-over is invisible.
class _Launch extends StatelessWidget {
  const _Launch();
  @override
  Widget build(BuildContext context) => const Scaffold(
        backgroundColor: Color(0xFF1A2744),
        body: Center(child: EvxLogo(height: 34, color: Colors.white)),
      );
}
