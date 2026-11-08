import 'package:equatable/equatable.dart';
import 'order_detail_entity.dart';
import 'payment_info_entity.dart';

/// Đơn hàng đã được tạo thành công – trả về từ POST /api/orders hoặc GET /api/orders.
class OrderEntity extends Equatable {
  final int orderId;
  final String orderCode;
  final double subtotal;
  final double discountAmount;
  final double totalAmount;
  final int pointsEarned;
  final int pointsRedeemed;
  final String orderStatus; // PENDING | COMPLETED | CANCELLED
  final PaymentInfoEntity payment;
  final List<OrderDetailEntity> orderDetails;
  final int itemCount;
  final DateTime createdAt;
  final String? customerName;

  const OrderEntity({
    required this.orderId,
    required this.orderCode,
    required this.subtotal,
    required this.discountAmount,
    required this.totalAmount,
    required this.pointsEarned,
    required this.pointsRedeemed,
    required this.orderStatus,
    required this.payment,
    required this.orderDetails,
    this.itemCount = 0,
    required this.createdAt,
    this.customerName,
  });

  int get effectiveItemCount =>
      orderDetails.isNotEmpty ? orderDetails.length : itemCount;

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
        payment,
        orderDetails,
        itemCount,
        createdAt,
        customerName,
      ];
}
