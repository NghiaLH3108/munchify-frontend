import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'core/network/DioClient.dart';
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

// POS Imports
import 'features/pos/data/datasources/pos_remote_data_source.dart';
import 'features/pos/data/repositories/pos_repository_impl.dart';
import 'features/pos/domain/usecases/get_products_usecase.dart';
import 'features/pos/presentation/bloc/pos_catalog_bloc.dart';
import 'features/pos/presentation/bloc/pos_catalog_event.dart';
import 'features/pos/presentation/screens/pos_home_screen.dart';

void main() {
  // 1. Khởi tạo các dependencies (sau này có thể chuyển sang get_it)
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
      )..add(LoadCatalogEvent()), // Tự động load dữ liệu khi mở app
    ),
  );
}

class MyApp extends StatelessWidget {
  final CategoryBloc categoryBloc;
  final StaffBloc staffBloc;
  final PosCatalogBloc posCatalogBloc;

  const MyApp({
    super.key, 
    required this.categoryBloc, 
    required this.staffBloc,
    required this.posCatalogBloc,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: categoryBloc),
        BlocProvider.value(value: staffBloc),
        BlocProvider.value(value: posCatalogBloc),
      ],
      child: MaterialApp(
        title: 'Munchify POS',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const PosHomeScreen(), // Đổi sang màn hình POS
      ),
    );
  }
}
