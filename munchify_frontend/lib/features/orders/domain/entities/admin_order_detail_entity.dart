import 'package:equatable/equatable.dart';

class AdminOrderDetailItemEntity extends Equatable {
  final String productName;
  final String unitName;
  final double unitPrice;
  final int quantity;
  final double discountAmount;
  final double totalAmount;

  const AdminOrderDetailItemEntity({
    required this.productName,
    required this.unitName,
    required this.unitPrice,
    required this.quantity,
    required this.discountAmount,
    required this.totalAmount,
  });

  @override
  List<Object?> get props => [
        productName,
        unitName,
        unitPrice,
        quantity,
        discountAmount,
        totalAmount,
      ];
}

class AdminOrderPaymentEntity extends Equatable {
  final int paymentId;
  final String paymentMethod;
  final double amount;
  final String paymentStatus;
  final String? transactionCode;
  final double? cashGiven;
  final double? changeAmount;
  final DateTime? paidAt;

  const AdminOrderPaymentEntity({
    required this.paymentId,
    required this.paymentMethod,
    required this.amount,
    required this.paymentStatus,
    this.transactionCode,
    this.cashGiven,
    this.changeAmount,
    this.paidAt,
  });

  @override
  List<Object?> get props => [
        paymentId,
        paymentMethod,
        amount,
        paymentStatus,
        transactionCode,
        cashGiven,
        changeAmount,
        paidAt,
      ];
}

class AdminOrderDetailEntity extends Equatable {
  final int orderId;
  final String orderCode;
  final double subtotal;
  final double discountAmount;
  final double totalAmount;
  final int pointsEarned;
  final int pointsRedeemed;
  final String orderStatus;
  final String paymentStatus;
  final String? customerName;
  final String? customerPhone;
  final String? staffName;
  final double? cashGiven;
  final double? changeAmount;
  final AdminOrderPaymentEntity payment;
  final List<AdminOrderDetailItemEntity> orderDetails;
  final DateTime createdAt;

  const AdminOrderDetailEntity({
    required this.orderId,
    required this.orderCode,
    required this.subtotal,
    required this.discountAmount,
    required this.totalAmount,
    required this.pointsEarned,
    required this.pointsRedeemed,
    required this.orderStatus,
    required this.paymentStatus,
    this.customerName,
    this.customerPhone,
    this.staffName,
    this.cashGiven,
    this.changeAmount,
    required this.payment,
    required this.orderDetails,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        orderId,
        orderCode,
        subtotal,
        discountAmount,
        totalAmount,
        pointsEarned,
        pointsRedeemed,
        orderStatus,
        paymentStatus,
        customerName,
        customerPhone,
        staffName,
        cashGiven,
        changeAmount,
        payment,
        orderDetails,
        createdAt,
      ];
}
