import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'kurama_colors.dart';

/// Builds the Kurama App MaterialTheme.
///
/// Uses Material 3 dark, with tokens from [KuramaColors].
/// Minimum touch target: 48 dp (WCAG 2.5.5 AA).
ThemeData buildKuramaTheme() {
  final baseTheme = ThemeData(brightness: Brightness.dark);
  
  final cs = ColorScheme.fromSeed(
    seedColor: const Color(0xFFFF5722),
    brightness: Brightness.dark,
  ).copyWith(
    surface: const Color(0xFF12121A),
    onSurface: const Color(0xFFF4E8D0),
    primary: const Color(0xFFFF5722),
    onPrimary: Colors.white,
    secondary: const Color(0xFFD8B46A),
    onSecondary: const Color(0xFF0B0809),
    error: const Color(0xFF743533),
    onError: Colors.white,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: cs,
    scaffoldBackgroundColor: const Color(0xFF12121A),
    fontFamily: GoogleFonts.outfit().fontFamily,

    // ── Typography ──────────────────────────────────────────────────
    textTheme: GoogleFonts.outfitTextTheme(baseTheme.textTheme).copyWith(
      displayLarge: const TextStyle(
          fontSize: 28, fontWeight: FontWeight.w700, color: KuramaColors.ivory),
      titleLarge: const TextStyle(
          fontSize: 20, fontWeight: FontWeight.w600, color: KuramaColors.ivory),
      bodyLarge: const TextStyle(fontSize: 16, color: KuramaColors.ivory),
      bodyMedium: const TextStyle(fontSize: 14, color: KuramaColors.ivory),
      bodySmall: const TextStyle(fontSize: 12, color: KuramaColors.ash),
      labelSmall: const TextStyle(fontSize: 11, color: KuramaColors.ash),
    ),

    // ── Buttons — 48 dp minimum height ─────────────────────────────
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(64, 48),
        backgroundColor: KuramaColors.lacquer,
        foregroundColor: KuramaColors.ivory,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(64, 48),
        backgroundColor: KuramaColors.panel,
        foregroundColor: KuramaColors.ivory,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(64, 48),
        foregroundColor: KuramaColors.gold,
        side: const BorderSide(color: KuramaColors.gold, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        minimumSize: const Size(44, 44),
        foregroundColor: KuramaColors.gold,
      ),
    ),

    // ── Cards ───────────────────────────────────────────────────────
    cardTheme: CardThemeData(
      color: const Color(0xFF1E1E2C),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
      ),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
    ),

    // ── Input fields ────────────────────────────────────────────────
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: KuramaColors.panel,
      hintStyle: const TextStyle(color: KuramaColors.ash),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0x33FFFFFF)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0x33FFFFFF)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: KuramaColors.lacquer, width: 2),
      ),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),

    // ── Bottom navigation ───────────────────────────────────────────
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: KuramaColors.panel,
      indicatorColor: KuramaColors.lacquer.withAlpha(50),
      labelTextStyle: WidgetStateProperty.resolveWith(
        (states) => TextStyle(
          color: states.contains(WidgetState.selected)
              ? KuramaColors.lacquer
              : KuramaColors.ash,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
      iconTheme: WidgetStateProperty.resolveWith(
        (states) => IconThemeData(
          color: states.contains(WidgetState.selected)
              ? KuramaColors.lacquer
              : KuramaColors.ash,
        ),
      ),
    ),

    // ── Progress ────────────────────────────────────────────────────
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: KuramaColors.lacquer,
    ),

    // ── Divider ─────────────────────────────────────────────────────
    dividerTheme: const DividerThemeData(
      color: Color(0x22FFFFFF),
      thickness: 1,
    ),

    // ── Chip ────────────────────────────────────────────────────────
    chipTheme: ChipThemeData(
      backgroundColor: KuramaColors.panel,
      labelStyle: const TextStyle(color: KuramaColors.ivory, fontSize: 12),
      side: const BorderSide(color: Color(0x33FFFFFF)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
  );
}
