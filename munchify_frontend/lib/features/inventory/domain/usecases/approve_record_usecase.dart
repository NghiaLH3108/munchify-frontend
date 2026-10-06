import 'package:dartz/dartz.dart';
import '../../../../core/errors/Failures.dart';
import '../repositories/stock_repository.dart';

class ApproveRecordUseCase {
  final StockRepository repository;

  ApproveRecordUseCase(this.repository);

  Future<Either<Failure, bool>> execute(int id) {
    return repository.approveDamagedExpiredRecord(id);
  }
}
