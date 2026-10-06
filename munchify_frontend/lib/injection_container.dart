import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

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

// Units
import 'features/units/data/datasources/unit_remote_data_source.dart';
import 'features/units/data/repositories/unit_repository_impl.dart';
import 'features/units/domain/repositories/unit_repository.dart';
import 'features/units/domain/usecases/manage_unit_usecases.dart';
import 'features/units/presentation/bloc/unit_bloc.dart';

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
import 'features/pos/domain/usecases/get_combos_usecase.dart';
import 'features/pos/presentation/bloc/pos_catalog_bloc.dart';

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

final sl = GetIt.instance; // sl = Service Locator

Future<void> init() async {
  /// ==============================
  /// BLoC
  /// ==============================
  sl.registerFactory(
    () => CustomerBloc(
      searchCustomer: sl(),
      createCustomer: sl(),
    ),
  );

  sl.registerFactory(
    () => AdminCustomerBloc(
      getCustomersUseCase: sl(),
      getCustomerPointHistoryUseCase: sl(),
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
    () => UnitBloc(
      getUnits: sl(),
      createUnit: sl(),
      updateUnit: sl(),
      deleteUnit: sl(),
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
    () => StockMovementBloc(
      getStockMovementsUseCase: sl(),
      adjustStockUseCase: sl(),
    ),
  );

  /// ==============================
  /// Use Cases
  /// ==============================
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

  // Unit
  sl.registerLazySingleton(() => GetUnitsUseCase(sl()));
  sl.registerLazySingleton(() => CreateUnitUseCase(sl()));
  sl.registerLazySingleton(() => UpdateUnitUseCase(sl()));
  sl.registerLazySingleton(() => DeleteUnitUseCase(sl()));

  // Staff
  sl.registerLazySingleton(() => GetStaffListUseCase(sl()));
  sl.registerLazySingleton(() => CreateStaffUseCase(sl()));
  sl.registerLazySingleton(() => UpdateStaffUseCase(sl()));
  sl.registerLazySingleton(() => ToggleStaffStatusUseCase(sl()));

  // POS
  sl.registerLazySingleton(() => GetProductsUseCase(sl()));
  sl.registerLazySingleton(() => GetCombosUseCase(sl()));

  // Customer
  sl.registerLazySingleton(() => SearchCustomerUseCase(sl()));
  sl.registerLazySingleton(() => CreateCustomerUseCase(sl()));
  sl.registerLazySingleton(() => GetCustomersUseCase(sl()));
  sl.registerLazySingleton(() => GetCustomerPointHistoryUseCase(sl()));

  // Inventory Movements
  sl.registerLazySingleton(() => GetStockMovementsUseCase(sl()));
  sl.registerLazySingleton(() => AdjustStockUseCase(sl()));

  /// ==============================
  /// Repository
  /// ==============================
  sl.registerLazySingleton<StockRepository>(
    () => StockRepositoryImpl(remoteDataSource: sl()),
  );
  
  sl.registerLazySingleton<CategoryRepository>(
    () => CategoryRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerLazySingleton<UnitRepository>(
    () => UnitRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerLazySingleton<StaffRepository>(
    () => StaffRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerLazySingleton<PosRepository>(
    () => PosRepositoryImpl(remoteDataSource: sl()),
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

  /// ==============================
  /// Data Sources
  /// ==============================
  sl.registerLazySingleton<StockRemoteDataSource>(
    () => StockRemoteDataSourceImpl(dio: sl()),
  );

  sl.registerLazySingleton<CategoryRemoteDataSource>(
    () => CategoryRemoteDataSourceImpl(dioClient: sl()),
  );

  sl.registerLazySingleton<UnitRemoteDataSource>(
    () => UnitRemoteDataSourceImpl(dioClient: sl()),
  );

  sl.registerLazySingleton<StaffRemoteDataSource>(
    () => StaffRemoteDataSourceImpl(dioClient: sl()),
  );

  sl.registerLazySingleton<PosRemoteDataSource>(
    () => PosRemoteDataSourceImpl(dioClient: sl()),
  );
  
  sl.registerLazySingleton<CustomerRemoteDataSource>(
    () => CustomerRemoteDataSourceImpl(dioClient: sl()),
  );

  sl.registerLazySingleton<InventoryRemoteDataSource>(
    () => InventoryRemoteDataSourceImpl(dioClient: sl()),
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
