import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/product_entity.dart';
import '../repositories/product_repository.dart';
import '../../data/models/product_request_model.dart';

class UpdateProductUseCase {
  final ProductRepository repository;

  UpdateProductUseCase(this.repository);

  Future<Either<Failure, ProductEntity>> call(String id, ProductRequestModel request) {
    return repository.updateProduct(id, request);
  }
}
