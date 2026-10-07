import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/Failures.dart';
import '../../domain/entities/combo_entity.dart';
import '../../domain/entities/combo_form_options_entity.dart';
import '../../domain/entities/combo_input.dart';
import '../../domain/repositories/combo_repository.dart';
import '../datasources/combo_remote_data_source.dart';

class ComboRepositoryImpl implements ComboRepository {
  final ComboRemoteDataSource remoteDataSource;

  ComboRepositoryImpl({required this.remoteDataSource});

  Failure _mapDio(DioException e) {
    final data = e.response?.data;
    final serverMsg = data is Map ? data['message'] as String? : null;
    return ServerFailure(
      message: serverMsg ?? e.message ?? 'Lỗi kết nối máy chủ',
      statusCode: e.response?.statusCode,
    );
  }

  @override
  Future<Either<Failure, ComboPageEntity>> getCombos({
    String searchTerm = '',
    bool? isActive,
    int page = 1,
    int pageSize = 10,
  }) async {
    try {
      final result = await remoteDataSource.getCombos(
        searchTerm: searchTerm,
        isActive: isActive,
        page: page,
        pageSize: pageSize,
      );
      return Right(ComboPageEntity(
        items: result.items.map((e) => e.toEntity()).toList(),
        totalCount: result.totalCount,
        page: result.page,
        pageSize: result.pageSize,
      ));
    } on DioException catch (e) {
      return Left(_mapDio(e));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, ComboEntity>> createCombo(ComboInput input) async {
    try {
      final result = await remoteDataSource.createCombo(input);
      return Right(result.toEntity());
    } on DioException catch (e) {
      return Left(_mapDio(e));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, ComboEntity>> updateCombo(
      int id, ComboInput input) async {
    try {
      final result = await remoteDataSource.updateCombo(id, input);
      return Right(result.toEntity());
    } on DioException catch (e) {
      return Left(_mapDio(e));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> deleteCombo(int id) async {
    try {
      final message = await remoteDataSource.deleteCombo(id);
      return Right(message);
    } on DioException catch (e) {
      return Left(_mapDio(e));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, ComboFormOptionsEntity>> getFormOptions() async {
    try {
      final result = await remoteDataSource.getFormOptions();
      return Right(result);
    } on DioException catch (e) {
      return Left(_mapDio(e));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }
}
