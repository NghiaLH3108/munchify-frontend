import 'package:intl/intl.dart';

import '../constants/AppConstants.dart';

/// Vietnamese Dong (VNĐ) currency formatting utilities.
///
/// AI Guide §6 mandates:
///   `NumberFormat.currency(locale: 'vi_VN', symbol: '₫')`
///   Output example: `100.000 ₫`
///
/// Usage:
/// ```dart
/// CurrencyFormatter.format(100000); // → '100.000 ₫'
/// CurrencyFormatter.formatPointsToVnd(50); // → '50.000 ₫'
/// ```
class CurrencyFormatter {
  CurrencyFormatter._();

  static final NumberFormat _vndFormatter = NumberFormat.currency(
    locale: 'vi_VN',
    symbol: '₫',
    decimalDigits: 0,
  );

  static final NumberFormat _noSymbolFormatter = NumberFormat(
    '#,###',
    'vi_VN',
  );

  // ─── Public API ───────────────────────────────────────────────────────────

  /// Format [amount] as Vietnamese Dong with symbol.
  ///
  /// Example: `format(100000)` → `'100.000 ₫'`
  static String format(num amount) => _vndFormatter.format(amount);

  /// Format [amount] without the ₫ symbol — useful for input fields.
  ///
  /// Example: `formatNoSymbol(100000)` → `'100.000'`
  static String formatNoSymbol(num amount) =>
      _noSymbolFormatter.format(amount);

  /// Convert loyalty [points] to their VNĐ discount equivalent and format.
  ///
  /// Rule (AI Guide §7.3): 1 point = [AppConstants.pointsToVndRate] VNĐ.
  ///
  /// Example: `formatPointsToVnd(50)` → `'50.000 ₫'`
  static String formatPointsToVnd(int points) =>
      format(points * AppConstants.pointsToVndRate);

  /// Parse a formatted VNĐ string back to a [double].
  ///
  /// Returns `null` if [value] cannot be parsed.
  ///
  /// Example: `parse('100.000 ₫')` → `100000.0`
  static double? parse(String value) {
    try {
      final cleaned = value
          .replaceAll('₫', '')
          .replaceAll('.', '')
          .replaceAll(',', '')
          .trim();
      return double.parse(cleaned);
    } catch (_) {
      return null;
    }
  }

  /// Format a compact number for metric cards (e.g. dashboard).
  ///
  /// Example: `compact(1500000)` → `'1,5 tr'`
  static String compact(num amount) {
    if (amount >= 1000000000) {
      return '${(amount / 1000000000).toStringAsFixed(1)} tỷ';
    }
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)} tr';
    }
    if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(0)}k';
    }
    return format(amount);
  }
}
