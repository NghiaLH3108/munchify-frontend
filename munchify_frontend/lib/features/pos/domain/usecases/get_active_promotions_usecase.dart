import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/Failures.dart';
import '../entities/catalog_promotion_entity.dart';
import '../repositories/promotion_repository.dart';

class GetActivePromotionsUseCase {
  final PromotionRepository repository;

  GetActivePromotionsUseCase(this.repository);

  Future<Either<Failure, List<CatalogPromotionEntity>>> execute() {
    return repository.getActivePromotions();
  }
}
