import 'package:flutter/material.dart';

/// Munchify POS brand color palette.
///
/// Source of truth for every color used in the app.
/// Widgets must reference these constants — never use raw hex strings inline.
///
/// Primary palette defined in AI Guide §6:
///   - Appetizing Orange  #E65100
///   - Amber              #FFB300
///   - Warm Dark Grey     #212121
///   - Light Warm Cream   #FFFDF9
class ColorPalette {
  ColorPalette._();

  // ─── Brand / Primary ──────────────────────────────────────────────────────
  static const Color appetizingOrange = Color(0xFFE65100);
  static const Color amber = Color(0xFFFFB300);
  static const Color warmDarkGrey = Color(0xFF212121);
  static const Color lightWarmCream = Color(0xFFFFFDF9);

  // ─── Semantic / Status ────────────────────────────────────────────────────
  static const Color success = Color(0xFF2E7D32);
  static const Color warning = Color(0xFFF57C00);
  static const Color error = Color(0xFFC62828);
  static const Color info = Color(0xFF1565C0);

  // ─── Stock Badge Colors (AI Guide §7 & Feature 7) ─────────────────────────
  /// Green  → Safe stock level.
  static const Color stockSafe = Color(0xFF2E7D32);

  /// Orange → Below minimum threshold (Low Stock).
  static const Color stockLow = Color(0xFFF57C00);

  /// Red    → Risk of stockout within 24–48 h.
  static const Color stockCritical = Color(0xFFC62828);

  // ─── Background & Surface ─────────────────────────────────────────────────
  static const Color background = lightWarmCream;
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF5F0EB);
  static const Color surfaceElevated = Color(0xFFFAF6F1);

  // ─── On-Colors ────────────────────────────────────────────────────────────
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onBackground = warmDarkGrey;
  static const Color onSurface = warmDarkGrey;
  static const Color onError = Color(0xFFFFFFFF);

  // ─── Text ─────────────────────────────────────────────────────────────────
  static const Color textPrimary = warmDarkGrey;
  static const Color textSecondary = Color(0xFF6D6D6D);
  static const Color textHint = Color(0xFF9E9E9E);
  static const Color textDisabled = Color(0xFFBDBDBD);

  // ─── Borders & Dividers ───────────────────────────────────────────────────
  static const Color divider = Color(0xFFE0D5C8);
  static const Color border = Color(0xFFD4C5B5);
  static const Color borderFocused = appetizingOrange;

  // ─── Payment Method Accent Colors ─────────────────────────────────────────
  static const Color cashColor = Color(0xFF388E3C);
  static const Color qrCodeColor = Color(0xFF1565C0);
  static const Color bankTransferColor = Color(0xFF6A1B9A);

  // ─── Overlay & Shadow ─────────────────────────────────────────────────────
  static const Color scrim = Color(0x80000000);
  static const Color shadowLight = Color(0x1A000000);
}
