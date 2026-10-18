import 'package:equatable/equatable.dart';

/// Thông tin thanh toán của một đơn hàng.
class PaymentInfoEntity extends Equatable {
  final int paymentId;
  final String paymentMethod; // CASH | QR_CODE | BANK_TRANSFER
  final double amount;
  final String paymentStatus; // PENDING | PAID | FAILED | REFUNDED
  final String? transactionCode;

  const PaymentInfoEntity({
    required this.paymentId,
    required this.paymentMethod,
    required this.amount,
    required this.paymentStatus,
    this.transactionCode,
  });

  @override
  List<Object?> get props => [
        paymentId,
        paymentMethod,
        amount,
        paymentStatus,
        transactionCode,
      ];
}
