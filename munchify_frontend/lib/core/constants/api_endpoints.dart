class ApiEndpoints {
  // Auth
  static const String login           = '/api/auth/login';
  static const String me              = '/api/auth/me';

  // Catalog
  static const String categories      = '/api/categories';
  static const String products        = '/api/products';
  static const String units           = '/api/units';

  // Orders & POS
  static const String orders          = '/api/orders';

  // Customers
  static const String customers       = '/api/customers';

  // Promotions
  static const String promotions      = '/api/promotions';

  // Inventory & Stock
  static const String stockImports    = '/api/stock-imports';
  static const String stockMovements  = '/api/stock-movements';
  static const String suppliers       = '/api/suppliers';

  // AI Forecasting
  static const String forecasting             = '/api/inventory/forecasting';
  static const String generateFromForecast    = '/api/stock-imports/generate-from-forecast';

  // Reports
  static const String reports         = '/api/reports';
}
