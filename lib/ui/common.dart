import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../data/api/eventix_api.dart';
import '../l10n/app_localizations.dart';

/// Eventix's colours (app/assets/css/eventix.css on the website).
class EvxColors {
  static const navy = Color(0xFF1A2744);
  static const gold = Color(0xFFB8923A);
  static const bg = Color(0xFFF8F7F4);
  static const success = Color(0xFF2D7A4F);
  static const warning = Color(0xFFC07A12);
  static const danger = Color(0xFFC0392B);
}

ThemeData eventixTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: EvxColors.navy,
    primary: EvxColors.navy,
    secondary: EvxColors.gold,
    error: EvxColors.danger,
    surface: Colors.white,
  );
  return ThemeData(
    colorScheme: scheme,
    scaffoldBackgroundColor: EvxColors.bg,
    appBarTheme: const AppBarTheme(
      backgroundColor: EvxColors.navy,
      foregroundColor: Colors.white,
    ),
    inputDecorationTheme: const InputDecorationTheme(
      border: OutlineInputBorder(),
      filled: true,
      fillColor: Colors.white,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(52),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
  );
}

extension L10nContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
  bool get isArabic => Localizations.localeOf(this).languageCode == 'ar';

  /// A guest's or event's name in the app's language, falling back to the other.
  String pick(String en, String ar) {
    final first = isArabic ? ar : en;
    return first.trim().isNotEmpty ? first : (isArabic ? en : ar);
  }

  /// The other language's version, when it differs (shown smaller).
  String? other(String en, String ar) {
    final second = isArabic ? en : ar;
    return second.trim().isEmpty || second == pick(en, ar) ? null : second;
  }

  /// A time on this phone's clock, e.g. "7:42 PM" / "٧:٤٢ م".
  String clock(DateTime t) =>
      DateFormat.jm(Localizations.localeOf(this).toLanguageTag())
          .format(t.toLocal());
}

/// What to tell door staff about a failed request, in their language.
String apiErrorText(AppLocalizations l, Object error) {
  if (error is NetworkException) return l.errorNetwork;
  if (error is RateLimitedException) {
    return error.code == 'too_many_attempts'
        ? l.errorTooManyAttempts
        : l.errorRateLimited;
  }
  if (error is ApiException) {
    return switch (error.code) {
      'invalid_credentials' => l.errorWrongPassword,
      'role_not_allowed' => l.errorRoleNotAllowed,
      'password_change_required' => l.errorPasswordChange,
      'forbidden' || 'event_not_found' => l.errorForbidden,
      _ => l.errorServer,
    };
  }
  return l.errorServer;
}

class LoadingView extends StatelessWidget {
  const LoadingView({super.key, this.label});
  final String? label;
  @override
  Widget build(BuildContext context) => Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const CircularProgressIndicator(),
          if (label != null) ...[
            const SizedBox(height: 16),
            Text(label!, textAlign: TextAlign.center),
          ],
        ]),
      );
}

/// A full-screen message: empty lists, errors, denied permissions.
class MessageView extends StatelessWidget {
  const MessageView({
    super.key,
    required this.icon,
    required this.title,
    this.body,
    this.actions = const [],
    this.color,
  });
  final IconData icon;
  final String title;
  final String? body;
  final List<Widget> actions;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 64, color: color ?? theme.colorScheme.outline),
          const SizedBox(height: 16),
          Text(title,
              style: theme.textTheme.titleLarge, textAlign: TextAlign.center),
          if (body != null) ...[
            const SizedBox(height: 8),
            Text(body!,
                style: theme.textTheme.bodyMedium, textAlign: TextAlign.center),
          ],
          if (actions.isNotEmpty) ...[
            const SizedBox(height: 24),
            ...actions.map((a) => Padding(
                padding: const EdgeInsets.only(bottom: 8), child: a)),
          ],
        ]),
      ),
    );
  }
}

class ErrorView extends StatelessWidget {
  const ErrorView({super.key, required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) => MessageView(
        icon: Icons.cloud_off,
        title: message,
        color: EvxColors.danger,
        actions: [
          FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: Text(context.l10n.retry),
          ),
        ],
      );
}

/// The language switch in app bars.
class LanguageButton extends StatelessWidget {
  const LanguageButton({super.key, required this.onSelected});
  final ValueChanged<String> onSelected;
  @override
  Widget build(BuildContext context) => PopupMenuButton<String>(
        icon: const Icon(Icons.translate),
        tooltip: context.l10n.language,
        onSelected: onSelected,
        itemBuilder: (_) => [
          PopupMenuItem(value: 'en', child: Text(context.l10n.english)),
          PopupMenuItem(value: 'ar', child: Text(context.l10n.arabic)),
        ],
      );
}
