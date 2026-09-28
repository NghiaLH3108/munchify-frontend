// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stock_movement_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StockMovementModel _$StockMovementModelFromJson(Map<String, dynamic> json) =>
    StockMovementModel(
      stockMovementId: (json['stockMovementId'] as num).toInt(),
      productId: (json['productId'] as num).toInt(),
      productName: json['productName'] as String,
      userId: (json['userId'] as num).toInt(),
      staffName: json['staffName'] as String,
      movementType: json['movementType'] as String,
      quantity: (json['quantity'] as num).toInt(),
      previousQuantity: (json['previousQuantity'] as num).toInt(),
      newQuantity: (json['newQuantity'] as num).toInt(),
      referenceType: json['referenceType'] as String?,
      referenceId: (json['referenceId'] as num?)?.toInt(),
      reason: json['reason'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$StockMovementModelToJson(StockMovementModel instance) =>
    <String, dynamic>{
      'stockMovementId': instance.stockMovementId,
      'productId': instance.productId,
      'productName': instance.productName,
      'userId': instance.userId,
      'staffName': instance.staffName,
      'movementType': instance.movementType,
      'quantity': instance.quantity,
      'previousQuantity': instance.previousQuantity,
      'newQuantity': instance.newQuantity,
      'referenceType': instance.referenceType,
      'referenceId': instance.referenceId,
      'reason': instance.reason,
      'createdAt': instance.createdAt.toIso8601String(),
    };
