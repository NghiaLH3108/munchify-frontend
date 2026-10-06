/// Centralized API endpoint constants for Munchify POS.
///
/// **Rule:** All URL strings MUST be declared here.
/// DataSource classes must reference `ApiEndpoints.*` — never hardcode path strings.
class ApiEndpoints {
  ApiEndpoints._();

  // ─── Authentication ────────────────────────────────────────────────────────
  static const String login = '/api/auth/login';
  static const String me = '/api/auth/me';
  static const String users = '/api/users';

  // ─── Catalog ───────────────────────────────────────────────────────────────
  static const String categories = '/api/categories';
  static const String products = '/api/products';
  static const String productsForStock = '/api/products/for-stock';
  static const String units = '/api/units';

  // ─── Orders & POS ─────────────────────────────────────────────────────────
  static const String orders = '/api/orders';

  // ─── Customers ────────────────────────────────────────────────────────────
  static const String customers = '/api/customers';

  // ─── Promotions ───────────────────────────────────────────────────────────
  static const String promotions = '/api/promotions';

  // ─── Inventory & Stock ────────────────────────────────────────────────────
  static const String stockImports = '/api/stock-imports';
  static const String stockMovements = '/api/stock-movements';
  static const String adjustStock = '/api/stock-movements';
  static const String suppliers = '/api/suppliers';

  // ─── AI Forecasting ───────────────────────────────────────────────────────
  /// GET  → Returns ForecastEntity list for the Forecast Dashboard.
  static const String forecasting = '/api/inventory/forecasting';

  /// POST → Backend auto-groups by supplier and creates DRAFT StockImport records.
  static const String generateFromForecast = '/api/stock-imports/generate-from-forecast';

  // ─── Reports / Analytics ──────────────────────────────────────────────────
  static const String reports = '/api/reports';

  // ─── AI Expiry Insights ───────────────────────────────────────────────────
  static const String damagedExpiredRecords = '/api/DamagedExpiredRecords';
  static String damagedExpiredPending() => '$damagedExpiredRecords/pending';
  static String damagedExpiredSummaryMetrics() => '$damagedExpiredRecords/summary-metrics';
  static String damagedExpiredApprove(dynamic id) => '$damagedExpiredRecords/$id/approve';
  static String damagedExpiredReject(dynamic id) => '$damagedExpiredRecords/$id/reject';

  // ─── Helpers ──────────────────────────────────────────────────────────────
  /// Build a parameterised path, e.g. stockImportById(3) → '/api/stock-imports/3'
  static String stockImportById(dynamic id) => '$stockImports/$id';
  static String stockImportComplete(dynamic id) => '$stockImports/$id/complete';
  static String productById(dynamic id) => '$products/$id';
  static String customerById(dynamic id) => '$customers/$id';
  static String orderById(dynamic id) => '$orders/$id';
}
