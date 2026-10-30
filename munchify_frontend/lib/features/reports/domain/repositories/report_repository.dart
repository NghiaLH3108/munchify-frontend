import 'dart:typed_data';
import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/Failures.dart';
import '../entities/report_filter.dart';
import '../entities/revenue_summary_entity.dart';
import '../entities/top_selling_entity.dart';

abstract class ReportRepository {
  Future<Either<Failure, RevenueSummaryEntity>> getRevenueSummary(
      ReportFilter filter);
  Future<Either<Failure, List<TopSellingEntity>>> getTopSelling(
      ReportFilter filter,
      {int limit = 10});
  Future<Either<Failure, Uint8List>> exportToExcel(ReportFilter filter);
}
