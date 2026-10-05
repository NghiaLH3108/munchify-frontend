import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_remote_data_source.dart';
import '../models/product_request_model.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource remoteDataSource;

  ProductRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<ProductEntity>>> getProducts({
    String? search,
    String? categoryId,
    bool? isActive,
    bool? lowStockWarning,
  }) async {
    try {
      final products = await remoteDataSource.getProducts(
        search: search,
        categoryId: categoryId,
        isActive: isActive,
        lowStockWarning: lowStockWarning,
      );
      return Right(products);
    } on DioException catch (e) {
      return Left(ServerFailure(message: e.message ?? 'Server Error'));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, ProductEntity>> addProduct(ProductRequestModel request) async {
    try {
      final product = await remoteDataSource.addProduct(request);
      return Right(product);
    } on DioException catch (e) {
      return Left(ServerFailure(message: e.message ?? 'Server Error'));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, ProductEntity>> updateProduct(String id, ProductRequestModel request) async {
    try {
      final product = await remoteDataSource.updateProduct(id, request);
      return Right(product);
    } on DioException catch (e) {
      return Left(ServerFailure(message: e.message ?? 'Server Error'));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> toggleProductStatus(String id, bool isActive) async {
    try {
      await remoteDataSource.toggleProductStatus(id, isActive);
      return const Right(null);
    } on DioException catch (e) {
      return Left(ServerFailure(message: e.message ?? 'Server Error'));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
