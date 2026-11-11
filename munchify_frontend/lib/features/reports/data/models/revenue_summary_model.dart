import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/revenue_summary_entity.dart';

part 'revenue_summary_model.g.dart';

@JsonSerializable(createToJson: false)
class PaymentMethodBreakdownModel {
  @JsonKey(name: 'paymentMethod', defaultValue: '')
  final String paymentMethod;
  @JsonKey(name: 'amount', defaultValue: 0)
  final num amount;
  @JsonKey(name: 'count', defaultValue: 0)
  final int count;

  const PaymentMethodBreakdownModel({
    required this.paymentMethod,
    required this.amount,
    required this.count,
  });

  factory PaymentMethodBreakdownModel.fromJson(Map<String, dynamic> json) =>
      _$PaymentMethodBreakdownModelFromJson(json);

  PaymentMethodBreakdownEntity toEntity() => PaymentMethodBreakdownEntity(
        paymentMethod: paymentMethod,
        amount: amount.toDouble(),
        count: count,
      );
}

@JsonSerializable(createToJson: false)
class RevenueDataPointModel {
  @JsonKey(name: 'label', defaultValue: '')
  final String label;
  @JsonKey(name: 'revenue', defaultValue: 0)
  final num revenue;
  @JsonKey(name: 'orderCount', defaultValue: 0)
  final int orderCount;

  const RevenueDataPointModel({
    required this.label,
    required this.revenue,
    required this.orderCount,
  });

  factory RevenueDataPointModel.fromJson(Map<String, dynamic> json) =>
      _$RevenueDataPointModelFromJson(json);

  RevenueDataPointEntity toEntity() => RevenueDataPointEntity(
        label: label,
        revenue: revenue.toDouble(),
        orderCount: orderCount,
      );
}

@JsonSerializable(createToJson: false)
class RevenueSummaryModel {
  @JsonKey(name: 'totalRevenue', defaultValue: 0)
  final num totalRevenue;
  @JsonKey(name: 'orderCount', defaultValue: 0)
  final int orderCount;
  @JsonKey(name: 'avgOrderValue', defaultValue: 0)
  final num avgOrderValue;
  @JsonKey(name: 'byPaymentMethod', defaultValue: <PaymentMethodBreakdownModel>[])
  final List<PaymentMethodBreakdownModel> byPaymentMethod;
  @JsonKey(name: 'dataPoints', defaultValue: <RevenueDataPointModel>[])
  final List<RevenueDataPointModel> dataPoints;

  const RevenueSummaryModel({
    required this.totalRevenue,
    required this.orderCount,
    required this.avgOrderValue,
    required this.byPaymentMethod,
    required this.dataPoints,
  });

  factory RevenueSummaryModel.fromJson(Map<String, dynamic> json) =>
      _$RevenueSummaryModelFromJson(json);

  RevenueSummaryEntity toEntity() => RevenueSummaryEntity(
        totalRevenue: totalRevenue.toDouble(),
        orderCount: orderCount,
        avgOrderValue: avgOrderValue.toDouble(),
        byPaymentMethod: byPaymentMethod.map((e) => e.toEntity()).toList(),
        dataPoints: dataPoints.map((e) => e.toEntity()).toList(),
      );
}
