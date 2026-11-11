import 'package:dartz/dartz.dart';
import '../../../../core/errors/Failures.dart';
import '../entities/damaged_expired_record_entity.dart';
import '../repositories/stock_repository.dart';

class GetPendingRecordsUseCase {
  final StockRepository repository;

  GetPendingRecordsUseCase(this.repository);

  Future<Either<Failure, List<DamagedExpiredRecordEntity>>> execute() {
    return repository.getPendingDamagedExpiredRecords();
  }
}
