import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

// Auth
import 'features/auth/data/datasources/auth_local_data_source.dart';
import 'features/auth/data/datasources/auth_remote_data_source.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/domain/usecases/forgot_password_usecase.dart';
import 'features/auth/domain/usecases/get_current_user_usecase.dart';
import 'features/auth/domain/usecases/login_usecase.dart';
import 'features/auth/domain/usecases/logout_usecase.dart';
import 'features/auth/domain/usecases/reset_password_usecase.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';

import 'features/customers/data/datasources/customer_remote_data_source.dart';
import 'features/customers/data/repositories/customer_repository_impl.dart';
import 'features/customers/domain/repositories/customer_repository.dart';
import 'features/customers/domain/usecases/search_customer_usecase.dart';
import 'features/customers/domain/usecases/create_customer_usecase.dart';
import 'features/customers/domain/usecases/get_customers_usecase.dart';
import 'features/customers/domain/usecases/get_customer_point_history_usecase.dart';
import 'features/customers/presentation/bloc/customer_bloc.dart';
import 'features/customers/presentation/bloc/admin_customer_bloc.dart';

import 'core/network/DioClient.dart';
import 'core/network/NetworkInfo.dart';

// Categories
import 'features/categories/data/datasources/category_remote_data_source.dart';
import 'features/categories/data/repositories/category_repository_impl.dart';
import 'features/categories/domain/repositories/category_repository.dart';
import 'features/categories/domain/usecases/manage_category_usecases.dart';
import 'features/categories/presentation/bloc/category_bloc.dart';

// Suppliers
import 'features/suppliers/data/datasources/supplier_remote_data_source.dart';
import 'features/suppliers/data/repositories/supplier_repository_impl.dart';
import 'features/suppliers/domain/repositories/supplier_repository.dart';
import 'features/suppliers/domain/usecases/manage_supplier_usecases.dart';
import 'features/suppliers/presentation/bloc/supplier_bloc.dart';

// Units
import 'features/units/data/datasources/unit_remote_data_source.dart';
import 'features/units/data/repositories/unit_repository_impl.dart';
import 'features/units/domain/repositories/unit_repository.dart';
import 'features/units/domain/usecases/manage_unit_usecases.dart';
import 'features/units/presentation/bloc/unit_bloc.dart';

// Combos
import 'features/combos/data/datasources/combo_remote_data_source.dart';
import 'features/combos/data/repositories/combo_repository_impl.dart';
import 'features/combos/domain/repositories/combo_repository.dart';
import 'features/combos/domain/usecases/manage_combo_usecases.dart';
import 'features/combos/presentation/bloc/combo_bloc.dart';
import 'features/combos/presentation/bloc/combo_form_options_cubit.dart';
// Reports
import 'features/reports/data/datasources/report_remote_data_source.dart';
import 'features/reports/data/repositories/report_repository_impl.dart';
import 'features/reports/domain/repositories/report_repository.dart';
import 'features/reports/domain/usecases/report_usecases.dart';
import 'features/reports/presentation/bloc/report_bloc.dart';
// Staff
import 'features/staff/data/datasources/staff_remote_data_source.dart';
import 'features/staff/data/repositories/staff_repository_impl.dart';
import 'features/staff/domain/repositories/staff_repository.dart';
import 'features/staff/domain/usecases/create_staff_usecase.dart';
import 'features/staff/domain/usecases/get_staff_list_usecase.dart';
import 'features/staff/domain/usecases/toggle_staff_status_usecase.dart';
import 'features/staff/domain/usecases/update_staff_usecase.dart';
import 'features/staff/presentation/bloc/staff_bloc.dart';

// POS
import 'features/pos/data/datasources/pos_remote_data_source.dart';
import 'features/pos/data/repositories/pos_repository_impl.dart';
import 'features/pos/domain/repositories/pos_repository.dart';
import 'features/pos/domain/usecases/get_products_usecase.dart';
import 'features/pos/domain/usecases/get_combos_usecase.dart' as pos_uc;
import 'features/pos/presentation/bloc/pos_catalog_bloc.dart';

// POS – Cart & Orders
import 'features/pos/data/datasources/order_remote_data_source.dart';
import 'features/pos/data/datasources/promotion_remote_data_source.dart' as pos_promo;
import 'features/pos/data/repositories/order_repository_impl.dart';
import 'features/pos/data/repositories/promotion_repository_impl.dart' as pos_promo;
import 'features/pos/domain/repositories/order_repository.dart';
import 'features/pos/domain/repositories/promotion_repository.dart' as pos_promo;
import 'features/pos/domain/usecases/create_order_usecase.dart';
import 'features/pos/domain/usecases/get_orders_usecase.dart';
import 'features/pos/domain/usecases/apply_promotion_usecase.dart';
import 'features/pos/domain/usecases/get_active_promotions_usecase.dart';

