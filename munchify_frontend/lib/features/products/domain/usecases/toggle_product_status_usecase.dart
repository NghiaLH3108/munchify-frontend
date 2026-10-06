import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/product_repository.dart';

class ToggleProductStatusUseCase {
  final ProductRepository repository;

  ToggleProductStatusUseCase(this.repository);

  Future<Either<Failure, void>> call(String id, bool isActive) {
    return repository.toggleProductStatus(id, isActive);
  }
}
