import '../../domain/entities/order_entity.dart';
import 'order_detail_model.dart';
import 'payment_info_model.dart';

class OrderModel extends OrderEntity {
  const OrderModel({
    required super.orderId,
    required super.orderCode,
    required super.subtotal,
    required super.discountAmount,
    required super.totalAmount,
    required super.pointsEarned,
    required super.pointsRedeemed,
    required super.orderStatus,
    required super.payment,
    required super.orderDetails,
    super.itemCount,
    required super.createdAt,
    super.customerName,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final rawDetails = json['orderDetails'] as List<dynamic>? ?? [];
    final rawPayment = json['payment'] as Map<String, dynamic>? ??
        {
          'paymentId': 0,
          'paymentMethod': json['paymentMethod'] ?? 'CASH',
          'amount': json['totalAmount'] ?? 0,
          'paymentStatus': json['paymentStatus'] ?? 'PAID',
        };
    final parsedDetails = rawDetails
        .map((d) => OrderDetailModel.fromJson(d as Map<String, dynamic>))
        .toList();

    return OrderModel(
      orderId: json['orderId'] ?? 0,
      orderCode: json['orderCode'] ?? '',
      subtotal: (json['subtotal'] ?? json['totalAmount'] ?? 0).toDouble(),
      discountAmount: (json['discountAmount'] ?? 0).toDouble(),
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      pointsEarned: json['pointsEarned'] ?? 0,
      pointsRedeemed: json['pointsRedeemed'] ?? 0,
      orderStatus: json['orderStatus'] ?? 'COMPLETED',
      payment: PaymentInfoModel.fromJson(rawPayment),
      orderDetails: parsedDetails,
      itemCount: json['itemCount'] ?? parsedDetails.length,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt']) ?? DateTime.now()
          : DateTime.now(),
      customerName: json['customerName'],
    );
  }
}
