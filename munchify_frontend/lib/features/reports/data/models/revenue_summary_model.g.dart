// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'revenue_summary_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PaymentMethodBreakdownModel _$PaymentMethodBreakdownModelFromJson(
  Map<String, dynamic> json,
) => PaymentMethodBreakdownModel(
  paymentMethod: json['paymentMethod'] as String? ?? '',
  amount: json['amount'] as num? ?? 0,
  count: (json['count'] as num?)?.toInt() ?? 0,
);

RevenueDataPointModel _$RevenueDataPointModelFromJson(
  Map<String, dynamic> json,
) => RevenueDataPointModel(
  label: json['label'] as String? ?? '',
  revenue: json['revenue'] as num? ?? 0,
  orderCount: (json['orderCount'] as num?)?.toInt() ?? 0,
);

RevenueSummaryModel _$RevenueSummaryModelFromJson(Map<String, dynamic> json) =>
    RevenueSummaryModel(
      totalRevenue: json['totalRevenue'] as num? ?? 0,
      orderCount: (json['orderCount'] as num?)?.toInt() ?? 0,
      avgOrderValue: json['avgOrderValue'] as num? ?? 0,
      byPaymentMethod:
          (json['byPaymentMethod'] as List<dynamic>?)
              ?.map(
                (e) => PaymentMethodBreakdownModel.fromJson(
                  e as Map<String, dynamic>,
                ),
              )
              .toList() ??
          [],
      dataPoints:
          (json['dataPoints'] as List<dynamic>?)
              ?.map(
                (e) =>
                    RevenueDataPointModel.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
    );
