import 'package:dartz/dartz.dart';
import '../../../../core/errors/Failures.dart';
import '../entities/damaged_expired_record_entity.dart';
import '../repositories/stock_repository.dart';

class ReportDamagedExpiredParams {
  final int productId;
  final int quantity;
  final String reportType;
  final String reason;

  ReportDamagedExpiredParams({
    required this.productId,
    required this.quantity,
    required this.reportType,
    required this.reason,
  });
}

class ReportDamagedExpiredUseCase {
  final StockRepository repository;

  ReportDamagedExpiredUseCase(this.repository);

  Future<Either<Failure, DamagedExpiredRecordEntity>> call(ReportDamagedExpiredParams params) async {
    return await repository.createStaffDamageReport(
      params.productId,
      params.quantity,
      params.reportType,
      params.reason,
    );
  }
}
