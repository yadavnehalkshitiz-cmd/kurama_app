import 'package:flutter/material.dart';
import 'kurama_colors.dart';

/// Builds the Kurama App MaterialTheme.
///
/// Uses Material 3 dark, with tokens from [KuramaColors].
/// Minimum touch target: 48 dp (WCAG 2.5.5 AA).
ThemeData buildKuramaTheme() {
  final cs = ColorScheme.fromSeed(
    seedColor: KuramaColors.lacquer,
    brightness: Brightness.dark,
  ).copyWith(
    // Override generated values with exact brand tokens
    surface: KuramaColors.ink,
    onSurface: KuramaColors.ivory,
    primary: KuramaColors.lacquer,
    onPrimary: KuramaColors.ivory,
    secondary: KuramaColors.gold,
    onSecondary: KuramaColors.ink,
    error: KuramaColors.danger,
    onError: KuramaColors.ivory,
    surfaceContainerHighest: KuramaColors.panel,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: cs,
    scaffoldBackgroundColor: KuramaColors.ink,

    // ── Typography ──────────────────────────────────────────────────
    textTheme: const TextTheme(
      displayLarge: TextStyle(
          fontSize: 28, fontWeight: FontWeight.w700, color: KuramaColors.ivory),
      titleLarge: TextStyle(
          fontSize: 20, fontWeight: FontWeight.w600, color: KuramaColors.ivory),
      bodyLarge: TextStyle(fontSize: 16, color: KuramaColors.ivory),
      bodyMedium: TextStyle(fontSize: 14, color: KuramaColors.ivory),
      bodySmall: TextStyle(fontSize: 12, color: KuramaColors.ash),
      labelSmall: TextStyle(fontSize: 11, color: KuramaColors.ash),
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
      color: KuramaColors.panel,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0x22FFFFFF)),
      ),
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 0),
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
