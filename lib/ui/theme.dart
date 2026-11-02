
import 'package:flutter/material.dart';

/// The Eventix web app's design tokens (app/assets/css/eventix.css, section 1
/// and its [data-theme="dark"] block), so the app and the website are one product.
@immutable
class EvxTokens extends ThemeExtension<EvxTokens> {
  const EvxTokens({
    required this.bg,
    required this.surface,
    required this.surface2,
    required this.border,
    required this.text,
    required this.text2,
    required this.text3,
    required this.gold,
    required this.goldLight,
    required this.goldBg,
    required this.navy,
    required this.navy2,
    required this.success,
    required this.danger,
    required this.warning,
    required this.info,
    required this.successBg,
    required this.dangerBg,
    required this.warningBg,
    required this.infoBg,
    required this.shadowSm,
    required this.shadowMd,
    required this.shadowLg,
  });

  final Color bg, surface, surface2, border, text, text2, text3;
  final Color gold, goldLight, goldBg, navy, navy2;
  final Color success, danger, warning, info;
  final Color successBg, dangerBg, warningBg, infoBg;
  final List<BoxShadow> shadowSm, shadowMd, shadowLg;

  static const light = EvxTokens(
    bg: Color(0xFFF8F7F4),
    surface: Color(0xFFFFFFFF),
    surface2: Color(0xFFF2F0EC),
    border: Color(0xFFE4E0D8),
    text: Color(0xFF1C1917),
    text2: Color(0xFF6B6560),
    text3: Color(0xFF9C9690),
    gold: Color(0xFFB8923A),
    goldLight: Color(0xFFE8D5A3),
    goldBg: Color(0xFFFDF6E8),
    navy: Color(0xFF1A2744),
    navy2: Color(0xFF243259),
    success: Color(0xFF2D7A4F),
    danger: Color(0xFFC0392B),
    warning: Color(0xFFC07A12),
    info: Color(0xFF1A6FA8),
    successBg: Color(0xFFEDF7F1),
    dangerBg: Color(0xFFFDF0EE),
    warningBg: Color(0xFFFDF5E6),
    infoBg: Color(0xFFE8F3FB),
    // --shadow-sm / -md / -lg
    shadowSm: [
      BoxShadow(color: Color(0x14000000), offset: Offset(0, 1), blurRadius: 3),
      BoxShadow(color: Color(0x0D000000), offset: Offset(0, 1), blurRadius: 2),
    ],
    shadowMd: [
      BoxShadow(color: Color(0x1A000000), offset: Offset(0, 4), blurRadius: 16),
      BoxShadow(color: Color(0x0F000000), offset: Offset(0, 2), blurRadius: 6),
    ],
    shadowLg: [
      BoxShadow(color: Color(0x24000000), offset: Offset(0, 12), blurRadius: 40),
    ],
  );

  static const dark = EvxTokens(
    bg: Color(0xFF0F0E0C),
    surface: Color(0xFF1C1B18),
    surface2: Color(0xFF252320),
    border: Color(0xFF333128),
    text: Color(0xFFF0ECE4),
    text2: Color(0xFFA09A90),
    text3: Color(0xFF6B6560),
    gold: Color(0xFFC9A84C),
    goldLight: Color(0xFF7A6030),
    goldBg: Color(0xFF1F1A0E),
    navy: Color(0xFF2A3D6E),
    navy2: Color(0xFF1E2D54),
    success: Color(0xFF3A9E68),
    danger: Color(0xFFD9534F),
    warning: Color(0xFFD4901A),
    info: Color(0xFF2D8FD4),
    successBg: Color(0xFF0E1F15),
    dangerBg: Color(0xFF1F0E0D),
    warningBg: Color(0xFF1F160A),
    infoBg: Color(0xFF0B1720),
    shadowSm: [
      BoxShadow(color: Color(0x4D000000), offset: Offset(0, 1), blurRadius: 3),
    ],
    shadowMd: [
      BoxShadow(color: Color(0x66000000), offset: Offset(0, 4), blurRadius: 16),
    ],
    shadowLg: [
      BoxShadow(color: Color(0x80000000), offset: Offset(0, 12), blurRadius: 40),
    ],
  );

  /// The navy of the web's top bar, which stays navy in both themes there.
  Color get bar => navy;

  @override
  EvxTokens copyWith() => this;

  @override
  EvxTokens lerp(ThemeExtension<EvxTokens>? other, double t) =>
      t < .5 ? this : (other as EvxTokens? ?? this);
}

extension EvxTheme on BuildContext {
  /// The Eventix tokens of the current theme; under a theme built elsewhere
  /// (a plain MaterialApp), the light or dark set by its brightness.
  EvxTokens get evx {
    final theme = Theme.of(this);
    return theme.extension<EvxTokens>() ??
        (theme.brightness == Brightness.dark ? EvxTokens.dark : EvxTokens.light);
  }
}

// ── Type ──────────────────────────────────────────────────────────────────────
// The web: DM Sans for text (15px, line-height 1.65), Playfair Display 700 for
// headings (letter-spacing -.02em), Noto Naskh Arabic for Arabic. The fonts are
// variable, so every style sets its weight axis as well as FontWeight.

const sans = 'DM Sans';
const display = 'Playfair Display';
const arabic = 'Noto Naskh Arabic';

TextStyle evxText(
  double size, {
  FontWeight weight = FontWeight.w400,
  String family = sans,
  Color? color,
  double? height,
  double? letterSpacing,
}) =>
    TextStyle(
      fontFamily: family,
      fontFamilyFallback: const [arabic],
      fontSize: size,
      fontWeight: weight,
      fontVariations: [FontVariation('wght', weight.value.toDouble())],
      // Playfair's default old-style figures make 0 read as O: lining figures
      fontFeatures: family == display ? const [FontFeature.liningFigures()] : null,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
    );

