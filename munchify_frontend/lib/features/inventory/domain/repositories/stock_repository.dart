import 'package:dartz/dartz.dart';
import '../../../../core/errors/Failures.dart';
import '../entities/stock_import_entity.dart';
import '../entities/damaged_expired_record_entity.dart';

import '../entities/ai_expiry_summary_entity.dart';

abstract class StockRepository {
  Future<Either<Failure, List<StockImportEntity>>> getStockImports();
  Future<Either<Failure, StockImportEntity>> getStockImportById(int id);
  Future<Either<Failure, int>> createDraftImport(int supplierId, String? notes, List<Map<String, dynamic>> items);
  Future<Either<Failure, bool>> completeImport(int id);
  Future<Either<Failure, bool>> cancelImport(int id);

  // AI Expiry Insights
  Future<Either<Failure, List<DamagedExpiredRecordEntity>>> getPendingDamagedExpiredRecords();
  Future<Either<Failure, AiExpirySummaryEntity>> getAiExpirySummaryMetrics();
  Future<Either<Failure, bool>> approveDamagedExpiredRecord(int id);
}
