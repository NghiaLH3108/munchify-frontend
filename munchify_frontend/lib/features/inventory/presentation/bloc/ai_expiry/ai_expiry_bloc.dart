import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/get_pending_records_usecase.dart';
import '../../../domain/usecases/approve_record_usecase.dart';
import '../../../domain/usecases/get_ai_expiry_summary_usecase.dart';
import 'ai_expiry_event.dart';
import 'ai_expiry_state.dart';

class AiExpiryBloc extends Bloc<AiExpiryEvent, AiExpiryState> {
  final GetPendingRecordsUseCase getPendingRecordsUseCase;
  final GetAiExpirySummaryUseCase getAiExpirySummaryUseCase;
  final ApproveRecordUseCase approveRecordUseCase;

  AiExpiryBloc({
    required this.getPendingRecordsUseCase,
    required this.getAiExpirySummaryUseCase,
    required this.approveRecordUseCase,
  }) : super(AiExpiryInitial()) {
    on<FetchPendingRecordsEvent>(_onFetchPendingRecords);
    on<ApproveRecordEvent>(_onApproveRecord);
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
}
