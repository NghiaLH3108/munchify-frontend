import 'package:equatable/equatable.dart';
import '../../domain/entities/report_filter.dart';

abstract class ReportEvent extends Equatable {
  const ReportEvent();

  @override
  List<Object?> get props => [];
}

class LoadReports extends ReportEvent {
  final ReportFilter filter;
  const LoadReports(this.filter);

  @override
  List<Object?> get props => [filter];
}

class ExportReportRequested extends ReportEvent {
  const ExportReportRequested();
}
