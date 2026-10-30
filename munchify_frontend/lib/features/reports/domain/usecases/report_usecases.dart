import 'dart:typed_data';
import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/Failures.dart';
import '../entities/report_filter.dart';
import '../entities/revenue_summary_entity.dart';
import '../entities/top_selling_entity.dart';
import '../repositories/report_repository.dart';

class GetRevenueSummaryUseCase {
  final ReportRepository repository;
  GetRevenueSummaryUseCase(this.repository);

  Future<Either<Failure, RevenueSummaryEntity>> call(ReportFilter filter) =>
      repository.getRevenueSummary(filter);
}

class GetTopSellingUseCase {
  final ReportRepository repository;
  GetTopSellingUseCase(this.repository);

  Future<Either<Failure, List<TopSellingEntity>>> call(ReportFilter filter,
          {int limit = 10}) =>
      repository.getTopSelling(filter, limit: limit);
}

class ExportReportToExcelUseCase {
  final ReportRepository repository;
  ExportReportToExcelUseCase(this.repository);

  Future<Either<Failure, Uint8List>> call(ReportFilter filter) =>
      repository.exportToExcel(filter);
}
