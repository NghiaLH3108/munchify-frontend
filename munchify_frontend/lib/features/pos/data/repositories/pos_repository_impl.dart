import 'package:dartz/dartz.dart';
import '../../../../core/errors/Failures.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/repositories/pos_repository.dart';
import '../datasources/pos_remote_data_source.dart';

class PosRepositoryImpl implements PosRepository {
  final PosRemoteDataSource remoteDataSource;

  PosRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<CategoryEntity>>> getCategories() async {
    try {
      final categories = await remoteDataSource.getCategories();
      return Right(categories);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ProductEntity>>> getProducts({
    String? searchTerm,
    int? categoryId,
  }) async {
    try {
      final products = await remoteDataSource.getProducts(
        searchTerm: searchTerm,
        categoryId: categoryId,
      );
      return Right(products);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ProductEntity>>> getCombos() async {
    try {
      final combos = await remoteDataSource.getCombos();
      return Right(combos);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
