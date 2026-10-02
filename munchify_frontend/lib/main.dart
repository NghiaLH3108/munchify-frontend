import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

import 'core/network/DioClient.dart';
import 'core/network/NetworkInfo.dart';
import 'core/theme/AppTheme.dart';
import 'features/admin/presentation/pages/admin_shell_screen.dart';
import 'features/categories/data/datasources/category_remote_data_source.dart';
import 'features/categories/data/repositories/category_repository_impl.dart';
import 'features/categories/domain/usecases/manage_category_usecases.dart';
import 'features/categories/presentation/bloc/category_bloc.dart';
import 'features/staff/data/datasources/staff_remote_data_source.dart';
import 'features/staff/data/repositories/staff_repository_impl.dart';
import 'features/staff/domain/usecases/create_staff_usecase.dart';
import 'features/staff/domain/usecases/get_staff_list_usecase.dart';
import 'features/staff/domain/usecases/toggle_staff_status_usecase.dart';
import 'features/staff/domain/usecases/update_staff_usecase.dart';
import 'features/staff/presentation/bloc/staff_bloc.dart';
import 'features/inventory/data/datasources/inventory_remote_datasource.dart';
import 'features/inventory/data/repositories/inventory_repository_impl.dart';
import 'features/inventory/domain/usecases/get_stock_movements_usecase.dart';
import 'features/inventory/domain/usecases/adjust_stock_usecase.dart';
import 'features/inventory/presentation/bloc/stock_movement_bloc.dart';
import 'features/inventory/presentation/bloc/stock_import_bloc.dart';
import 'features/inventory/presentation/screens/inventory_screen.dart';

// POS Imports
import 'features/pos/data/datasources/pos_remote_data_source.dart';
import 'features/pos/data/repositories/pos_repository_impl.dart';
import 'features/pos/domain/usecases/get_products_usecase.dart';
import 'features/pos/presentation/bloc/pos_catalog_bloc.dart';
import 'features/pos/presentation/bloc/pos_catalog_event.dart';
import 'features/pos/presentation/screens/pos_home_screen.dart';

// Customer Imports
import 'features/customers/data/datasources/customer_remote_data_source.dart';
import 'features/customers/data/repositories/customer_repository_impl.dart';
import 'features/customers/domain/usecases/search_customer_usecase.dart';
import 'features/customers/domain/usecases/create_customer_usecase.dart';
import 'features/customers/domain/usecases/get_customers_usecase.dart';
import 'features/customers/domain/usecases/get_customer_point_history_usecase.dart';
import 'features/customers/presentation/bloc/customer_bloc.dart';
import 'features/customers/presentation/bloc/admin_customer_bloc.dart';

import 'injection_container.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await di.init();

  // 1. Khởi tạo các dependencies
  const secureStorage = FlutterSecureStorage();
  final dioClient = DioClient(secureStorage: secureStorage);

  // Category dependencies
  final categoryRemoteDataSource = CategoryRemoteDataSourceImpl(
    dioClient: dioClient,
  );
  final categoryRepository = CategoryRepositoryImpl(
    remoteDataSource: categoryRemoteDataSource,
  );
  final getCategoriesUseCase = GetCategoriesUseCase(categoryRepository);
  final createCategoryUseCase = CreateCategoryUseCase(categoryRepository);
  final updateCategoryUseCase = UpdateCategoryUseCase(categoryRepository);
  final deleteCategoryUseCase = DeleteCategoryUseCase(categoryRepository);

  // Staff dependencies
  final staffRemoteDataSource = StaffRemoteDataSourceImpl(dioClient: dioClient);
  final staffRepository = StaffRepositoryImpl(
    remoteDataSource: staffRemoteDataSource,
  );

  // POS dependencies
  final posRemoteDataSource = PosRemoteDataSourceImpl(dio: dioClient.dio); 
  final posRepository = PosRepositoryImpl(remoteDataSource: posRemoteDataSource);
  final getProductsUseCase = GetProductsUseCase(posRepository);

  // Inventory dependencies
  final networkInfo = NetworkInfoImpl(InternetConnection());
  final inventoryRemoteDataSource = InventoryRemoteDataSourceImpl(dioClient: dioClient);
  final inventoryRepository = InventoryRepositoryImpl(
    remoteDataSource: inventoryRemoteDataSource,
    networkInfo: networkInfo,
  );
  final getStockMovementsUseCase = GetStockMovementsUseCase(inventoryRepository);
  final adjustStockUseCase = AdjustStockUseCase(inventoryRepository);

  // Customer dependencies
  final customerRemoteDataSource = CustomerRemoteDataSourceImpl(dioClient: dioClient);
  final customerRepository = CustomerRepositoryImpl(remoteDataSource: customerRemoteDataSource);
  final searchCustomerUseCase = SearchCustomerUseCase(customerRepository);
  final createCustomerUseCase = CreateCustomerUseCase(customerRepository);
  final getCustomersUseCase = GetCustomersUseCase(customerRepository);
  final getCustomerPointHistoryUseCase = GetCustomerPointHistoryUseCase(customerRepository);

  runApp(
    MyApp(
      categoryBloc: CategoryBloc(
        getCategories: getCategoriesUseCase,
        createCategory: createCategoryUseCase,
        updateCategory: updateCategoryUseCase,
        deleteCategory: deleteCategoryUseCase,
      ),
      staffBloc: StaffBloc(
        getStaffList: GetStaffListUseCase(staffRepository),
        createStaff: CreateStaffUseCase(staffRepository),
        updateStaff: UpdateStaffUseCase(staffRepository),
        toggleStaffStatus: ToggleStaffStatusUseCase(staffRepository),
      ),
      posCatalogBloc: PosCatalogBloc(
        getProductsUseCase: getProductsUseCase,
        repository: posRepository,
      )..add(LoadCatalogEvent()),
      stockMovementBloc: StockMovementBloc(
        getStockMovementsUseCase: getStockMovementsUseCase,
        adjustStockUseCase: adjustStockUseCase,
      ),
      customerBloc: CustomerBloc(
        searchCustomer: searchCustomerUseCase,
        createCustomer: createCustomerUseCase,
      ),
      adminCustomerBloc: AdminCustomerBloc(
        getCustomersUseCase: getCustomersUseCase,
        getCustomerPointHistoryUseCase: getCustomerPointHistoryUseCase,
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  final CategoryBloc categoryBloc;
  final StaffBloc staffBloc;
  final PosCatalogBloc posCatalogBloc;
  final StockMovementBloc stockMovementBloc;
  final CustomerBloc customerBloc;
  final AdminCustomerBloc adminCustomerBloc;

  const MyApp({
    super.key, 
    required this.categoryBloc, 
    required this.staffBloc,
    required this.posCatalogBloc,
    required this.stockMovementBloc,
    required this.customerBloc,
    required this.adminCustomerBloc,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: categoryBloc),
        BlocProvider.value(value: staffBloc),
        BlocProvider.value(value: posCatalogBloc),
        BlocProvider.value(value: stockMovementBloc),
        BlocProvider.value(value: customerBloc),
        BlocProvider.value(value: adminCustomerBloc),
        BlocProvider<StockImportBloc>(
          create: (_) => di.sl<StockImportBloc>(),
        ),
      ],
      child: MaterialApp(
        title: 'Munchify POS',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
         home: const AdminShellScreen(initialTab: 'loyalty'), // Đổi sang Web Admin
//            home: const PosHomeScreen(),
      ),
    );
  }
}
