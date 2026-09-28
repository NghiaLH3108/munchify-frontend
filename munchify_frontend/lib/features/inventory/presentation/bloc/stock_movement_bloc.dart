import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:munchify_frontend/features/inventory/domain/usecases/get_stock_movements_usecase.dart';
import 'package:munchify_frontend/features/inventory/domain/usecases/adjust_stock_usecase.dart';
import 'stock_movement_event.dart';
import 'stock_movement_state.dart';

class StockMovementBloc extends Bloc<StockMovementEvent, StockMovementState> {
  final GetStockMovementsUseCase getStockMovementsUseCase;
  final AdjustStockUseCase adjustStockUseCase;

  // Filter state
  int? _currentProductId;
  String? _currentMovementType;
  DateTime? _currentFrom;
  DateTime? _currentTo;

  StockMovementBloc({
    required this.getStockMovementsUseCase,
    required this.adjustStockUseCase,
  }) : super(StockMovementInitial()) {
    on<LoadStockMovements>(_onLoadStockMovements);
    on<LoadNextPage>(_onLoadNextPage);
    on<AdjustStockEvent>(_onAdjustStock);
  }

  Future<void> _onAdjustStock(
    AdjustStockEvent event,
    Emitter<StockMovementState> emit,
  ) async {
    final currentState = state;
    if (currentState is StockMovementLoaded) {
      emit(StockMovementLoading());
      
      final result = await adjustStockUseCase.execute(AdjustStockParams(
        productId: event.productId,
        quantityChange: event.quantityChange,
        reason: event.reason,
        movementType: event.movementType,
      ));

      result.fold(
        (failure) {
          emit(StockMovementError(failure.message));
          // Restore previous state if needed
          emit(currentState);
        },
        (movement) {
          // Add new movement to top of list and emit
          emit(currentState.copyWith(
            movements: [movement, ...currentState.movements],
          ));
        },
      );
    }
  }

  Future<void> _onLoadStockMovements(
    LoadStockMovements event,
    Emitter<StockMovementState> emit,
  ) async {
    emit(StockMovementLoading());

    _currentProductId = event.productId;
    _currentMovementType = event.movementType;
    _currentFrom = event.from;
    _currentTo = event.to;

    final params = GetStockMovementsParams(
      productId: _currentProductId,
      movementType: _currentMovementType,
      from: _currentFrom,
      to: _currentTo,
      page: 1,
    );

    final result = await getStockMovementsUseCase.execute(params);

    result.fold(
      (failure) => emit(StockMovementError(failure.message)),
      (data) => emit(StockMovementLoaded(
        movements: data.items,
        hasReachedMax: data.pageNumber >= data.totalCount / data.pageSize,
        currentPage: 1,
      )),
    );
  }

  Future<void> _onLoadNextPage(
    LoadNextPage event,
    Emitter<StockMovementState> emit,
  ) async {
    final currentState = state;
    if (currentState is StockMovementLoaded && !currentState.hasReachedMax) {
      final params = GetStockMovementsParams(
        productId: _currentProductId,
        movementType: _currentMovementType,
        from: _currentFrom,
        to: _currentTo,
        page: currentState.currentPage + 1,
      );

      final result = await getStockMovementsUseCase.execute(params);

      result.fold(
        (failure) => emit(StockMovementError(failure.message)),
        (data) => emit(currentState.copyWith(
          movements: List.of(currentState.movements)..addAll(data.items),
          hasReachedMax: data.pageNumber >= data.totalCount / data.pageSize,
          currentPage: data.pageNumber,
        )),
      );
    }
  }
}
