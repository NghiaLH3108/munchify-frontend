import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/product_entity.dart';
import '../../data/models/product_request_model.dart';

abstract class ProductRepository {
  Future<Either<Failure, List<ProductEntity>>> getProducts({
    String? search,
    String? categoryId,
    bool? isActive,
    bool? lowStockWarning,
  });
  
  Future<Either<Failure, ProductEntity>> addProduct(ProductRequestModel request);
  
  Future<Either<Failure, ProductEntity>> updateProduct(String id, ProductRequestModel request);
  
  Future<Either<Failure, void>> toggleProductStatus(String id, bool isActive);
}
