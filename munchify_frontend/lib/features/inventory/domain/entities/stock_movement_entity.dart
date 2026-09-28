import 'package:equatable/equatable.dart';

class StockMovementEntity extends Equatable {
  final int stockMovementId;
  final int productId;
  final String productName;
  final int userId;
  final String staffName;
  final String movementType;
  final int quantity;
  final int previousQuantity;
  final int newQuantity;
  final String? referenceType;
  final int? referenceId;
  final String? reason;
  final DateTime createdAt;

  const StockMovementEntity({
    required this.stockMovementId,
    required this.productId,
    required this.productName,
    required this.userId,
    required this.staffName,
    required this.movementType,
    required this.quantity,
    required this.previousQuantity,
    required this.newQuantity,
    this.referenceType,
    this.referenceId,
    this.reason,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        stockMovementId,
        productId,
        productName,
        userId,
        staffName,
        movementType,
        quantity,
        previousQuantity,
        newQuantity,
        referenceType,
        referenceId,
        reason,
        createdAt,
      ];
}
