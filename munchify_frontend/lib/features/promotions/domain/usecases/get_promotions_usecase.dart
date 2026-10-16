import 'package:dartz/dartz.dart';
import '../../../../core/errors/Failures.dart';
import '../../../../core/utils/PagedResult.dart';
import '../entities/promotion_entity.dart';
import '../repositories/promotion_repository.dart';

class GetPromotionsUseCase {
  final PromotionRepository repository;

  GetPromotionsUseCase(this.repository);

  Future<Either<Failure, PagedResult<PromotionEntity>>> call(int pageIndex, int pageSize, String? searchKeyword) {
    return repository.getPromotions(pageIndex, pageSize, searchKeyword);
  }
}
