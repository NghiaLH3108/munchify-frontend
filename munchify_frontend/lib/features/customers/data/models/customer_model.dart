import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/customer_entity.dart';

part 'customer_model.g.dart';

@JsonSerializable()
class CustomerModel extends CustomerEntity {
  const CustomerModel({
    required super.customerId,
    required super.customerName,
    required super.phone,
    required super.loyaltyPoints,
    required super.createdAt,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) => _$CustomerModelFromJson(json);

  Map<String, dynamic> toJson() => _$CustomerModelToJson(this);
}
