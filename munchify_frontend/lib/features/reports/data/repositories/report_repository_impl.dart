import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/Failures.dart';
import '../../domain/entities/report_filter.dart';
import '../../domain/entities/revenue_summary_entity.dart';
import '../../domain/entities/top_selling_entity.dart';
import '../../domain/repositories/report_repository.dart';
import '../datasources/report_remote_data_source.dart';

class ReportRepositoryImpl implements ReportRepository {
  final ReportRemoteDataSource remoteDataSource;

  ReportRepositoryImpl({required this.remoteDataSource});

  Failure _mapDio(DioException e) {
    final data = e.response?.data;
    final serverMsg = data is Map ? data['message'] as String? : null;
    return ServerFailure(
      message: serverMsg ?? e.message ?? 'Lỗi kết nối máy chủ',
      statusCode: e.response?.statusCode,
    );
  }

  @override
  Future<Either<Failure, RevenueSummaryEntity>> getRevenueSummary(
      ReportFilter filter) async {
    try {
      final result = await remoteDataSource.getRevenueSummary(filter);
      return Right(result.toEntity());
    } on DioException catch (e) {
      return Left(_mapDio(e));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<TopSellingEntity>>> getTopSelling(
      ReportFilter filter,
      {int limit = 10}) async {
    try {
      final result = await remoteDataSource.getTopSelling(filter, limit: limit);
      return Right(result.map((e) => e.toEntity()).toList());
    } on DioException catch (e) {
      return Left(_mapDio(e));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Uint8List>> exportToExcel(ReportFilter filter) async {
    try {
      return Right(await remoteDataSource.exportToExcel(filter));
    } on DioException catch (e) {
      return Left(_mapDio(e));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }
}
