import '../../domain/entities/payment_info_entity.dart';

class PaymentInfoModel extends PaymentInfoEntity {
  const PaymentInfoModel({
    required super.paymentId,
    required super.paymentMethod,
    required super.amount,
    required super.paymentStatus,
    super.transactionCode,
  });

  factory PaymentInfoModel.fromJson(Map<String, dynamic> json) {
    return PaymentInfoModel(
      paymentId: json['paymentId'] ?? 0,
      paymentMethod: json['paymentMethod'] ?? 'CASH',
      amount: (json['amount'] ?? 0).toDouble(),
      paymentStatus: json['paymentStatus'] ?? 'PENDING',
      transactionCode: json['transactionCode'],
    );
  }
}
