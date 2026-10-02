import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'core/constants/AppConstants.dart';


import 'features/inventory/data/datasources/stock_remote_data_source.dart';
import 'features/inventory/data/repositories/stock_repository_impl.dart';
import 'features/inventory/domain/repositories/stock_repository.dart';
import 'features/inventory/domain/usecases/stock_import_use_cases.dart';
import 'features/inventory/presentation/bloc/stock_import_bloc.dart';

final sl = GetIt.instance; // sl = Service Locator

Future<void> init() async {
  /// ==============================
  /// BLoC
  /// ==============================
  sl.registerFactory(
    () => StockImportBloc(
      getStockImportsUseCase: sl(),
      createDraftImportUseCase: sl(),
      completeImportUseCase: sl(),
      cancelImportUseCase: sl(),
    ),
  );

  /// ==============================
  /// Use Cases
  /// ==============================
  sl.registerLazySingleton(() => GetStockImportsUseCase(sl()));
  sl.registerLazySingleton(() => CreateDraftImportUseCase(sl()));
  sl.registerLazySingleton(() => CompleteImportUseCase(sl()));
  sl.registerLazySingleton(() => CancelImportUseCase(sl()));

  /// ==============================
  /// Repository
  /// ==============================
  sl.registerLazySingleton<StockRepository>(
    () => StockRepositoryImpl(remoteDataSource: sl()),
  );

  /// ==============================
  /// Data Sources
  /// ==============================
  sl.registerLazySingleton<StockRemoteDataSource>(
    () => StockRemoteDataSourceImpl(dio: sl()),
  );

  /// ==============================
  /// Core / External
  /// ==============================
  // Dio
  sl.registerLazySingleton(
    () => Dio(BaseOptions(baseUrl: AppConstants.baseUrl)),
  );
}
