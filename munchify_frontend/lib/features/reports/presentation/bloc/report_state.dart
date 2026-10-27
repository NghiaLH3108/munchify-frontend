import 'dart:typed_data';
import 'package:equatable/equatable.dart';
import '../../domain/entities/report_filter.dart';
import '../../domain/entities/revenue_summary_entity.dart';
import '../../domain/entities/top_selling_entity.dart';

abstract class ReportState extends Equatable {
  const ReportState();

  @override
  List<Object?> get props => [];
}

class ReportInitial extends ReportState {
  const ReportInitial();
}

class ReportLoading extends ReportState {
  const ReportLoading();
}

class ReportLoaded extends ReportState {
  final ReportFilter filter;
  final RevenueSummaryEntity revenue;
  final List<TopSellingEntity> topSelling;
  final bool isExporting;

  /// Set once after a successful export; UI consumes it to trigger a download.
  final Uint8List? exportedBytes;
  final String? exportError;
  final int stamp;

  const ReportLoaded({
    required this.filter,
    required this.revenue,
    required this.topSelling,
    this.isExporting = false,
    this.exportedBytes,
    this.exportError,
    this.stamp = 0,
  });

  ReportLoaded copyWith({
    bool? isExporting,
    Uint8List? exportedBytes,
    String? exportError,
  }) =>
      ReportLoaded(
        filter: filter,
        revenue: revenue,
        topSelling: topSelling,
        isExporting: isExporting ?? this.isExporting,
        exportedBytes: exportedBytes,
        exportError: exportError,
        stamp: stamp + 1,
      );

  @override
  List<Object?> get props =>
      [filter, revenue, topSelling, isExporting, exportedBytes, exportError, stamp];
}

class ReportError extends ReportState {
  final String message;
  const ReportError(this.message);

  @override
  List<Object?> get props => [message];
}