// Admin Orders
import 'features/orders/data/datasources/admin_order_remote_datasource.dart';
import 'features/orders/data/repositories/admin_order_repository_impl.dart';
import 'features/orders/domain/repositories/admin_order_repository.dart';
import 'features/orders/domain/usecases/get_admin_orders_usecase.dart';
import 'features/orders/domain/usecases/get_admin_order_detail_usecase.dart';
import 'features/orders/presentation/bloc/admin_order_bloc.dart';
import 'features/pos/presentation/bloc/cart_cubit.dart';
import 'features/pos/presentation/bloc/order_bloc.dart';

// Inventory (Stock Imports & Movements)
import 'features/inventory/data/datasources/stock_remote_data_source.dart';
import 'features/inventory/data/repositories/stock_repository_impl.dart';
import 'features/inventory/domain/repositories/stock_repository.dart';
import 'features/inventory/domain/usecases/stock_import_use_cases.dart';
import 'features/inventory/presentation/bloc/stock_import_bloc.dart';

import 'features/inventory/data/datasources/inventory_remote_datasource.dart';
import 'features/inventory/data/repositories/inventory_repository_impl.dart';
import 'features/inventory/domain/repositories/inventory_repository.dart';
import 'features/inventory/domain/usecases/get_stock_movements_usecase.dart';
import 'features/inventory/domain/usecases/adjust_stock_usecase.dart';
import 'features/inventory/presentation/bloc/stock_movement_bloc.dart';

// Products Admin
import 'features/products/data/datasources/product_remote_data_source.dart';
import 'features/products/data/repositories/product_repository_impl.dart';
import 'features/products/domain/repositories/product_repository.dart';
import 'features/products/domain/usecases/get_products_usecase.dart' as admin_get_products;
import 'features/products/domain/usecases/add_product_usecase.dart';
import 'features/products/domain/usecases/update_product_usecase.dart';
import 'features/products/domain/usecases/toggle_product_status_usecase.dart';
import 'features/products/presentation/bloc/product_admin_bloc.dart';
import 'features/products/presentation/bloc/product_form_bloc.dart';
import 'features/inventory/presentation/bloc/ai_expiry/ai_expiry_bloc.dart';
import 'features/inventory/domain/usecases/get_pending_records_usecase.dart';
import 'features/inventory/domain/usecases/get_ai_expiry_summary_usecase.dart';
import 'features/inventory/domain/usecases/approve_record_usecase.dart';
import 'features/inventory/domain/usecases/analyze_damaged_expired_usecase.dart';
import 'features/inventory/domain/usecases/report_damaged_expired_usecase.dart';

import 'features/inventory/presentation/bloc/low_stock/low_stock_bloc.dart';
import 'features/inventory/domain/usecases/get_forecasting_usecase.dart';
import 'features/inventory/domain/usecases/generate_draft_imports_from_forecast_usecase.dart';

import 'features/promotions/data/datasources/promotion_remote_data_source.dart';
import 'features/promotions/data/repositories/promotion_repository_impl.dart';
import 'features/promotions/domain/repositories/promotion_repository.dart';
import 'features/promotions/domain/usecases/get_promotions_usecase.dart';
import 'features/promotions/domain/usecases/get_promotion_by_id_usecase.dart';
import 'features/promotions/domain/usecases/create_promotion_usecase.dart';
import 'features/promotions/domain/usecases/update_promotion_usecase.dart';
import 'features/promotions/domain/usecases/toggle_promotion_status_usecase.dart';
import 'features/promotions/presentation/bloc/promotion_admin_bloc.dart';
import 'features/promotions/presentation/bloc/promotion_form_bloc.dart';

final sl = GetIt.instance; // sl = Service Locator

