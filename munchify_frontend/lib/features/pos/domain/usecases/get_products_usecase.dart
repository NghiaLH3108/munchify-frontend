import 'package:dartz/dartz.dart';
import '../../../../core/errors/Failures.dart';
import '../entities/product_entity.dart';
import '../repositories/pos_repository.dart';

class GetProductsUseCase {
  final PosRepository repository;

  GetProductsUseCase(this.repository);

  Future<Either<Failure, List<ProductEntity>>> execute({
    String? searchTerm,
    int? categoryId,
  }) async {
    return await repository.getProducts(
      searchTerm: searchTerm,
      categoryId: categoryId,
    );
  }
}
