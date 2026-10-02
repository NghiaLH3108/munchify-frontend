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
    emit(UnitLoading());

    final result = await getUnits(
      searchTerm: event.searchTerm,
      isActive: event.isActive,
      page: event.page,
      pageSize: event.pageSize,
    );

    result.fold(
      (failure) => emit(UnitError(failure.message)),
      (units) => emit(UnitLoaded(
        units: units,
        isListEnd: units.length < event.pageSize,
      )),
    );
  }

  Future<void> _onCreateUnit(
    CreateUnitEvent event,
    Emitter<UnitState> emit,
  ) async {
    final currentState = state;

    emit(UnitLoading());

    final result = await createUnit(
      unitName: event.unitName,
      description: event.description,
      isActive: event.isActive,
    );

    result.fold(
      (failure) => emit(UnitError(failure.message)),
      (newUnit) {
        if (currentState is UnitLoaded) {
          emit(UnitLoaded(
            units: [newUnit, ...currentState.units],
            isListEnd: currentState.isListEnd,
            successMessage: 'Đã thêm đơn vị tính thành công.',
          ));
        } else {
          emit(UnitLoaded(
              units: [newUnit], successMessage: 'Đã thêm đơn vị tính thành công.'));
        }
      },
    );
  }

  Future<void> _onUpdateUnit(
    UpdateUnitEvent event,
    Emitter<UnitState> emit,
  ) async {
    final currentState = state;

    emit(UnitLoading());

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

          emit(UnitLoaded(
            units: updated,
            isListEnd: currentState.isListEnd,
            successMessage: 'Đã cập nhật đơn vị tính thành công.',
          ));
        } else {
          emit(UnitLoaded(
              units: [updatedUnit],
              successMessage: 'Đã cập nhật đơn vị tính thành công.'));
        }
      },
    );
  }

  Future<void> _onDeleteUnit(
    DeleteUnitEvent event,
    Emitter<UnitState> emit,
  ) async {
    final currentState = state;

    emit(UnitLoading());

    final result = await deleteUnit(event.id);

    result.fold(
      (failure) => emit(UnitError(failure.message)),
      (success) {
        if (currentState is UnitLoaded) {
          final updated =
              currentState.units.where((u) => u.id != event.id).toList();

          emit(UnitLoaded(
            units: updated,
            isListEnd: currentState.isListEnd,
            successMessage: 'Đã xóa đơn vị tính.',
          ));
        } else {
          emit(const UnitLoaded(units: [], successMessage: 'Đã xóa đơn vị tính.'));
        }
      },
    );
  }
}
