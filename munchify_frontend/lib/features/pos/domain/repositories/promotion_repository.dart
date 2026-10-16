import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/Failures.dart';
import '../entities/catalog_promotion_entity.dart';
import '../entities/promotion_entity.dart';

abstract class PromotionRepository {
  Future<Either<Failure, PromotionEntity>> applyPromotion({
    required String promotionCode,
    required double subtotal,
  });

  /// Lấy danh sách khuyến mãi đang có hiệu lực trong catalog
  Future<Either<Failure, List<CatalogPromotionEntity>>> getActivePromotions();
}
