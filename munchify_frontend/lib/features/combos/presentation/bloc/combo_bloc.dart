import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/manage_combo_usecases.dart';
import 'combo_event.dart';
import 'combo_state.dart';

class ComboBloc extends Bloc<ComboEvent, ComboState> {
  final GetCombosUseCase getCombos;
  final CreateComboUseCase createCombo;
  final UpdateComboUseCase updateCombo;
  final DeleteComboUseCase deleteCombo;
  final ToggleComboStatusUseCase toggleComboStatus;

  // Last query, reused to refresh the list after a mutation.
  LoadCombosEvent _lastQuery = const LoadCombosEvent();

  ComboBloc({
    required this.getCombos,
    required this.createCombo,
    required this.updateCombo,
    required this.deleteCombo,
    required this.toggleComboStatus,
  }) : super(ComboInitial()) {
    on<LoadCombosEvent>(_onLoadCombos);
    on<CreateComboEvent>(_onCreateCombo);
    on<UpdateComboEvent>(_onUpdateCombo);
    on<DeleteComboEvent>(_onDeleteCombo);
    on<ToggleComboStatusEvent>(_onToggleComboStatus);
  }

  Future<void> _onLoadCombos(
    LoadCombosEvent event,
    Emitter<ComboState> emit,
  ) async {
    _lastQuery = event;
    final current = state;
    if (current is ComboLoaded) {
      emit(ComboLoaded(
        combos: current.combos,
        totalCount: current.totalCount,
        page: current.page,
        pageSize: current.pageSize,
        isRefreshing: true,
        stamp: DateTime.now().microsecondsSinceEpoch,
      ));
    } else {
      emit(ComboLoading());
    }
    await _fetch(emit);
  }

  Future<void> _fetch(
    Emitter<ComboState> emit, {
    String? successMessage,
    String? errorMessage,
  }) async {
    final result = await getCombos(
      searchTerm: _lastQuery.searchTerm,
      isActive: _lastQuery.isActive,
      page: _lastQuery.page,
      pageSize: _lastQuery.pageSize,
    );

    await result.fold(
      (failure) async => emit(ComboError(failure.message)),
      (pageData) async {
        // Deleting the last row of a page: step back one page.
        if (pageData.items.isEmpty && _lastQuery.page > 1) {
          _lastQuery = LoadCombosEvent(
            searchTerm: _lastQuery.searchTerm,
            isActive: _lastQuery.isActive,
            page: _lastQuery.page - 1,
            pageSize: _lastQuery.pageSize,
          );
          await _fetch(emit,
              successMessage: successMessage, errorMessage: errorMessage);
          return;
        }
        emit(ComboLoaded(
          combos: pageData.items,
          totalCount: pageData.totalCount,
          page: pageData.page,
          pageSize: pageData.pageSize,
          successMessage: successMessage,
          errorMessage: errorMessage,
          isRefreshing: false,
          stamp: DateTime.now().microsecondsSinceEpoch,
        ));
      },
    );
  }

  Future<void> _onCreateCombo(
    CreateComboEvent event,
    Emitter<ComboState> emit,
  ) async {
    final result = await createCombo(event.input);
    await result.fold(
      (failure) async => event.completer.complete(failure.message),
      (_) async {
        event.completer.complete(null);
        // Newest first: go back to page 1 to show the new combo.
        _lastQuery = LoadCombosEvent(
          searchTerm: _lastQuery.searchTerm,
          isActive: _lastQuery.isActive,
          page: 1,
          pageSize: _lastQuery.pageSize,
        );
        await _fetch(emit, successMessage: 'Đã thêm combo thành công.');
      },
    );
  }

  Future<void> _onUpdateCombo(
    UpdateComboEvent event,
    Emitter<ComboState> emit,
  ) async {
    final result = await updateCombo(event.id, event.input);
    await result.fold(
      (failure) async => event.completer.complete(failure.message),
      (_) async {
        event.completer.complete(null);
        await _fetch(emit, successMessage: 'Đã cập nhật combo thành công.');
      },
    );
  }

  Future<void> _onDeleteCombo(
    DeleteComboEvent event,
    Emitter<ComboState> emit,
  ) async {
    final result = await deleteCombo(event.id);
    await result.fold(
      (failure) async {
        final current = state;
        if (current is ComboLoaded) {
          emit(ComboLoaded(
            combos: current.combos,
            totalCount: current.totalCount,
            page: current.page,
            pageSize: current.pageSize,
            errorMessage: failure.message,
            isRefreshing: false,
            stamp: DateTime.now().microsecondsSinceEpoch,
          ));
        } else {
          emit(ComboError(failure.message));
        }
      },
      (message) async => _fetch(emit, successMessage: message),
    );
  }

  Future<void> _onToggleComboStatus(
    ToggleComboStatusEvent event,
    Emitter<ComboState> emit,
  ) async {
    final result = await toggleComboStatus(event.id);
    await result.fold(
      (failure) async {
        final current = state;
        if (current is ComboLoaded) {
          emit(ComboLoaded(
            combos: current.combos,
            totalCount: current.totalCount,
            page: current.page,
            pageSize: current.pageSize,
            errorMessage: failure.message,
            isRefreshing: false,
            stamp: DateTime.now().microsecondsSinceEpoch,
          ));
        } else {
          emit(ComboError(failure.message));
        }
      },
      (_) async {
        await _fetch(
          emit,
          successMessage:
              'Đã cập nhật trạng thái combo sang ${!event.currentIsActive ? "Đang bán" : "Ngừng bán"}.',
        );
      },
    );
  }
}
