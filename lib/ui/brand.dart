import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'theme.dart';

/// The Eventix wordmark (the web's assets/img/eventix-logo.svg), in one colour:
/// white on the navy bar as in the web's top bar, black or white on the sign-in card.
class EvxLogo extends StatelessWidget {
  const EvxLogo({super.key, this.height = 22, this.color});
  final double height;
  final Color? color;
  @override
  Widget build(BuildContext context) => SvgPicture.asset(
        'assets/brand/eventix-logo.svg',
        height: height,
        semanticsLabel: 'Eventix',
        colorFilter:
            ColorFilter.mode(color ?? context.evx.text, BlendMode.srcIn),
      );
}

/// The QR mark on its own (the logo's glyph).
class EvxMark extends StatelessWidget {
  const EvxMark({super.key, this.size = 40, this.color});
  final double size;
  final Color? color;
  @override
  Widget build(BuildContext context) => SvgPicture.asset(
        'assets/brand/eventix-mark.svg',
        width: size,
        height: size,
        excludeFromSemantics: true,
        colorFilter:
            ColorFilter.mode(color ?? context.evx.gold, BlendMode.srcIn),
      );
}

/// The web's .card: surface, 1px border, --radius-md, --shadow-sm; an optional
/// footer in surface-2 like .card-footer.
class EvxCard extends StatelessWidget {
  const EvxCard({
    super.key,
    required this.child,
    this.footer,
    this.padding = const EdgeInsets.all(18),
    this.onTap,
    this.accent,
  });
  final Widget child;
  final Widget? footer;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  /// A colour stripe on the leading edge (status).
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    final t = context.evx;
    Widget body = Padding(padding: padding, child: child);
    if (accent != null) {
      body = DecoratedBox(
        decoration: BoxDecoration(
          border: BorderDirectional(start: BorderSide(color: accent!, width: 4)),
        ),
        child: body,
      );
    }
    return Container(
      decoration: BoxDecoration(
        color: t.surface,
        borderRadius: BorderRadius.circular(radiusMd),
        border: Border.all(color: t.border),
        boxShadow: t.shadowSm,
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              body,
              if (footer != null)
                Container(
                  decoration: BoxDecoration(
                    color: t.surface2,
                    border: Border(top: BorderSide(color: t.border)),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  child: DefaultTextStyle.merge(
                    style: Theme.of(context).textTheme.bodySmall!,
                    child: footer!,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

enum EvxTone { success, warning, danger, info, neutral, gold }

extension on EvxTone {
  (Color fg, Color bg) colors(EvxTokens t) => switch (this) {
        EvxTone.success => (t.success, t.successBg),
        EvxTone.warning => (t.warning, t.warningBg),
        EvxTone.danger => (t.danger, t.dangerBg),
        EvxTone.info => (t.info, t.infoBg),
        EvxTone.gold => (t.gold, t.goldBg),
        EvxTone.neutral => (t.text2, t.surface2),
      };
}

/// The web's .badge: a small pill, tinted background, coloured text and border.
class EvxBadge extends StatelessWidget {
  const EvxBadge(this.label, {super.key, this.tone = EvxTone.neutral, this.icon});
  final String label;
  final EvxTone tone;
  final IconData? icon;
  @override
  Widget build(BuildContext context) {
    final (fg, bg) = tone.colors(context.evx);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: fg.withValues(alpha: .45)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        if (icon != null) ...[
          Icon(icon, size: 13, color: fg),
          const SizedBox(width: 4),
        ],
        Text(label,
            style: evxText(12, weight: FontWeight.w600, color: fg, letterSpacing: .2)),
      ]),
    );
  }
}

/// The web's .alert: tinted panel, coloured text, icon first; optional action.
class EvxAlert extends StatelessWidget {
  const EvxAlert({
    super.key,
    required this.text,
    this.tone = EvxTone.warning,
    this.icon,
    this.action,
  });
  final String text;
  final EvxTone tone;
  final IconData? icon;
  final Widget? action;
  @override
  Widget build(BuildContext context) {
    final (fg, bg) = tone.colors(context.evx);
    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(radiusMd),
        border: Border.all(color: fg.withValues(alpha: .25)),
      ),
      padding: const EdgeInsetsDirectional.fromSTEB(14, 12, 8, 12),
      child: Row(children: [
        Icon(icon ?? Icons.info_outline, color: fg, size: 22),
        const SizedBox(width: 10),
        Expanded(
          child: Text(text,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium!
                  .copyWith(color: fg, fontSize: 14, height: 1.45)),
        ),
        ?action,
      ]),
    );
  }
}

/// The web's check-in progress bar (scanner dashboard): 5px, rounded, green.
class EvxProgress extends StatelessWidget {
  const EvxProgress({super.key, required this.value, this.color, this.track, this.height = 5});
  final double value;
  final Color? color;
  final Color? track;
  final double height;
  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: LinearProgressIndicator(
          value: value.clamp(0, 1),
          minHeight: height,
          color: color ?? context.evx.success,
          backgroundColor: track ?? context.evx.border,
        ),
      );
}

/// The web's EN | ع slider in the nav and on the sign-in card.
class LanguageToggle extends StatelessWidget {
  const LanguageToggle({super.key, required this.onSelected, this.onDark = false});
  final ValueChanged<String> onSelected;

  /// On the navy bar rather than on a light surface.
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    final t = context.evx;
    final current = Localizations.localeOf(context).languageCode;
    Widget opt(String code, String label) {
      final active = current == code;
      return Semantics(
        selected: active,
        button: true,
        label: code == 'en' ? 'English' : 'العربية',
        child: GestureDetector(
          onTap: () => onSelected(code),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
            decoration: BoxDecoration(
              color: active
                  ? (onDark ? Colors.white.withValues(alpha: .14) : t.surface)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(label,
                style: evxText(13,
                    family: code == 'ar' ? arabic : sans,
                    weight: FontWeight.w700,
                    color: active
                        ? t.gold
                        : (onDark ? Colors.white60 : t.text3))),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: onDark ? Colors.white.withValues(alpha: .08) : t.surface2,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Directionality(
        textDirection: TextDirection.ltr, // EN stays left, as on the website
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          opt('en', 'EN'),
          opt('ar', 'ع'),
        ]),
      ),
    );
  }
}

/// The web's round dark-mode button.
class ThemeToggle extends StatelessWidget {
  const ThemeToggle({super.key, required this.onToggle, this.onDark = false});
  final VoidCallback onToggle;
  final bool onDark;
  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final t = context.evx;
    return Material(
      color: onDark ? Colors.white.withValues(alpha: .08) : t.surface2,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onToggle,
        child: Tooltip(
          message: dark ? 'Light' : 'Dark',
          child: SizedBox(
            width: 36,
            height: 36,
            child: Icon(dark ? Icons.light_mode_rounded : Icons.dark_mode_outlined,
                size: 19, color: dark ? t.gold : (onDark ? Colors.white : t.text2)),
          ),
        ),
      ),
    );
  }
}

/// A page title in Playfair with a quiet line under it (the web's page header).
class PageHeader extends StatelessWidget {
  const PageHeader({super.key, required this.title, this.subtitle});
  final String title;
  final String? subtitle;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 8),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: theme.textTheme.headlineMedium),
        if (subtitle != null) ...[
          const SizedBox(height: 2),
          Text(subtitle!, style: theme.textTheme.bodySmall),
        ],
      ]),
    );
  }
}
