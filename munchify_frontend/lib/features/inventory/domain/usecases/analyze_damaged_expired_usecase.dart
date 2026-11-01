import 'package:dartz/dartz.dart';
import '../../../../core/errors/Failures.dart';
import '../entities/damaged_expired_record_entity.dart';
import '../repositories/stock_repository.dart';

class AnalyzeDamagedExpiredUseCase {
  final StockRepository repository;

  AnalyzeDamagedExpiredUseCase(this.repository);

  Future<Either<Failure, DamagedExpiredRecordEntity>> execute(int id) {
    return repository.analyzeDamagedExpiredRecord(id);
  }
}
