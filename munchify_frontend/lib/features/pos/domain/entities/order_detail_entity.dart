import 'package:equatable/equatable.dart';

/// Một dòng chi tiết trong đơn hàng đã hoàn tất (snapshot lịch sử).
class OrderDetailEntity extends Equatable {
  final String productName;
  final String unitName;
  final double unitPrice;
  final int quantity;
  final double totalAmount;

  const OrderDetailEntity({
    required this.productName,
    required this.unitName,
    required this.unitPrice,
    required this.quantity,
    required this.totalAmount,
  });

  @override
  List<Object?> get props => [
        productName,
        unitName,
        unitPrice,
        quantity,
        totalAmount,
      ];
}
