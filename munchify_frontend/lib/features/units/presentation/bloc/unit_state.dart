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
  final bool isListEnd;
  final String? successMessage;

  const UnitLoaded({
    required this.units,
    this.isListEnd = false,
    this.successMessage,
  });

  @override
  List<Object?> get props => [units, isListEnd, successMessage];
}

class UnitError extends UnitState {
  final String message;

  const UnitError(this.message);

  @override
  List<Object?> get props => [message];
}
