import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Clarus design tokens.
/// Palette grounded in the app's subject: warm amber echoes a fundus
/// photograph's glow; deep teal-ink reads clinical without being cold.
class ClarusColors {
  static const Color ink = Color(0xFF12312E); // primary / headers / nav
  static const Color canvas = Color(0xFFF4F7F5); // background
  static const Color accent = Color(0xFFD6A419); // brand amber — also "Monitor"
  static const Color refer =
      Color(0xFFB3392C); // "Refer" triage — muted brick red
  static const Color normal = Color(0xFF3F7A5C); // "Normal" triage — muted sage
  static const Color textPrimary = Color(0xFF1B2523);
  static const Color textMuted = Color(0xFF5B6B67);
  static const Color divider = Color(0xFFDDE5E2);
  static const Color cardSurface = Color(0xFFFFFFFF);

  /// Returns the correct triage color for a given category string.
  static Color forTriage(String triage) {
    switch (triage) {
      case 'Normal':
        return normal;
      case 'Monitor':
        return accent;
      case 'Refer':
        return refer;
      default:
        return textMuted;
    }
  }
}

class ClarusType {
  static TextTheme textTheme() {
    final display = GoogleFonts.fraunces();
    final body = GoogleFonts.ibmPlexSans();

    return TextTheme(
      displaySmall: display.copyWith(
        fontSize: 30,
        fontWeight: FontWeight.w600,
        color: ClarusColors.ink,
        height: 1.15,
      ),
      headlineSmall: display.copyWith(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: ClarusColors.ink,
      ),
      titleMedium: body.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: ClarusColors.textPrimary,
      ),
      bodyLarge: body.copyWith(
          fontSize: 16, color: ClarusColors.textPrimary, height: 1.4),
      bodyMedium: body.copyWith(
          fontSize: 14, color: ClarusColors.textPrimary, height: 1.4),
      bodySmall: body.copyWith(
          fontSize: 12, color: ClarusColors.textMuted, height: 1.3),
      labelLarge: body.copyWith(fontSize: 14, fontWeight: FontWeight.w600),
    );
  }

  /// For data: confidence scores, encounter IDs, timestamps.
  static TextStyle mono({double size = 13, Color? color, FontWeight? weight}) {
    return GoogleFonts.ibmPlexMono(
      fontSize: size,
      color: color ?? ClarusColors.textMuted,
      fontWeight: weight ?? FontWeight.w500,
    );
  }
}

ThemeData clarusTheme() {
  return ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: ClarusColors.canvas,
    colorScheme: ColorScheme.fromSeed(
      seedColor: ClarusColors.ink,
      primary: ClarusColors.ink,
      secondary: ClarusColors.accent,
      surface: ClarusColors.cardSurface,
    ),
    textTheme: ClarusType.textTheme(),
    appBarTheme: AppBarTheme(
      backgroundColor: ClarusColors.canvas,
      elevation: 0,
      foregroundColor: ClarusColors.ink,
      titleTextStyle: ClarusType.textTheme().headlineSmall,
      centerTitle: false,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: ClarusColors.ink,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: ClarusType.textTheme().labelLarge,
        elevation: 0,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: ClarusColors.ink,
        side: const BorderSide(color: ClarusColors.ink, width: 1.3),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
    cardTheme: CardThemeData(
      color: ClarusColors.cardSurface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: ClarusColors.divider),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: ClarusColors.cardSurface,
      indicatorColor: ClarusColors.accent.withValues(alpha: 0.18),
      labelTextStyle: WidgetStateProperty.all(
        ClarusType.textTheme().bodySmall?.copyWith(color: ClarusColors.ink),
      ),
    ),
  );
}
