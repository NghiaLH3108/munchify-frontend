import 'package:json_annotation/json_annotation.dart';
import 'package:munchify_frontend/features/inventory/domain/entities/stock_movement_entity.dart';

part 'stock_movement_model.g.dart';

@JsonSerializable()
class StockMovementModel extends StockMovementEntity {
  const StockMovementModel({
    required super.stockMovementId,
    required super.productId,
    required super.productName,
    required super.userId,
    required super.staffName,
    required super.movementType,
    required super.quantity,
    required super.previousQuantity,
    required super.newQuantity,
    super.referenceType,
    super.referenceId,
    super.reason,
    required super.createdAt,
  });

  factory StockMovementModel.fromJson(Map<String, dynamic> json) =>
      _$StockMovementModelFromJson(json);

  Map<String, dynamic> toJson() => _$StockMovementModelToJson(this);
}
