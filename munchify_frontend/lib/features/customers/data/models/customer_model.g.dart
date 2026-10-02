// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'customer_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CustomerModel _$CustomerModelFromJson(Map<String, dynamic> json) =>
    CustomerModel(
      customerId: (json['customerId'] as num).toInt(),
      customerName: json['customerName'] as String,
      phone: json['phone'] as String,
      loyaltyPoints: (json['loyaltyPoints'] as num).toInt(),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$CustomerModelToJson(CustomerModel instance) =>
    <String, dynamic>{
      'customerId': instance.customerId,
      'customerName': instance.customerName,
      'phone': instance.phone,
      'loyaltyPoints': instance.loyaltyPoints,
      'createdAt': instance.createdAt.toIso8601String(),
    };
