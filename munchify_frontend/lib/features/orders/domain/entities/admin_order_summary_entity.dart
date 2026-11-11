import 'package:equatable/equatable.dart';

class AdminOrderSummaryEntity extends Equatable {
  final int orderId;
  final String orderCode;
  final double totalAmount;
  final String orderStatus;
  final String paymentStatus;
  final String paymentMethod;
  final int pointsEarned;
  final String? customerName;
  final String? customerPhone;
  final String? staffName;
  final DateTime createdAt;
  final int itemCount;

  const AdminOrderSummaryEntity({
    required this.orderId,
    required this.orderCode,
    required this.totalAmount,
    required this.orderStatus,
    required this.paymentStatus,
    required this.paymentMethod,
    required this.pointsEarned,
    this.customerName,
    this.customerPhone,
    this.staffName,
    required this.createdAt,
    required this.itemCount,
  });

  @override
  List<Object?> get props => [
        orderId,
        orderCode,
        totalAmount,
        orderStatus,
        paymentStatus,
        paymentMethod,
        pointsEarned,
        customerName,
        customerPhone,
        staffName,
        createdAt,
        itemCount,
      ];
}
