import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/Failures.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/repositories/category_repository.dart';
import '../datasources/category_remote_data_source.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final CategoryRemoteDataSource remoteDataSource;

  CategoryRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<CategoryEntity>>> getCategories({
    String searchTerm = '',
    bool? isActive,
    int page = 1,
    int pageSize = 10,
  }) async {
    try {
      final result = await remoteDataSource.getCategories(
        searchTerm: searchTerm,
        isActive: isActive,
        page: page,
        pageSize: pageSize,
      );
      return Right(result);
    } on DioException catch (e) {
      return Left(ServerFailure(message: e.error?.toString() ?? e.message ?? 'Lỗi kết nối máy chủ'));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, CategoryEntity>> getCategoryById(int id) async {
    try {
      final result = await remoteDataSource.getCategoryById(id);
      return Right(result);
    } on DioException catch (e) {
      return Left(ServerFailure(message: e.error?.toString() ?? e.message ?? 'Lỗi kết nối máy chủ'));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, CategoryEntity>> createCategory({
    required String categoryName,
    String? description,
    required bool isActive,
  }) async {
    try {
      final result = await remoteDataSource.createCategory(
        categoryName: categoryName,
        description: description,
        isActive: isActive,
      );
      return Right(result);
    } on DioException catch (e) {
      return Left(ServerFailure(message: e.error?.toString() ?? e.message ?? 'Lỗi kết nối máy chủ'));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, CategoryEntity>> updateCategory({
    required int id,
    required String categoryName,
    String? description,
    required bool isActive,
  }) async {
    try {
      final result = await remoteDataSource.updateCategory(
        id: id,
        categoryName: categoryName,
        description: description,
        isActive: isActive,
      );
      return Right(result);
    } on DioException catch (e) {
      return Left(ServerFailure(message: e.error?.toString() ?? e.message ?? 'Lỗi kết nối máy chủ'));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteCategory(int id) async {
    try {
      final result = await remoteDataSource.deleteCategory(id);
      return Right(result);
    } on DioException catch (e) {
      return Left(ServerFailure(message: e.error?.toString() ?? e.message ?? 'Lỗi kết nối máy chủ'));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }
}
