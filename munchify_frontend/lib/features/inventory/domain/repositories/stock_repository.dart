import 'package:dartz/dartz.dart';
import '../../../../core/errors/Failures.dart';
import '../entities/stock_import_entity.dart';

abstract class StockRepository {
  Future<Either<Failure, List<StockImportEntity>>> getStockImports();
  Future<Either<Failure, StockImportEntity>> getStockImportById(int id);
  Future<Either<Failure, int>> createDraftImport(int supplierId, String? notes, List<Map<String, dynamic>> items);
  Future<Either<Failure, bool>> completeImport(int id);
  Future<Either<Failure, bool>> cancelImport(int id);
}
