import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/errors/Failures.dart';
import '../../../../core/utils/PagedResult.dart';
import '../../domain/entities/promotion_entity.dart';
import '../../domain/repositories/promotion_repository.dart';
import '../datasources/promotion_remote_data_source.dart';
import '../models/promotion_model.dart';

class PromotionRepositoryImpl implements PromotionRepository {
  final PromotionRemoteDataSource remoteDataSource;

  PromotionRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, PagedResult<PromotionEntity>>> getPromotions(int pageIndex, int pageSize, String? searchKeyword) async {
    try {
      final result = await remoteDataSource.getPromotions(pageIndex, pageSize, searchKeyword);
      final items = (result['items'] as List)
          .map<PromotionEntity>((e) => PromotionModel.fromJson(e as Map<String, dynamic>))
          .toList();
      return Right(PagedResult<PromotionEntity>(
        items: items,
        totalCount: result['totalCount'] as int,
        pageNumber: result['pageNumber'] as int,
        pageSize: result['pageSize'] as int,
      ));
    } on DioException catch (e) {
      return Left(ServerFailure(message: e.response?.data['message']?.toString() ?? e.message ?? 'Lỗi server'));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, PromotionDetailEntity>> getPromotionById(String id) async {
    try {
      final result = await remoteDataSource.getPromotionById(id);
      return Right(result);
    } on DioException catch (e) {
      return Left(ServerFailure(message: e.response?.data['message']?.toString() ?? e.message ?? 'Lỗi server'));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, PromotionDetailEntity>> createPromotion(Map<String, dynamic> data) async {
    try {
      final result = await remoteDataSource.createPromotion(data);
      return Right(result);
    } on DioException catch (e) {
      return Left(ServerFailure(message: e.response?.data['message']?.toString() ?? e.message ?? 'Lỗi server'));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, PromotionDetailEntity>> updatePromotion(String id, Map<String, dynamic> data) async {
    try {
      final result = await remoteDataSource.updatePromotion(id, data);
      return Right(result);
    } on DioException catch (e) {
      return Left(ServerFailure(message: e.response?.data['message']?.toString() ?? e.message ?? 'Lỗi server'));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> togglePromotionStatus(String id) async {
    try {
      final result = await remoteDataSource.togglePromotionStatus(id);
      return Right(result);
    } on DioException catch (e) {
      return Left(ServerFailure(message: e.response?.data['message']?.toString() ?? e.message ?? 'Lỗi server'));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
