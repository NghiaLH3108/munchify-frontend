import 'package:dartz/dartz.dart';
import '../../../../core/errors/Failures.dart';
import '../repositories/promotion_repository.dart';

class TogglePromotionStatusUseCase {
  final PromotionRepository repository;

  TogglePromotionStatusUseCase(this.repository);

  Future<Either<Failure, bool>> call(String id) {
    return repository.togglePromotionStatus(id);
  }
}
