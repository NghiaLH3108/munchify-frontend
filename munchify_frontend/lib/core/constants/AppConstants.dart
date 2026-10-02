import 'package:flutter/foundation.dart';

/// App-wide configuration constants for Munchify POS.
/// Add all magic values and hard-coded config here — never inline them elsewhere.
class AppConstants {
  AppConstants._();

  // ─── App Info ──────────────────────────────────────────────────────────────
  static const String appName = 'Munchify POS';
  static const String appVersion = '1.0.0';

  // ─── Base URL ──────────────────────────────────────────────────────────────
  /// Android emulator → host machine localhost.
  /// Change to your real staging/production URL before deploying.
  /// Web / Windows Desktop: https://localhost:<port_backend>
  /// Android Emulator: https://10.0.2.2:<port_backend>

  static String get baseUrl {
    if (kIsWeb) return 'http://localhost:5194';
    if (defaultTargetPlatform == TargetPlatform.android) return 'http://10.0.2.2:5194';
    return 'http://localhost:5194';
  }

  // ─── HTTP Timeouts (milliseconds) ─────────────────────────────────────────
  static const int connectTimeoutMs = 15000;
  static const int receiveTimeoutMs = 15000;
  static const int sendTimeoutMs = 15000;

  // ─── User Roles ────────────────────────────────────────────────────────────
  /// JWT claim value for the Administrator role.
  static const String roleAdmin = 'ADMIN';

  /// JWT claim value for the Staff (cashier) role.
  static const String roleStaff = 'STAFF';

  // ─── Loyalty Points ────────────────────────────────────────────────────────
  /// Exchange rate: 1 loyalty point = 1,000 VNĐ discount.
  static const int pointsToVndRate = 1000;

  // ─── POS UX ────────────────────────────────────────────────────────────────
  /// Debounce delay for customer search input (ms).
  static const int searchDebounceMs = 300;

  /// Minimum touch target size in logical pixels (WCAG / Material guideline).
  static const double minTouchTargetDp = 48.0;

  // ─── Pagination ────────────────────────────────────────────────────────────
  static const int defaultPageSize = 20;

  // ─── Quick-Cash Buttons ────────────────────────────────────────────────────
  /// Preset denominations shown on the checkout screen's cash-tendered helper.
  static const List<int> quickCashAmounts = [50000, 100000, 200000, 500000];

  // ─── Payment Method Identifiers ────────────────────────────────────────────
  static const String paymentCash = 'CASH';
  static const String paymentQrCode = 'QR_CODE';
  static const String paymentBankTransfer = 'BANK_TRANSFER';

  // ─── Stock Movement Types ──────────────────────────────────────────────────
  static const String movementAdjustment = 'ADJUSTMENT';
  static const String movementDamage = 'DAMAGE';
}
