import 'package:equatable/equatable.dart';
import '../../domain/entities/unit_entity.dart';

abstract class UnitState extends Equatable {
  const UnitState();

  @override
  List<Object?> get props => [];
}

class UnitInitial extends UnitState {}

class UnitLoading extends UnitState {}

class UnitLoaded extends UnitState {
  final List<UnitEntity> units;
  final List<UnitEntity>? allUnits;
  final bool isListEnd;
  final bool isRefreshing;
  final String? successMessage;

  const UnitLoaded({
    required this.units,
    this.allUnits,
    this.isListEnd = false,
    this.isRefreshing = false,
    this.successMessage,
  });

  List<UnitEntity> get kpiUnits => allUnits ?? units;

  @override
  List<Object?> get props => [
        units,
        allUnits,
        isListEnd,
        isRefreshing,
        successMessage,
      ];
}

class UnitError extends UnitState {
  final String message;

  const UnitError(this.message);

  @override
  List<Object?> get props => [message];
}
