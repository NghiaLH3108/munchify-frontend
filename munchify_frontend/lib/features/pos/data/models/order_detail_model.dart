import '../../domain/entities/order_detail_entity.dart';

class OrderDetailModel extends OrderDetailEntity {
  const OrderDetailModel({
    required super.productName,
    required super.unitName,
    required super.unitPrice,
    required super.quantity,
    required super.totalAmount,
  });

  factory OrderDetailModel.fromJson(Map<String, dynamic> json) {
    return OrderDetailModel(
      productName: json['productName'] ?? '',
      unitName: json['unitName'] ?? '',
      unitPrice: (json['unitPrice'] ?? 0).toDouble(),
      quantity: json['quantity'] ?? 0,
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
    );
  }
}
