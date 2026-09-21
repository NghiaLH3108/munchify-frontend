/// Storage key constants for Munchify POS.
///
/// - Sensitive data (tokens, credentials) → use with `FlutterSecureStorage`.
/// - User preferences / offline cache      → use with `SharedPreferences`.
///
/// Never use raw string literals for storage keys outside this class.
class StorageKeys {
  StorageKeys._();

  // ─── Secure Storage (FlutterSecureStorage) ────────────────────────────────
  /// JWT Bearer token returned by POST /api/auth/login.
  static const String accessToken = 'access_token';

  /// Refresh token (if implemented by backend).
  static const String refreshToken = 'refresh_token';

  /// Decoded JWT role claim: 'ADMIN' or 'STAFF'.
  static const String userRole = 'user_role';

  /// Authenticated user's ID.
  static const String userId = 'user_id';

  /// Authenticated user's display name.
  static const String userName = 'user_name';

  // ─── SharedPreferences ────────────────────────────────────────────────────
  /// Pre-fill the username field on the login screen.
  static const String lastLoggedInUsername = 'last_logged_in_username';

  /// Remember the cashier's last selected payment method between sessions.
  static const String selectedPaymentMethod = 'selected_payment_method';

  /// Cached JSON string of product categories for offline display.
  static const String cachedCategories = 'cached_categories';

  /// Cached JSON string of products for offline display.
  static const String cachedProducts = 'cached_products';

  /// Unix timestamp (ms) when the product cache was last updated.
  static const String productCacheTimestamp = 'product_cache_timestamp';
}
