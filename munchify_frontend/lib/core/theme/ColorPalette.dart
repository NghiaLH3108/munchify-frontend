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

  // ─── Admin Web Dashboard (Mockup-aligned) ─────────────────────────────
  /// Cool grey background for admin web layout (#F3F4F6).
  static const Color webBgAdmin = Color(0xFFF3F4F6);

  /// Subtle border for card edges and dividers (#E2E8F0).
  static const Color borderSubtle = Color(0xFFE2E8F0);

  /// Muted text for secondary labels and hints (#64748B).
  static const Color textMuted = Color(0xFF64748B);

  /// Dark surface for sidebar background (#263143).
  static const Color inverseSurface = Color(0xFF263143);

  /// Elevated surface container for header backgrounds (#DEE8FF).
  static const Color surfaceContainerHigh = Color(0xFFDEE8FF);

  /// Primary-fixed tinted background for accent areas (#FFDBCF).
  static const Color primaryFixed = Color(0xFFFFDBCF);

  /// Primary container (button and card accent in HTML: #cd4700).
  static const Color primaryContainer = Color(0xFFCD4700);

  /// Primary light accent (#FF833A).
  static const Color primaryLight = Color(0xFFFF833A);

  /// Secondary color (#865300).
  static const Color secondary = Color(0xFF865300);

  /// Secondary container (#FDA625).
  static const Color secondaryContainer = Color(0xFFFDA625);

  /// Tertiary green (#186A22).
  static const Color tertiary = Color(0xFF186A22);

  /// Tertiary container green (#358438).
  static const Color tertiaryContainer = Color(0xFF358438);

  /// Tangerine warning (#F57C00).
  static const Color warningTangerine = Color(0xFFF57C00);

  /// Crimson danger (#D32F2F).
  static const Color dangerCrimson = Color(0xFFD32F2F);

  /// Surface dim text (#CFDAF2).
  static const Color surfaceDim = Color(0xFFCFDAF2);

  /// Pure white surface (#FFFFFF).
  static const Color surfaceWhite = Color(0xFFFFFFFF);

  /// On surface dark (#111C2D).
  static const Color onSurfaceDark = Color(0xFF111C2D);

  /// Deep purple accent for admin badges.
  static const Color adminPurple = Color(0xFF7C3AED);
}
