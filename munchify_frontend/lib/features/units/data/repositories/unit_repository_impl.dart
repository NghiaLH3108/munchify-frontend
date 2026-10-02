import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/Failures.dart';
import '../../domain/entities/unit_entity.dart';
import '../../domain/repositories/unit_repository.dart';
import '../datasources/unit_remote_data_source.dart';

class UnitRepositoryImpl implements UnitRepository {
  final UnitRemoteDataSource remoteDataSource;

  UnitRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<UnitEntity>>> getUnits({
    String searchTerm = '',
    bool? isActive,
    int page = 1,
    int pageSize = 10,
  }) async {
    try {
      final result = await remoteDataSource.getUnits(
        searchTerm: searchTerm,
        isActive: isActive,
        page: page,
        pageSize: pageSize,
      );
      return Right(result);
    } on DioException catch (e) {
      final serverMsg = e.response?.data is Map ? e.response?.data['message'] as String? : null;
      return Left(ServerFailure(
          message: serverMsg ?? e.message ?? 'Lỗi kết nối máy chủ'));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, UnitEntity>> getUnitById(int id) async {
    try {
      final result = await remoteDataSource.getUnitById(id);
      return Right(result);
    } on DioException catch (e) {
      final serverMsg = e.response?.data is Map ? e.response?.data['message'] as String? : null;
      return Left(ServerFailure(
          message: serverMsg ?? e.message ?? 'Lỗi kết nối máy chủ'));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, UnitEntity>> createUnit({
    required String unitName,
    String? description,
    bool isActive = true,
  }) async {
    try {
      final result = await remoteDataSource.createUnit(
        unitName: unitName,
        description: description,
        isActive: isActive,
      );
      return Right(result);
    } on DioException catch (e) {
      final serverMsg = e.response?.data is Map ? e.response?.data['message'] as String? : null;
      return Left(ServerFailure(
          message: serverMsg ?? e.message ?? 'Lỗi kết nối máy chủ'));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, UnitEntity>> updateUnit({
    required int id,
    required String unitName,
    String? description,
    required bool isActive,
  }) async {
    try {
      final result = await remoteDataSource.updateUnit(
        id: id,
        unitName: unitName,
        description: description,
        isActive: isActive,
      );
      return Right(result);
    } on DioException catch (e) {
      final serverMsg = e.response?.data is Map ? e.response?.data['message'] as String? : null;
      return Left(ServerFailure(
          message: serverMsg ?? e.message ?? 'Lỗi kết nối máy chủ'));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteUnit(int id) async {
    try {
      final result = await remoteDataSource.deleteUnit(id);
      return Right(result);
    } on DioException catch (e) {
      final serverMsg = e.response?.data is Map ? e.response?.data['message'] as String? : null;
      return Left(ServerFailure(
          message: serverMsg ?? e.message ?? 'Lỗi kết nối máy chủ'));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }
}
