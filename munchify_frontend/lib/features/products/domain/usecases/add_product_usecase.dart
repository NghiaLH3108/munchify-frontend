import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/product_entity.dart';
import '../repositories/product_repository.dart';
import '../../data/models/product_request_model.dart';

class AddProductUseCase {
  final ProductRepository repository;

  AddProductUseCase(this.repository);

  Future<Either<Failure, ProductEntity>> call(ProductRequestModel request) {
    return repository.addProduct(request);
  }
}
