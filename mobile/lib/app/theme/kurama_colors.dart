import 'package:flutter/material.dart';

/// Lacquer & Gold — Kurama App design token set.
///
/// All colours are declared as `const` values so the compiler dead-strips
/// any token that is never referenced.
abstract final class KuramaColors {
  // ── Backgrounds ────────────────────────────────────────────────────
  /// Primary app background — pitch dark obsidian.
  static const Color ink = Color(0xFF0A0A0E);

  /// Deep obsidian canvas background.
  static const Color surfaceDark = Color(0xFF0D0D14);

  /// Card / sheet surface — slightly lighter than ink.
  static const Color panel = Color(0xFF171720);

  /// Glassmorphic container surface.
  static const Color surfaceContainer = Color(0xFF14141E);

  /// Glass container subtle border.
  static const Color glassBorder = Color(0x1FFFFFFF);

  /// Glow accent for Lacquer buttons and hero artwork.
  static const Color lacquerGlow = Color(0x66E53935);

  // ── Brand accents ─────────────────────────────────────────────────
  /// Lacquer red — primary interactive colour, CTAs, progress.
  static const Color lacquer = Color(0xFFE53935);

  /// Lacquer mid — hover / pressed state.
  static const Color lacquerMid = Color(0xFFEF5350);

  /// Gold — premium, completed, award.
  static const Color gold = Color(0xFFFFB300);

  /// Gold highlight — hover / shine effect.
  static const Color goldHigh = Color(0xFFFFCA28);

  // ── Text / content ────────────────────────────────────────────────
  /// Primary text on dark backgrounds.
  static const Color ivory = Color(0xFFF5F0E8);

  /// Secondary / subdued text.
  static const Color ash = Color(0xFF9E9EAE);

  // ── Semantic ──────────────────────────────────────────────────────
  /// Success / completed state.
  static const Color success = Color(0xFF43A047);

  /// Warning / attention.
  static const Color warning = Color(0xFFFFA000);

  /// Error / danger state.
  static const Color danger = Color(0xFFD32F2F);
}