Future<void> init() async {
  /// ==============================
  /// BLoC
  /// ==============================
  sl.registerFactory(
    () => AuthBloc(
      loginUseCase: sl(),
      logoutUseCase: sl(),
      getCurrentUserUseCase: sl(),
      forgotPasswordUseCase: sl(),
      resetPasswordUseCase: sl(),
      localDataSource: sl(),
    ),
  );

  sl.registerFactory(
    () => PromotionAdminBloc(
      getPromotionsUseCase: sl(),
      togglePromotionStatusUseCase: sl(),
    ),
  );

  sl.registerFactory(
    () => PromotionFormBloc(
      createPromotionUseCase: sl(),
      updatePromotionUseCase: sl(),
      getProductsUseCase: sl<admin_get_products.GetProductsUseCase>(),
    ),
  );

  sl.registerFactory(
    () => CustomerBloc(
      searchCustomer: sl(),
      createCustomer: sl(),
      ),
  );
  sl.registerFactory(
    () => AiExpiryBloc(
      getPendingRecordsUseCase: sl(),
      getAiExpirySummaryUseCase: sl(),
      approveRecordUseCase: sl(),
      reportDamagedExpiredUseCase: sl(),
    ),
  );

  sl.registerFactory(
    () => AdminCustomerBloc(
      getCustomersUseCase: sl(),
      getCustomerPointHistoryUseCase: sl(),
    ),
  );
  sl.registerFactory(
    () => LowStockBloc(
      getForecastingUseCase: sl(),
      generateDraftImportsFromForecastUseCase: sl(),
    ),
  );

  sl.registerFactory(
    () => StockImportBloc(
      getStockImportsUseCase: sl(),
      createDraftImportUseCase: sl(),
      completeImportUseCase: sl(),
      cancelImportUseCase: sl(),
    ),
  );

  sl.registerFactory(
    () => CategoryBloc(
      getCategories: sl(),
      createCategory: sl(),
      updateCategory: sl(),
      deleteCategory: sl(),
    ),
  );

  sl.registerFactory(
    () => SupplierBloc(
      getSuppliersUseCase: sl(),
      createSupplierUseCase: sl(),
      updateSupplierUseCase: sl(),
      deleteSupplierUseCase: sl(),
    ),
  );

  sl.registerFactory(
    () => UnitBloc(
      getUnits: sl(),
      createUnit: sl(),
      updateUnit: sl(),
      deleteUnit: sl(),
    ),
  );

  sl.registerFactory(
    () => ComboBloc(
      getCombos: sl(),
      createCombo: sl(),
      updateCombo: sl(),
      deleteCombo: sl(),
    ),
  );

  sl.registerFactory(
    () => ComboFormOptionsCubit(getFormOptions: sl()),
  );

  sl.registerFactory(
    () => ReportBloc(
      getRevenueSummary: sl(),
      getTopSelling: sl(),
      exportToExcel: sl(),
    ),
  );

  sl.registerFactory(
    () => StaffBloc(
      getStaffList: sl(),
      createStaff: sl(),
      updateStaff: sl(),
      toggleStaffStatus: sl(),
    ),
  );

  sl.registerFactory(
    () => PosCatalogBloc(
      getProductsUseCase: sl(),
      getCombosUseCase: sl(),
      repository: sl(),
    ),
  );

  sl.registerFactory(
    () => CartCubit(applyPromotionUseCase: sl()),
  );

  sl.registerFactory(
    () => OrderBloc(
      createOrderUseCase: sl(),
      getOrdersUseCase: sl(),
    ),
  );

  sl.registerFactory(
    () => AdminOrderBloc(
      getAdminOrdersUseCase: sl(),
      getAdminOrderDetailUseCase: sl(),
    ),
  );

  sl.registerFactory(
    () => StockMovementBloc(
      getStockMovementsUseCase: sl(),
      adjustStockUseCase: sl(),
    ),
  );

  sl.registerFactory(
    () => ProductAdminBloc(
      getProductsUseCase: sl(),
      toggleProductStatusUseCase: sl(),
    ),
  );

  sl.registerFactory(
    () => ProductFormBloc(
      addProductUseCase: sl(),
      updateProductUseCase: sl(),
    ),
  );

  /// ==============================
  /// Use Cases
  /// ==============================
  // Auth
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));
  sl.registerLazySingleton(() => GetCurrentUserUseCase(sl()));
  sl.registerLazySingleton(() => ForgotPasswordUseCase(sl()));
  sl.registerLazySingleton(() => ResetPasswordUseCase(sl()));

  // AI Expiry
  sl.registerLazySingleton(() => GetPendingRecordsUseCase(sl()));
  sl.registerLazySingleton(() => GetAiExpirySummaryUseCase(sl()));
  sl.registerLazySingleton(() => ApproveRecordUseCase(sl()));
  sl.registerLazySingleton(() => AnalyzeDamagedExpiredUseCase(sl()));
  sl.registerLazySingleton(() => ReportDamagedExpiredUseCase(sl()));

  // AI Low Stock
  sl.registerLazySingleton(() => GetForecastingUseCase(sl()));
  sl.registerLazySingleton(() => GenerateDraftImportsFromForecastUseCase(sl()));

  // Stock Import
  sl.registerLazySingleton(() => GetStockImportsUseCase(sl()));
  sl.registerLazySingleton(() => CreateDraftImportUseCase(sl()));
  sl.registerLazySingleton(() => CompleteImportUseCase(sl()));
  sl.registerLazySingleton(() => CancelImportUseCase(sl()));

  // Category
  sl.registerLazySingleton(() => GetCategoriesUseCase(sl()));
  sl.registerLazySingleton(() => CreateCategoryUseCase(sl()));
  sl.registerLazySingleton(() => UpdateCategoryUseCase(sl()));
  sl.registerLazySingleton(() => DeleteCategoryUseCase(sl()));

  // Supplier
  sl.registerLazySingleton(() => GetSuppliersUseCase(sl()));
  sl.registerLazySingleton(() => CreateSupplierUseCase(sl()));
  sl.registerLazySingleton(() => UpdateSupplierUseCase(sl()));
  sl.registerLazySingleton(() => DeleteSupplierUseCase(sl()));

  // Unit
  sl.registerLazySingleton(() => GetUnitsUseCase(sl()));
  sl.registerLazySingleton(() => CreateUnitUseCase(sl()));
  sl.registerLazySingleton(() => UpdateUnitUseCase(sl()));
  sl.registerLazySingleton(() => DeleteUnitUseCase(sl()));

  // Combo
  sl.registerLazySingleton(() => GetCombosUseCase(sl()));
  sl.registerLazySingleton(() => CreateComboUseCase(sl()));
  sl.registerLazySingleton(() => UpdateComboUseCase(sl()));
  sl.registerLazySingleton(() => DeleteComboUseCase(sl()));
  sl.registerLazySingleton(() => GetComboFormOptionsUseCase(sl()));

  // Reports
  sl.registerLazySingleton(() => GetRevenueSummaryUseCase(sl()));
  sl.registerLazySingleton(() => GetTopSellingUseCase(sl()));
  sl.registerLazySingleton(() => ExportReportToExcelUseCase(sl()));

  // Staff
  sl.registerLazySingleton(() => GetStaffListUseCase(sl()));
  sl.registerLazySingleton(() => CreateStaffUseCase(sl()));
  sl.registerLazySingleton(() => UpdateStaffUseCase(sl()));
  sl.registerLazySingleton(() => ToggleStaffStatusUseCase(sl()));

  // POS
  sl.registerLazySingleton(() => GetProductsUseCase(sl()));
  sl.registerLazySingleton(() => pos_uc.GetCombosUseCase(sl()));

  // POS – Orders & Promotions
  sl.registerLazySingleton(() => CreateOrderUseCase(sl()));
  sl.registerLazySingleton(() => GetOrdersUseCase(sl()));
  sl.registerLazySingleton(() => ApplyPromotionUseCase(sl()));
  sl.registerLazySingleton(() => GetActivePromotionsUseCase(sl()));
  sl.registerLazySingleton(() => GetAdminOrdersUseCase(sl()));
  sl.registerLazySingleton(() => GetAdminOrderDetailUseCase(sl()));

  // Customer
  sl.registerLazySingleton(() => SearchCustomerUseCase(sl()));
  sl.registerLazySingleton(() => CreateCustomerUseCase(sl()));
  sl.registerLazySingleton(() => GetCustomersUseCase(sl()));
  sl.registerLazySingleton(() => GetCustomerPointHistoryUseCase(sl()));

  // Inventory Movements
  sl.registerLazySingleton(() => GetStockMovementsUseCase(sl()));
  sl.registerLazySingleton(() => AdjustStockUseCase(sl()));

  // Products
  sl.registerLazySingleton(() => admin_get_products.GetProductsUseCase(sl()));
  sl.registerLazySingleton(() => AddProductUseCase(sl()));
  sl.registerLazySingleton(() => UpdateProductUseCase(sl()));
  sl.registerLazySingleton(() => ToggleProductStatusUseCase(sl()));

  // Promotions
  sl.registerLazySingleton(() => GetPromotionsUseCase(sl()));
  sl.registerLazySingleton(() => GetPromotionByIdUseCase(sl()));
  sl.registerLazySingleton(() => CreatePromotionUseCase(sl()));
  sl.registerLazySingleton(() => UpdatePromotionUseCase(sl()));
  sl.registerLazySingleton(() => TogglePromotionStatusUseCase(sl()));

  /// ==============================
  /// Repository
  /// ==============================
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
    ),
  );

  sl.registerLazySingleton<PromotionRepository>(
    () => PromotionRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerLazySingleton<StockRepository>(
    () => StockRepositoryImpl(remoteDataSource: sl()),
  );
  
  sl.registerLazySingleton<CategoryRepository>(
    () => CategoryRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerLazySingleton<SupplierRepository>(
    () => SupplierRepositoryImpl(
      remoteDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  sl.registerLazySingleton<UnitRepository>(
    () => UnitRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerLazySingleton<ReportRepository>(
    () => ReportRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerLazySingleton<ComboRepository>(
    () => ComboRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerLazySingleton<StaffRepository>(
    () => StaffRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerLazySingleton<PosRepository>(
    () => PosRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerLazySingleton<OrderRepository>(
    () => OrderRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerLazySingleton<AdminOrderRepository>(
    () => AdminOrderRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerLazySingleton<pos_promo.PromotionRepository>(
    () => pos_promo.PromotionRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerLazySingleton<CustomerRepository>(
    () => CustomerRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerLazySingleton<InventoryRepository>(
    () => InventoryRepositoryImpl(
      remoteDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  sl.registerLazySingleton<ProductRepository>(
    () => ProductRepositoryImpl(remoteDataSource: sl()),
  );

  /// ==============================
  /// Data Sources
  /// ==============================
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(dioClient: sl()),
  );

  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(secureStorage: sl()),
  );

  sl.registerLazySingleton<PromotionRemoteDataSource>(
    () => PromotionRemoteDataSourceImpl(dioClient: sl()),
  );

  sl.registerLazySingleton<StockRemoteDataSource>(
    () => StockRemoteDataSourceImpl(dioClient: sl()),
  );

  sl.registerLazySingleton<CategoryRemoteDataSource>(
    () => CategoryRemoteDataSourceImpl(dioClient: sl()),
  );

  sl.registerLazySingleton<SupplierRemoteDataSource>(
    () => SupplierRemoteDataSourceImpl(dioClient: sl()),
  );

  sl.registerLazySingleton<UnitRemoteDataSource>(
    () => UnitRemoteDataSourceImpl(dioClient: sl()),
  );

  sl.registerLazySingleton<ReportRemoteDataSource>(
    () => ReportRemoteDataSourceImpl(dioClient: sl()),
  );

  sl.registerLazySingleton<ComboRemoteDataSource>(
    () => ComboRemoteDataSourceImpl(dioClient: sl()),
  );

  sl.registerLazySingleton<StaffRemoteDataSource>(
    () => StaffRemoteDataSourceImpl(dioClient: sl()),
  );

  sl.registerLazySingleton<PosRemoteDataSource>(
    () => PosRemoteDataSourceImpl(dioClient: sl()),
  );

  sl.registerLazySingleton<OrderRemoteDataSource>(
    () => OrderRemoteDataSourceImpl(dioClient: sl()),
  );

  sl.registerLazySingleton<AdminOrderRemoteDataSource>(
    () => AdminOrderRemoteDataSourceImpl(dioClient: sl()),
  );

  sl.registerLazySingleton<pos_promo.PromotionRemoteDataSource>(
    () => pos_promo.PromotionRemoteDataSourceImpl(dioClient: sl()),
  );
  
  sl.registerLazySingleton<CustomerRemoteDataSource>(
    () => CustomerRemoteDataSourceImpl(dioClient: sl()),
  );

  sl.registerLazySingleton<InventoryRemoteDataSource>(
    () => InventoryRemoteDataSourceImpl(dioClient: sl()),
  );

  sl.registerLazySingleton<ProductRemoteDataSource>(
    () => ProductRemoteDataSourceImpl(dioClient: sl()),
  );

  /// ==============================
  /// Core / External
  /// ==============================
  sl.registerLazySingleton(() => const FlutterSecureStorage());
  
  sl.registerLazySingleton(() => DioClient(secureStorage: sl()));
  
  sl.registerLazySingleton<Dio>(
    () => sl<DioClient>().dio,
  );

  sl.registerLazySingleton(() => InternetConnection());
  
  sl.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(sl()),
  );
}
