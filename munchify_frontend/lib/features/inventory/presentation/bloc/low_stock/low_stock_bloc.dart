import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/get_forecasting_usecase.dart';
import '../../../domain/usecases/generate_draft_imports_from_forecast_usecase.dart';
import 'low_stock_event.dart';
import 'low_stock_state.dart';

class LowStockBloc extends Bloc<LowStockEvent, LowStockState> {
  final GetForecastingUseCase getForecastingUseCase;
  final GenerateDraftImportsFromForecastUseCase generateDraftImportsFromForecastUseCase;

  LowStockBloc({
    required this.getForecastingUseCase,
    required this.generateDraftImportsFromForecastUseCase,
  }) : super(LowStockInitial()) {
    on<FetchLowStockWarningEvent>(_onFetchLowStockWarning);
    on<GenerateDraftImportsEvent>(_onGenerateDraftImports);
  }

  Future<void> _onFetchLowStockWarning(
    FetchLowStockWarningEvent event,
    Emitter<LowStockState> emit,
  ) async {
    // Only emit loading if we don't have data yet to prevent flickering
    if (state is! LowStockLoaded) {
      emit(LowStockLoading());
    }
    
    final result = await getForecastingUseCase(daysHistory: event.daysHistory);
    result.fold(
      (failure) => emit(LowStockError(failure.message)),
      (forecastItems) => emit(LowStockLoaded(forecastItems)),
    );
  }

  Future<void> _onGenerateDraftImports(
    GenerateDraftImportsEvent event,
    Emitter<LowStockState> emit,
  ) async {
    final currentState = state;
    emit(DraftImportGenerating());
    
    final result = await generateDraftImportsFromForecastUseCase(event.items);
    
    result.fold(
      (failure) => emit(DraftImportGeneratedError(failure.message)),
      (_) => emit(DraftImportGeneratedSuccess()),
    );
    
    // Re-emit previous loaded state if available so UI doesn't break
    if (currentState is LowStockLoaded) {
      emit(currentState);
    }
  }
}
