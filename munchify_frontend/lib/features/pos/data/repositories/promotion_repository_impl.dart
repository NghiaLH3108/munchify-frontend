import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/Failures.dart';
import '../../domain/entities/promotion_entity.dart';
import '../../domain/repositories/promotion_repository.dart';
import '../datasources/promotion_remote_data_source.dart';

class PromotionRepositoryImpl implements PromotionRepository {
  final PromotionRemoteDataSource remoteDataSource;

  PromotionRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, PromotionEntity>> applyPromotion({
    required String promotionCode,
    required double subtotal,
  }) async {
    try {
      final result = await remoteDataSource.applyPromotion(
        promotionCode: promotionCode,
        subtotal: subtotal,
      );
      return Right(result);
    } on DioException catch (e) {
      final msg = e.response?.data?['message']?.toString() ??
          e.message ??
          'Mã khuyến mãi không hợp lệ';
      return Left(ValidationFailure(message: msg));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }
}
