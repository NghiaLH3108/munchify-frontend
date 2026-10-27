import 'package:equatable/equatable.dart';
import '../../domain/entities/stock_movement_entity.dart';

abstract class StockMovementState extends Equatable {
  const StockMovementState();

  @override
  List<Object?> get props => [];
}

class StockMovementInitial extends StockMovementState {}

class StockMovementLoading extends StockMovementState {}

class StockMovementLoaded extends StockMovementState {
  final List<StockMovementEntity> movements;
  final bool hasReachedMax;
  final int currentPage;

  const StockMovementLoaded({
    required this.movements,
    required this.hasReachedMax,
    required this.currentPage,
  });

  StockMovementLoaded copyWith({
    List<StockMovementEntity>? movements,
    bool? hasReachedMax,
    int? currentPage,
  }) {
    return StockMovementLoaded(
      movements: movements ?? this.movements,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      currentPage: currentPage ?? this.currentPage,
    );
  }

  @override
  List<Object?> get props => [movements, hasReachedMax, currentPage];
}

class StockMovementError extends StockMovementState {
  final String message;

  const StockMovementError(this.message);

  @override
  List<Object?> get props => [message];
}
