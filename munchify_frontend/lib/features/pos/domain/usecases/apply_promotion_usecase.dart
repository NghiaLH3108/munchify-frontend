import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/Failures.dart';
import '../entities/promotion_entity.dart';
import '../repositories/promotion_repository.dart';

class ApplyPromotionUseCase {
  final PromotionRepository repository;

  ApplyPromotionUseCase(this.repository);

  Future<Either<Failure, PromotionEntity>> execute({
    required String promotionCode,
    required double subtotal,
  }) {
    return repository.applyPromotion(
      promotionCode: promotionCode,
      subtotal: subtotal,
    );
  }
}
