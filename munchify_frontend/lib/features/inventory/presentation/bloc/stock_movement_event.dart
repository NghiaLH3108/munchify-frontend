import 'package:equatable/equatable.dart';

abstract class StockMovementEvent extends Equatable {
  const StockMovementEvent();

  @override
  List<Object?> get props => [];
}

class LoadStockMovements extends StockMovementEvent {
  final int? productId;
  final String? movementType;
  final DateTime? from;
  final DateTime? to;

  const LoadStockMovements({
    this.productId,
    this.movementType,
    this.from,
    this.to,
  });

  @override
  List<Object?> get props => [productId, movementType, from, to];
}

class LoadNextPage extends StockMovementEvent {}

class AdjustStockEvent extends StockMovementEvent {
  final int productId;
  final int quantityChange;
  final String reason;
  final String movementType;

  const AdjustStockEvent({
    required this.productId,
    required this.quantityChange,
    required this.reason,
    required this.movementType,
  });

  @override
  List<Object?> get props => [productId, quantityChange, reason, movementType];
}
