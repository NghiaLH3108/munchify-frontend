import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/report_filter.dart';
import '../../domain/usecases/report_usecases.dart';
import 'report_event.dart';
import 'report_state.dart';

class ReportBloc extends Bloc<ReportEvent, ReportState> {
  final GetRevenueSummaryUseCase getRevenueSummary;
  final GetTopSellingUseCase getTopSelling;
  final ExportReportToExcelUseCase exportToExcel;

  ReportBloc({
    required this.getRevenueSummary,
    required this.getTopSelling,
    required this.exportToExcel,
  }) : super(const ReportInitial()) {
    on<LoadReports>(_onLoad);
    on<ExportReportRequested>(_onExport);
  }

  ReportFilter? _lastFilter;

  Future<void> _onLoad(LoadReports event, Emitter<ReportState> emit) async {
    _lastFilter = event.filter;
    emit(const ReportLoading());

    final revenueResult = await getRevenueSummary(event.filter);
    final topResult = await getTopSelling(event.filter);

    final revenue = revenueResult.toNullable();
    final top = topResult.toNullable();

    if (revenue == null || top == null) {
      final msg = revenueResult.match((f) => f.message, (_) => '');
      final msg2 = topResult.match((f) => f.message, (_) => '');
      emit(ReportError(msg.isNotEmpty ? msg : msg2));
      return;
    }
    emit(ReportLoaded(
      filter: event.filter,
      revenue: revenue,
      topSelling: top,
    ));
  }

  Future<void> _onExport(
      ExportReportRequested event, Emitter<ReportState> emit) async {
    final current = state;
    if (current is! ReportLoaded || _lastFilter == null) return;

    emit(current.copyWith(isExporting: true));
    final result = await exportToExcel(current.filter);
    result.fold(
      (f) => emit(current.copyWith(isExporting: false, exportError: f.message)),
      (bytes) =>
          emit(current.copyWith(isExporting: false, exportedBytes: bytes)),
    );
  }
}
