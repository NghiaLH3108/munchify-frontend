import 'package:dartz/dartz.dart';
import '../../../../core/errors/Failures.dart';
import '../entities/ai_expiry_summary_entity.dart';
import '../repositories/stock_repository.dart';

class GetAiExpirySummaryUseCase {
  final StockRepository repository;

  GetAiExpirySummaryUseCase(this.repository);

  Future<Either<Failure, AiExpirySummaryEntity>> execute() {
    return repository.getAiExpirySummaryMetrics();
  }
}
