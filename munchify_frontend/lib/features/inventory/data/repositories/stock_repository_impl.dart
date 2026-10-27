import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/errors/Failures.dart';
import '../../domain/entities/stock_import_entity.dart';
import '../../domain/entities/damaged_expired_record_entity.dart';
import '../../domain/repositories/stock_repository.dart';
import '../datasources/stock_remote_data_source.dart';

import '../../domain/entities/ai_expiry_summary_entity.dart';
import '../../domain/entities/forecast_item_entity.dart';
import '../models/forecast_item_model.dart';

class StockRepositoryImpl implements StockRepository {
  final StockRemoteDataSource remoteDataSource;

  StockRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<StockImportEntity>>> getStockImports() async {
    try {
      final imports = await remoteDataSource.getStockImports();
      return Right(imports);
    } on DioException catch (e) {
      return Left(ServerFailure(message: e.message ?? 'Server error occurred'));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, StockImportEntity>> getStockImportById(int id) async {
    try {
      final importDetail = await remoteDataSource.getStockImportById(id);
      return Right(importDetail);
    } on DioException catch (e) {
      return Left(ServerFailure(message: e.message ?? 'Server error occurred'));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, int>> createDraftImport(int supplierId, String? notes, List<Map<String, dynamic>> items) async {
    try {
      final id = await remoteDataSource.createDraftImport(supplierId, notes, items);
      return Right(id);
    } on DioException catch (e) {
      return Left(ServerFailure(message: e.message ?? 'Server error occurred'));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> completeImport(int id) async {
    try {
      final success = await remoteDataSource.completeImport(id);
      return Right(success);
    } on DioException catch (e) {
      return Left(ServerFailure(message: e.message ?? 'Server error occurred'));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> cancelImport(int id) async {
    try {
      final success = await remoteDataSource.cancelImport(id);
      return Right(success);
    } on DioException catch (e) {
      return Left(ServerFailure(message: e.message ?? 'Server error occurred'));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<DamagedExpiredRecordEntity>>> getPendingDamagedExpiredRecords() async {
    try {
      final records = await remoteDataSource.getPendingDamagedExpiredRecords();
      final List<DamagedExpiredRecordEntity> entities = records.cast<DamagedExpiredRecordEntity>();
      return Right(entities);
    } on DioException catch (e) {
      return Left(ServerFailure(message: e.message ?? 'Server error occurred'));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AiExpirySummaryEntity>> getAiExpirySummaryMetrics() async {
    try {
      final summary = await remoteDataSource.getAiExpirySummaryMetrics();
      return Right(summary);
    } on DioException catch (e) {
      return Left(ServerFailure(message: e.message ?? 'Server error occurred'));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> approveDamagedExpiredRecord(int id) async {
    try {
      final success = await remoteDataSource.approveDamagedExpiredRecord(id);
      return Right(success);
    } on DioException catch (e) {
      return Left(ServerFailure(message: e.message ?? 'Server error occurred'));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, DamagedExpiredRecordEntity>> createStaffDamageReport(int productId, int quantity, String reportType, String reason) async {
    try {
      final result = await remoteDataSource.createStaffDamageReport(productId, quantity, reportType, reason);
      return Right(result);
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? e.message ?? 'Lỗi khi gửi báo cáo sự cố hàng hóa';
      return Left(ServerFailure(message: msg.toString()));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ForecastItemEntity>>> getForecasting({int daysHistory = 30}) async {
    try {
      final forecast = await remoteDataSource.getForecasting(daysHistory: daysHistory);
      final List<ForecastItemEntity> entities = forecast.cast<ForecastItemEntity>();
      return Right(entities);
    } on DioException catch (e) {
      return Left(ServerFailure(message: e.message ?? 'Server error occurred'));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> generateDraftImportsFromForecast(List<ForecastItemEntity> items) async {
    try {
      final models = items.map((e) => ForecastItemModel(
        productId: e.productId,
        productName: e.productName,
        unitName: e.unitName,
        stockQuantity: e.stockQuantity,
        minStockLevel: e.minStockLevel,
        avgDailyUsage: e.avgDailyUsage,
        daysRemaining: e.daysRemaining,
        riskLevel: e.riskLevel,
        suggestedImportQty: e.suggestedImportQty,
        defaultSupplierId: e.defaultSupplierId,
        defaultSupplierName: e.defaultSupplierName,
      )).toList();
      final success = await remoteDataSource.generateDraftImportsFromForecast(models);
      return Right(success);
    } on DioException catch (e) {
      return Left(ServerFailure(message: e.message ?? 'Server error occurred'));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
