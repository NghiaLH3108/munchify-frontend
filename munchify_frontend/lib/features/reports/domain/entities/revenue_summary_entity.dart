import 'package:equatable/equatable.dart';

class PaymentMethodBreakdownEntity extends Equatable {
  final String paymentMethod;
  final double amount;
  final int count;

  const PaymentMethodBreakdownEntity({
    required this.paymentMethod,
    required this.amount,
    required this.count,
  });

  @override
  List<Object?> get props => [paymentMethod, amount, count];
}

class RevenueDataPointEntity extends Equatable {
  final String label;
  final double revenue;
  final int orderCount;

  const RevenueDataPointEntity({
    required this.label,
    required this.revenue,
    required this.orderCount,
  });

  @override
  List<Object?> get props => [label, revenue, orderCount];
}

class RevenueSummaryEntity extends Equatable {
  final double totalRevenue;
  final int orderCount;
  final double avgOrderValue;
  final List<PaymentMethodBreakdownEntity> byPaymentMethod;
  final List<RevenueDataPointEntity> dataPoints;

  const RevenueSummaryEntity({
    required this.totalRevenue,
    required this.orderCount,
    required this.avgOrderValue,
    required this.byPaymentMethod,
    required this.dataPoints,
  });

  @override
  List<Object?> get props =>
      [totalRevenue, orderCount, avgOrderValue, byPaymentMethod, dataPoints];
}
