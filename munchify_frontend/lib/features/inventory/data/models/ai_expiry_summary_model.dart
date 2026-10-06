import '../../domain/entities/ai_expiry_summary_entity.dart';

class AiExpirySummaryModel extends AiExpirySummaryEntity {
  const AiExpirySummaryModel({
    required int totalPendingAlerts,
    required int urgentPendingAlerts,
    required double estFinancialLoss,
    required double lossTrendPercent,
    required int autoResolvedThisMonth,
    required double recoveredCapital,
  }) : super(
          totalPendingAlerts: totalPendingAlerts,
          urgentPendingAlerts: urgentPendingAlerts,
          estFinancialLoss: estFinancialLoss,
          lossTrendPercent: lossTrendPercent,
          autoResolvedThisMonth: autoResolvedThisMonth,
          recoveredCapital: recoveredCapital,
        );

  factory AiExpirySummaryModel.fromJson(Map<String, dynamic> json) {
    return AiExpirySummaryModel(
      totalPendingAlerts: json['totalPendingAlerts'] ?? 0,
      urgentPendingAlerts: json['urgentPendingAlerts'] ?? 0,
      estFinancialLoss: (json['estFinancialLoss'] ?? 0).toDouble(),
      lossTrendPercent: (json['lossTrendPercent'] ?? 0).toDouble(),
      autoResolvedThisMonth: json['autoResolvedThisMonth'] ?? 0,
      recoveredCapital: (json['recoveredCapital'] ?? 0).toDouble(),
    );
  }
}
