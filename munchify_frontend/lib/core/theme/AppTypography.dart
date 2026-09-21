import 'package:flutter/material.dart';

import 'ColorPalette.dart';

/// Munchify POS typography scale.
///
/// All text styles use the `Inter` font family (add to pubspec.yaml via
/// google_fonts or bundled assets). Every style is `const` for performance.
///
/// Usage:
/// ```dart
/// Text('Total', style: AppTypography.priceText);
/// ```
class AppTypography {
  AppTypography._();

  static const String _fontFamily = 'Inter';

  // ─── Display ──────────────────────────────────────────────────────────────
  static const TextStyle displayLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: ColorPalette.textPrimary,
    letterSpacing: -0.5,
    height: 1.2,
  );

  static const TextStyle displayMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: ColorPalette.textPrimary,
    letterSpacing: -0.25,
    height: 1.25,
  );

  // ─── Headline ─────────────────────────────────────────────────────────────
  static const TextStyle headlineLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: ColorPalette.textPrimary,
    height: 1.3,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: ColorPalette.textPrimary,
    height: 1.3,
  );

  static const TextStyle headlineSmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: ColorPalette.textPrimary,
    height: 1.35,
  );

  // ─── Title ────────────────────────────────────────────────────────────────
  static const TextStyle titleLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: ColorPalette.textPrimary,
    height: 1.4,
  );

  static const TextStyle titleMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: ColorPalette.textPrimary,
    height: 1.4,
  );

  static const TextStyle titleSmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: ColorPalette.textPrimary,
    height: 1.4,
  );

  // ─── Body ─────────────────────────────────────────────────────────────────
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: ColorPalette.textPrimary,
    height: 1.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: ColorPalette.textPrimary,
    height: 1.5,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: ColorPalette.textSecondary,
    height: 1.5,
  );

  // ─── Label ────────────────────────────────────────────────────────────────
  static const TextStyle labelLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: ColorPalette.textPrimary,
    letterSpacing: 0.25,
    height: 1.4,
  );

  static const TextStyle labelMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: ColorPalette.textSecondary,
    letterSpacing: 0.25,
    height: 1.4,
  );

  static const TextStyle labelSmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: ColorPalette.textSecondary,
    letterSpacing: 0.5,
    height: 1.4,
  );

  // ─── Domain-Specific Styles ───────────────────────────────────────────────

  /// Product price in product cards and cart.
  static const TextStyle priceText = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: ColorPalette.appetizingOrange,
    height: 1.3,
  );

  /// Large price display on checkout / bill summary.
  static const TextStyle priceLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w800,
    color: ColorPalette.appetizingOrange,
    height: 1.2,
  );

  /// Total amount on receipt / checkout summary.
  static const TextStyle priceXLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 32,
    fontWeight: FontWeight.w800,
    color: ColorPalette.appetizingOrange,
    letterSpacing: -0.5,
    height: 1.1,
  );

  /// Badge text for stock chips (Low Stock / Out of Stock / Safe).
  static const TextStyle badgeText = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 10,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.5,
    height: 1.2,
  );
}
