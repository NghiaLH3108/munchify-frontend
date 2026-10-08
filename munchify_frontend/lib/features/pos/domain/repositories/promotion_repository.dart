import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/Failures.dart';
import '../entities/promotion_entity.dart';

abstract class PromotionRepository {
  Future<Either<Failure, PromotionEntity>> applyPromotion({
    required String promotionCode,
    required double subtotal,
  });
}
