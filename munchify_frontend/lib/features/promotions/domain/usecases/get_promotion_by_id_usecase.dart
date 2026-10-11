import 'package:dartz/dartz.dart';
import '../../../../core/errors/Failures.dart';
import '../entities/promotion_entity.dart';
import '../repositories/promotion_repository.dart';

class GetPromotionByIdUseCase {
  final PromotionRepository repository;

  GetPromotionByIdUseCase(this.repository);

  Future<Either<Failure, PromotionDetailEntity>> call(String id) {
    return repository.getPromotionById(id);
  }
}
