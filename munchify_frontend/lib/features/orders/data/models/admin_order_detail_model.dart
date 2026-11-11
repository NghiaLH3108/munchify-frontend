import '../../domain/entities/admin_order_detail_entity.dart';

class AdminOrderDetailItemModel extends AdminOrderDetailItemEntity {
  const AdminOrderDetailItemModel({
    required super.productName,
    required super.unitName,
    required super.unitPrice,
    required super.quantity,
    required super.discountAmount,
    required super.totalAmount,
  });

  factory AdminOrderDetailItemModel.fromJson(Map<String, dynamic> json) {
    return AdminOrderDetailItemModel(
      productName: json['productName'] ?? '',
      unitName: json['unitName'] ?? '',
      unitPrice: (json['unitPrice'] ?? 0).toDouble(),
      quantity: json['quantity'] ?? 0,
      discountAmount: (json['discountAmount'] ?? 0).toDouble(),
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
    );
  }
}

class AdminOrderPaymentModel extends AdminOrderPaymentEntity {
  const AdminOrderPaymentModel({
    required super.paymentId,
    required super.paymentMethod,
    required super.amount,
    required super.paymentStatus,
    super.transactionCode,
    super.cashGiven,
    super.changeAmount,
    super.paidAt,
  });

  factory AdminOrderPaymentModel.fromJson(Map<String, dynamic> json) {
    return AdminOrderPaymentModel(
      paymentId: json['paymentId'] ?? 0,
      paymentMethod: json['paymentMethod'] ?? 'CASH',
      amount: (json['amount'] ?? 0).toDouble(),
      paymentStatus: json['paymentStatus'] ?? 'PAID',
      transactionCode: json['transactionCode'],
      cashGiven: json['cashGiven'] != null ? (json['cashGiven']).toDouble() : null,
      changeAmount: json['changeAmount'] != null ? (json['changeAmount']).toDouble() : null,
      paidAt: json['paidAt'] != null ? DateTime.tryParse(json['paidAt']) : null,
    );
  }
}

class AdminOrderDetailModel extends AdminOrderDetailEntity {
  const AdminOrderDetailModel({
    required super.orderId,
    required super.orderCode,
    required super.subtotal,
    required super.discountAmount,
    required super.totalAmount,
    required super.pointsEarned,
    required super.pointsRedeemed,
    required super.orderStatus,
    required super.paymentStatus,
    super.customerName,
    super.customerPhone,
    super.staffName,
    super.cashGiven,
    super.changeAmount,
    required super.payment,
    required super.orderDetails,
    required super.createdAt,
  });

  factory AdminOrderDetailModel.fromJson(Map<String, dynamic> json) {
    final rawPayment = json['payment'] as Map<String, dynamic>? ?? {};
    final rawDetails = json['orderDetails'] as List<dynamic>? ?? [];

    return AdminOrderDetailModel(
      orderId: json['orderId'] ?? 0,
      orderCode: json['orderCode'] ?? '',
      subtotal: (json['subtotal'] ?? 0).toDouble(),
      discountAmount: (json['discountAmount'] ?? 0).toDouble(),
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      pointsEarned: json['pointsEarned'] ?? 0,
      pointsRedeemed: json['pointsRedeemed'] ?? 0,
      orderStatus: json['orderStatus'] ?? 'COMPLETED',
      paymentStatus: json['paymentStatus'] ?? 'PAID',
      customerName: json['customerName'],
      customerPhone: json['customerPhone'],
      staffName: json['staffName'],
      cashGiven: json['cashGiven'] != null ? (json['cashGiven']).toDouble() : null,
      changeAmount: json['changeAmount'] != null ? (json['changeAmount']).toDouble() : null,
      payment: AdminOrderPaymentModel.fromJson(rawPayment),
      orderDetails: rawDetails
          .map((d) => AdminOrderDetailItemModel.fromJson(d as Map<String, dynamic>))
          .toList(),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt']) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
