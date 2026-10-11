import 'package:dartz/dartz.dart';
import '../../../../core/errors/Failures.dart';
import '../entities/promotion_entity.dart';
import '../repositories/promotion_repository.dart';

class CreatePromotionUseCase {
  final PromotionRepository repository;

  CreatePromotionUseCase(this.repository);

  Future<Either<Failure, PromotionDetailEntity>> call(Map<String, dynamic> data) {
    return repository.createPromotion(data);
  }
}
