// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'customer_point_history_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CustomerPointHistoryModel _$CustomerPointHistoryModelFromJson(
  Map<String, dynamic> json,
) => CustomerPointHistoryModel(
  orderId: (json['orderId'] as num).toInt(),
  orderCode: json['orderCode'] as String,
  pointsEarned: (json['pointsEarned'] as num).toInt(),
  pointsRedeemed: (json['pointsRedeemed'] as num).toInt(),
  totalAmount: (json['totalAmount'] as num).toDouble(),
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$CustomerPointHistoryModelToJson(
  CustomerPointHistoryModel instance,
) => <String, dynamic>{
  'orderId': instance.orderId,
  'orderCode': instance.orderCode,
  'pointsEarned': instance.pointsEarned,
  'pointsRedeemed': instance.pointsRedeemed,
  'totalAmount': instance.totalAmount,
  'createdAt': instance.createdAt.toIso8601String(),
};
