import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/get_pending_records_usecase.dart';
import '../../../domain/usecases/approve_record_usecase.dart';
import '../../../domain/usecases/get_ai_expiry_summary_usecase.dart';
import '../../../domain/usecases/report_damaged_expired_usecase.dart';
import 'ai_expiry_event.dart';
import 'ai_expiry_state.dart';

class AiExpiryBloc extends Bloc<AiExpiryEvent, AiExpiryState> {
  final GetPendingRecordsUseCase getPendingRecordsUseCase;
  final GetAiExpirySummaryUseCase getAiExpirySummaryUseCase;
  final ApproveRecordUseCase approveRecordUseCase;
  final ReportDamagedExpiredUseCase reportDamagedExpiredUseCase;

  AiExpiryBloc({
    required this.getPendingRecordsUseCase,
    required this.getAiExpirySummaryUseCase,
    required this.approveRecordUseCase,
    required this.reportDamagedExpiredUseCase,
  }) : super(AiExpiryInitial()) {
    on<FetchPendingRecordsEvent>(_onFetchPendingRecords);
    on<ApproveRecordEvent>(_onApproveRecord);
    on<SubmitStaffReportEvent>(_onSubmitStaffReport);
  }

  Future<void> _onFetchPendingRecords(
    FetchPendingRecordsEvent event,
    Emitter<AiExpiryState> emit,
  ) async {
    if (state is! AiExpiryLoaded) {
      emit(AiExpiryLoading());
    }
    final recordsResult = await getPendingRecordsUseCase.execute();
    final summaryResult = await getAiExpirySummaryUseCase.execute();

    recordsResult.fold(
      (failure) => emit(AiExpiryError(message: failure.message)),
      (records) {
        summaryResult.fold(
          (failure) => emit(AiExpiryError(message: failure.message)),
          (summary) => emit(AiExpiryLoaded(records: records, summary: summary)),
        );
      },
    );
  }

  Future<void> _onApproveRecord(
    ApproveRecordEvent event,
    Emitter<AiExpiryState> emit,
  ) async {
    final currentState = state;
    if (currentState is AiExpiryLoaded) {
      final result = await approveRecordUseCase.execute(event.recordId);
      result.fold(
        (failure) => emit(AiExpiryError(message: failure.message)),
        (success) {
          emit(AiExpiryApproveSuccess());
          add(FetchPendingRecordsEvent()); // Refresh list
        },
      );
    }
  }

  Future<void> _onSubmitStaffReport(
    SubmitStaffReportEvent event,
    Emitter<AiExpiryState> emit,
  ) async {
    emit(AiExpiryReportSubmitting());
    final result = await reportDamagedExpiredUseCase.call(
      ReportDamagedExpiredParams(
        productId: event.productId,
        quantity: event.quantity,
        reportType: event.reportType,
        reason: event.reason,
      ),
    );
    result.fold(
      (failure) => emit(AiExpiryError(message: failure.message)),
      (record) {
        emit(const AiExpiryReportSuccess(message: 'Đã gửi báo cáo sự cố hàng hóa thành công, đang chờ quản lý duyệt!'));
        add(FetchPendingRecordsEvent());
      },
    );
  }
}