TextStyle evxDisplay(double size, {Color? color, FontWeight weight = FontWeight.w700}) =>
    evxText(size,
        family: display,
        weight: weight,
        color: color,
        height: 1.2,
        letterSpacing: size * -.02);

TextTheme _textTheme(EvxTokens t, {required bool arabicUi}) {
  // Arabic letters always come from Noto Naskh (the fallback of every style); in
  // Arabic the headings stay sans so English names in them don't switch to Playfair
  const body = sans;
  final head = arabicUi ? sans : display;
  return TextTheme(
    displaySmall: evxText(30, family: head, weight: FontWeight.w700, color: t.text, height: 1.2),
    headlineMedium: evxText(26, family: head, weight: FontWeight.w700, color: t.text, height: 1.25),
    headlineSmall: evxText(22, family: head, weight: FontWeight.w700, color: t.text, height: 1.25),
    titleLarge: evxText(19, family: body, weight: FontWeight.w600, color: t.text, height: 1.3),
    titleMedium: evxText(16, family: body, weight: FontWeight.w600, color: t.text, height: 1.4),
    titleSmall: evxText(14, family: body, weight: FontWeight.w600, color: t.text, height: 1.4),
    bodyLarge: evxText(16, family: body, color: t.text, height: 1.6),
    bodyMedium: evxText(15, family: body, color: t.text, height: 1.6),
    bodySmall: evxText(13, family: body, color: t.text2, height: 1.5),
    labelLarge: evxText(15, family: body, weight: FontWeight.w600, height: 1.2),
    labelMedium: evxText(13, family: body, weight: FontWeight.w500, color: t.text2),
    labelSmall: evxText(12, family: body, weight: FontWeight.w600, color: t.text2),
  );
}

// ── Components ────────────────────────────────────────────────────────────────

const radiusSm = 6.0; // --radius-sm: buttons, fields
const radiusMd = 10.0; // --radius-md: cards, alerts
const radiusLg = 16.0; // --radius-lg: dialogs
const radiusXl = 24.0; // --radius-xl: the sign-in card

ThemeData buildEventixTheme(Brightness brightness, {required bool arabicUi}) {
  final t = brightness == Brightness.dark ? EvxTokens.dark : EvxTokens.light;
  final text = _textTheme(t, arabicUi: arabicUi);
  final scheme = ColorScheme(
    brightness: brightness,
    primary: t.navy,
    onPrimary: Colors.white,
    secondary: t.gold,
    onSecondary: Colors.white,
    error: t.danger,
    onError: Colors.white,
    surface: t.surface,
    onSurface: t.text,
    onSurfaceVariant: t.text2,
    outline: t.border,
    outlineVariant: t.border,
    surfaceContainerHighest: t.surface2,
  );
  final fieldBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(radiusSm),
    borderSide: BorderSide(color: t.border),
  );
  final buttonShape =
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusSm));

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: scheme,
    scaffoldBackgroundColor: t.bg,
    textTheme: text,
    extensions: [t],
    splashFactory: InkSparkle.splashFactory,
    dividerTheme: DividerThemeData(color: t.border, space: 1, thickness: 1),
    appBarTheme: AppBarTheme(
      backgroundColor: t.bar,
      foregroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: text.titleLarge!.copyWith(color: Colors.white),
      iconTheme: const IconThemeData(color: Colors.white),
      actionsIconTheme: const IconThemeData(color: Colors.white),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: t.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: fieldBorder,
      enabledBorder: fieldBorder,
      // the web's gold focus ring
      focusedBorder: fieldBorder.copyWith(borderSide: BorderSide(color: t.gold, width: 1.6)),
      errorBorder: fieldBorder.copyWith(borderSide: BorderSide(color: t.danger)),
      focusedErrorBorder: fieldBorder.copyWith(borderSide: BorderSide(color: t.danger, width: 1.6)),
      hintStyle: text.bodyMedium!.copyWith(color: t.text3),
      prefixIconColor: t.text3,
      suffixIconColor: t.text3,
      errorStyle: text.bodySmall!.copyWith(color: t.danger),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: t.navy,
        foregroundColor: Colors.white,
        disabledBackgroundColor: t.navy.withValues(alpha: .55),
        disabledForegroundColor: Colors.white70,
        minimumSize: const Size.fromHeight(50),
        shape: buttonShape,
        textStyle: text.labelLarge,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: brightness == Brightness.dark ? t.text : t.navy,
        side: BorderSide(color: brightness == Brightness.dark ? t.border : t.navy),
        minimumSize: const Size(0, 48),
        shape: buttonShape,
        textStyle: text.labelLarge,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: t.gold,
        shape: buttonShape,
        textStyle: text.labelLarge,
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(minimumSize: const Size(44, 44)),
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: t.gold,
      linearTrackColor: t.border,
      circularTrackColor: Colors.transparent,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: t.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusLg)),
      titleTextStyle: evxDisplay(21, color: t.text),
      contentTextStyle: text.bodyMedium,
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: t.navy,
      contentTextStyle: text.bodyMedium!.copyWith(color: Colors.white),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusMd)),
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: t.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          side: BorderSide(color: t.border)),
      textStyle: text.bodyMedium,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: t.gold,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusMd)),
      extendedTextStyle: text.labelLarge,
    ),
    listTileTheme: ListTileThemeData(
      iconColor: t.text2,
      titleTextStyle: text.titleSmall!.copyWith(fontSize: 15),
      subtitleTextStyle: text.bodySmall,
    ),
  );
}
