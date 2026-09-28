import 'package:dartz/dartz.dart';
import '../../../../core/errors/Failures.dart';
import '../entities/stock_import_entity.dart';
import '../repositories/stock_repository.dart';

class GetStockImportsUseCase {
  final StockRepository repository;
  GetStockImportsUseCase(this.repository);

  Future<Either<Failure, List<StockImportEntity>>> call() {
    return repository.getStockImports();
  }
}

class CreateDraftImportUseCase {
  final StockRepository repository;
  CreateDraftImportUseCase(this.repository);

  Future<Either<Failure, int>> call(int supplierId, String? notes, List<Map<String, dynamic>> items) {
    return repository.createDraftImport(supplierId, notes, items);
  }
}

class CompleteImportUseCase {
  final StockRepository repository;
  CompleteImportUseCase(this.repository);

  Future<Either<Failure, bool>> call(int id) {
    return repository.completeImport(id);
  }
}

class CancelImportUseCase {
  final StockRepository repository;
  CancelImportUseCase(this.repository);

  Future<Either<Failure, bool>> call(int id) {
    return repository.cancelImport(id);
  }
}
