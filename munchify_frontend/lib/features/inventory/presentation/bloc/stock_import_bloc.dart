import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/stock_import_use_cases.dart';
import 'stock_import_event.dart';
import 'stock_import_state.dart';

class StockImportBloc extends Bloc<StockImportEvent, StockImportState> {
  final GetStockImportsUseCase getStockImportsUseCase;
  final CreateDraftImportUseCase createDraftImportUseCase;
  final CompleteImportUseCase completeImportUseCase;
  final CancelImportUseCase cancelImportUseCase;

  StockImportBloc({
    required this.getStockImportsUseCase,
    required this.createDraftImportUseCase,
    required this.completeImportUseCase,
    required this.cancelImportUseCase,
  }) : super(StockImportInitial()) {
    on<FetchStockImportsEvent>(_onFetchStockImports);
    on<CreateDraftImportEvent>(_onCreateDraftImport);
    on<CompleteImportEvent>(_onCompleteImport);
    on<CancelImportEvent>(_onCancelImport);
  }

  Future<void> _onFetchStockImports(
    FetchStockImportsEvent event,
    Emitter<StockImportState> emit,
  ) async {
    emit(StockImportLoading());
    final result = await getStockImportsUseCase();
    result.fold(
      (failure) => emit(StockImportError(failure.message)),
      (imports) => emit(StockImportsLoaded(imports)),
    );
  }

  Future<void> _onCreateDraftImport(
    CreateDraftImportEvent event,
    Emitter<StockImportState> emit,
  ) async {
    emit(StockImportLoading());
    final result = await createDraftImportUseCase(event.supplierId, event.notes, event.items);
    result.fold(
      (failure) {
        emit(StockImportError(failure.message));
        add(FetchStockImportsEvent());
      },
      (id) {
        emit(const StockImportActionSuccess("Tạo phiếu nhập nháp thành công"));
        add(FetchStockImportsEvent()); // Reload list after success
      },
    );
  }

  Future<void> _onCompleteImport(
    CompleteImportEvent event,
    Emitter<StockImportState> emit,
  ) async {
    emit(StockImportLoading());
    final result = await completeImportUseCase(event.id);
    result.fold(
      (failure) {
        emit(StockImportError(failure.message));
        add(FetchStockImportsEvent());
      },
      (success) {
        emit(const StockImportActionSuccess("Hoàn thành phiếu nhập thành công"));
        add(FetchStockImportsEvent());
      },
    );
  }

  Future<void> _onCancelImport(
    CancelImportEvent event,
    Emitter<StockImportState> emit,
  ) async {
    emit(StockImportLoading());
    final result = await cancelImportUseCase(event.id);
    result.fold(
      (failure) {
        emit(StockImportError(failure.message));
        add(FetchStockImportsEvent());
      },
      (success) {
        emit(const StockImportActionSuccess("Huỷ phiếu nhập thành công"));
        add(FetchStockImportsEvent());
      },
    );
  }
}
