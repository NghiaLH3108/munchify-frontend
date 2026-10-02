import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/customer_point_history_entity.dart';

part 'customer_point_history_model.g.dart';

@JsonSerializable()
class CustomerPointHistoryModel implements CustomerPointHistoryEntity {
  @override
  final int orderId;
  @override
  final String orderCode;
  @override
  final int pointsEarned;
  @override
  final int pointsRedeemed;
  @override
  final double totalAmount;
  @override
  final DateTime createdAt;

  CustomerPointHistoryModel({
    required this.orderId,
    required this.orderCode,
    required this.pointsEarned,
    required this.pointsRedeemed,
    required this.totalAmount,
    required this.createdAt,
  });

  factory CustomerPointHistoryModel.fromJson(Map<String, dynamic> json) =>
      _$CustomerPointHistoryModelFromJson(json);

  Map<String, dynamic> toJson() => _$CustomerPointHistoryModelToJson(this);
}