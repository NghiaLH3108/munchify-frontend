import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'core/network/DioClient.dart';
import 'core/theme/AppTheme.dart';
import 'features/categories/data/datasources/category_remote_data_source.dart';
import 'features/categories/data/repositories/category_repository_impl.dart';
import 'features/categories/domain/usecases/manage_category_usecases.dart';
import 'features/categories/presentation/bloc/category_bloc.dart';
import 'features/categories/presentation/screens/manage_categories_screen.dart';

void main() {
  // 1. Khởi tạo các dependencies (sau này có thể chuyển sang get_it)
  const secureStorage = FlutterSecureStorage();
  final dioClient = DioClient(secureStorage: secureStorage);
  
  final categoryRemoteDataSource = CategoryRemoteDataSourceImpl(dio: dioClient.dio);
  final categoryRepository = CategoryRepositoryImpl(remoteDataSource: categoryRemoteDataSource);

  final getCategoriesUseCase = GetCategoriesUseCase(categoryRepository);
  final createCategoryUseCase = CreateCategoryUseCase(categoryRepository);
  final updateCategoryUseCase = UpdateCategoryUseCase(categoryRepository);
  final deleteCategoryUseCase = DeleteCategoryUseCase(categoryRepository);

  runApp(MyApp(
    categoryBloc: CategoryBloc(
      getCategories: getCategoriesUseCase,
      createCategory: createCategoryUseCase,
      updateCategory: updateCategoryUseCase,
      deleteCategory: deleteCategoryUseCase,
    ),
  ));
}

class MyApp extends StatelessWidget {
  final CategoryBloc categoryBloc;

  const MyApp({super.key, required this.categoryBloc});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: categoryBloc,
      child: MaterialApp(
        title: 'Munchify POS',
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        home: const ManageCategoriesScreen(),
      ),
    );
  }
}
