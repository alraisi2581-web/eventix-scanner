import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../data/api/eventix_api.dart';
import '../l10n/app_localizations.dart';
import 'brand.dart';
import 'theme.dart';

export 'brand.dart';
export 'theme.dart';

// Unicode LEFT-TO-RIGHT ISOLATE and POP DIRECTIONAL ISOLATE (written as numbers: the
// characters themselves are invisible in source code)
final _lri = String.fromCharCode(0x2066);
final _pdi = String.fromCharCode(0x2069);

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

  /// [s] isolated left-to-right ("7:03 pm" from the server stays "7:03 pm"
  /// inside an Arabic sentence instead of reading "pm 7:03").
  String ltr(String s) => '$_lri$s$_pdi';

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
          SizedBox(
            width: 30,
            height: 30,
            child: CircularProgressIndicator(strokeWidth: 3, color: context.evx.gold),
          ),
          if (label != null) ...[
            const SizedBox(height: 16),
            Text(label!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall),
          ],
        ]),
      );
}

/// A full-screen message: empty lists, errors, denied permissions. The icon
/// sits in a tinted circle; the title is set in Playfair like the web's headings.
class MessageView extends StatelessWidget {
  const MessageView({
    super.key,
    required this.icon,
    required this.title,
    this.body,
    this.actions = const [],
    this.tone = EvxTone.gold,
  });
  final IconData icon;
  final String title;
  final String? body;
  final List<Widget> actions;
  final EvxTone tone;

  @override
  Widget build(BuildContext context) {
    final t = context.evx;
    final theme = Theme.of(context);
    final (fg, bg) = switch (tone) {
      EvxTone.success => (t.success, t.successBg),
      EvxTone.warning => (t.warning, t.warningBg),
      EvxTone.danger => (t.danger, t.dangerBg),
      EvxTone.info => (t.info, t.infoBg),
      EvxTone.neutral => (t.text2, t.surface2),
      EvxTone.gold => (t.gold, t.goldBg),
    };
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: bg,
                shape: BoxShape.circle,
                border: Border.all(color: fg.withValues(alpha: .25)),
              ),
              child: Icon(icon, size: 40, color: fg),
            ),
            const SizedBox(height: 20),
            Text(title,
                style: theme.textTheme.headlineSmall, textAlign: TextAlign.center),
            if (body != null) ...[
              const SizedBox(height: 8),
              Text(body!,
                  style: theme.textTheme.bodyMedium!.copyWith(color: t.text2),
                  textAlign: TextAlign.center),
            ],
            if (actions.isNotEmpty) ...[
              const SizedBox(height: 28),
              ...actions.map((a) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: SizedBox(width: double.infinity, child: a))),
            ],
          ]),
        ),
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
        icon: Icons.cloud_off_rounded,
        title: message,
        tone: EvxTone.danger,
        actions: [
          FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: Text(context.l10n.retry),
          ),
        ],
      );
}
