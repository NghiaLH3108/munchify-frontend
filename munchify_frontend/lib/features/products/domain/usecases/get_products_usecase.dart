import 'package:dartz/dartz.dart';
import '../../../../core/errors/Failures.dart';
import '../entities/product_entity.dart';
import '../repositories/product_repository.dart';

class GetProductsUseCase {
  final ProductRepository repository;

  GetProductsUseCase(this.repository);

  Future<Either<Failure, List<ProductEntity>>> call({
    String? search,
    String? categoryId,
    bool? isActive,
    bool? lowStockWarning,
  }) {
    return repository.getProducts(
      search: search,
      categoryId: categoryId,
      isActive: isActive,
      lowStockWarning: lowStockWarning,
    );
  }
}
