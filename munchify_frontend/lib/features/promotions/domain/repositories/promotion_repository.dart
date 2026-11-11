import 'package:dartz/dartz.dart';
import '../../../../core/errors/Failures.dart';
import '../../../../core/utils/PagedResult.dart';
import '../entities/promotion_entity.dart';

abstract class PromotionRepository {
  Future<Either<Failure, PagedResult<PromotionEntity>>> getPromotions(int pageIndex, int pageSize, String? searchKeyword);
  Future<Either<Failure, PromotionDetailEntity>> getPromotionById(String id);
  Future<Either<Failure, PromotionDetailEntity>> createPromotion(Map<String, dynamic> data);
  Future<Either<Failure, PromotionDetailEntity>> updatePromotion(String id, Map<String, dynamic> data);
  Future<Either<Failure, bool>> togglePromotionStatus(String id);
}
