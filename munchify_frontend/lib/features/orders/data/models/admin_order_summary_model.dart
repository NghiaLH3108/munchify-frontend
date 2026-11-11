import '../../domain/entities/admin_order_summary_entity.dart';

class AdminOrderSummaryModel extends AdminOrderSummaryEntity {
  const AdminOrderSummaryModel({
    required super.orderId,
    required super.orderCode,
    required super.totalAmount,
    required super.orderStatus,
    required super.paymentStatus,
    required super.paymentMethod,
    required super.pointsEarned,
    super.customerName,
    super.customerPhone,
    super.staffName,
    required super.createdAt,
    required super.itemCount,
  });

  factory AdminOrderSummaryModel.fromJson(Map<String, dynamic> json) {
    return AdminOrderSummaryModel(
      orderId: json['orderId'] ?? 0,
      orderCode: json['orderCode'] ?? '',
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      orderStatus: json['orderStatus'] ?? 'COMPLETED',
      paymentStatus: json['paymentStatus'] ?? 'PAID',
      paymentMethod: json['paymentMethod'] ?? 'CASH',
      pointsEarned: json['pointsEarned'] ?? 0,
      customerName: json['customerName'],
      customerPhone: json['customerPhone'],
      staffName: json['staffName'],
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt']) ?? DateTime.now()
          : DateTime.now(),
      itemCount: json['itemCount'] ?? 0,
    );
  }
}
