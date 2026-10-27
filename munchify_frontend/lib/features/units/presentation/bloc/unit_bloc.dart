import 'package:flutter_bloc/flutter_bloc.dart';
import 'unit_event.dart';
import 'unit_state.dart';
import '../../domain/usecases/manage_unit_usecases.dart';

class UnitBloc extends Bloc<UnitEvent, UnitState> {
  final GetUnitsUseCase getUnits;
  final CreateUnitUseCase createUnit;
  final UpdateUnitUseCase updateUnit;
  final DeleteUnitUseCase deleteUnit;

  UnitBloc({
    required this.getUnits,
    required this.createUnit,
    required this.updateUnit,
    required this.deleteUnit,
  }) : super(UnitInitial()) {
    on<LoadUnitsEvent>(_onLoadUnits);
    on<CreateUnitEvent>(_onCreateUnit);
    on<UpdateUnitEvent>(_onUpdateUnit);
    on<DeleteUnitEvent>(_onDeleteUnit);
  }

  Future<void> _onLoadUnits(
    LoadUnitsEvent event,
    Emitter<UnitState> emit,
  ) async {
    final currentState = state;
    if (currentState is UnitLoaded) {
      emit(UnitLoaded(
        units: currentState.units,
        allUnits: currentState.allUnits,
        isListEnd: currentState.isListEnd,
        isRefreshing: true,
      ));
    } else {
      emit(UnitLoading());
    }

    final result = await getUnits(
      searchTerm: event.searchTerm,
      isActive: event.isActive,
      page: event.page,
      pageSize: event.pageSize,
    );

    result.fold(
      (failure) => emit(UnitError(failure.message)),
      (units) {
        final isUnfiltered = event.isActive == null &&
            event.searchTerm.trim().isEmpty &&
            event.page == 1;
        final prevAll =
            currentState is UnitLoaded ? currentState.allUnits : null;
        emit(UnitLoaded(
          units: units,
          allUnits: isUnfiltered ? units : (prevAll ?? units),
          isListEnd: units.length < event.pageSize,
          isRefreshing: false,
        ));
      },
    );
  }

  Future<void> _onCreateUnit(
    CreateUnitEvent event,
    Emitter<UnitState> emit,
  ) async {
    final currentState = state;

    final result = await createUnit(
      unitName: event.unitName,
      description: event.description,
      isActive: event.isActive,
    );

    result.fold(
      (failure) => emit(UnitError(failure.message)),
      (newUnit) {
        if (currentState is UnitLoaded) {
          final updatedAll = [
            newUnit,
            ...(currentState.allUnits ?? currentState.units),
          ];
          emit(UnitLoaded(
            units: [newUnit, ...currentState.units],
            allUnits: updatedAll,
            isListEnd: currentState.isListEnd,
            isRefreshing: false,
            successMessage: 'Đã thêm đơn vị tính thành công.',
          ));
        } else {
          emit(UnitLoaded(
            units: [newUnit],
            allUnits: [newUnit],
            successMessage: 'Đã thêm đơn vị tính thành công.',
          ));
        }
      },
    );
  }

  Future<void> _onUpdateUnit(
    UpdateUnitEvent event,
    Emitter<UnitState> emit,
  ) async {
    final currentState = state;

    final result = await updateUnit(
      id: event.id,
      unitName: event.unitName,
      description: event.description,
      isActive: event.isActive,
    );

    result.fold(
      (failure) => emit(UnitError(failure.message)),
      (updatedUnit) {
        if (currentState is UnitLoaded) {
          final updated = currentState.units.map((u) {
            return u.id == updatedUnit.id ? updatedUnit : u;
          }).toList();
          final updatedAll =
              (currentState.allUnits ?? currentState.units).map((u) {
            return u.id == updatedUnit.id ? updatedUnit : u;
          }).toList();

          emit(UnitLoaded(
            units: updated,
            allUnits: updatedAll,
            isListEnd: currentState.isListEnd,
            isRefreshing: false,
            successMessage: 'Đã cập nhật đơn vị tính thành công.',
          ));
        } else {
          emit(UnitLoaded(
            units: [updatedUnit],
            allUnits: [updatedUnit],
            successMessage: 'Đã cập nhật đơn vị tính thành công.',
          ));
        }
      },
    );
  }

  Future<void> _onDeleteUnit(
    DeleteUnitEvent event,
    Emitter<UnitState> emit,
  ) async {
    final currentState = state;

    final result = await deleteUnit(event.id);

    result.fold(
      (failure) => emit(UnitError(failure.message)),
      (success) {
        if (currentState is UnitLoaded) {
          final updated =
              currentState.units.where((u) => u.id != event.id).toList();
          final updatedAll =
              (currentState.allUnits ?? currentState.units)
                  .where((u) => u.id != event.id)
                  .toList();

          emit(UnitLoaded(
            units: updated,
            allUnits: updatedAll,
            isListEnd: currentState.isListEnd,
            isRefreshing: false,
            successMessage: 'Đã xóa đơn vị tính.',
          ));
        } else {
          emit(const UnitLoaded(
            units: [],
            allUnits: [],
            successMessage: 'Đã xóa đơn vị tính.',
          ));
        }
      },
    );
  }
}
