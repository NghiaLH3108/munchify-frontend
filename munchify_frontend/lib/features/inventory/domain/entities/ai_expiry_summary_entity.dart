import 'package:equatable/equatable.dart';

class AiExpirySummaryEntity extends Equatable {
  final int totalPendingAlerts;
  final int urgentPendingAlerts;
  final double estFinancialLoss;
  final double lossTrendPercent;
  final int autoResolvedThisMonth;
  final double recoveredCapital;

  const AiExpirySummaryEntity({
    required this.totalPendingAlerts,
    required this.urgentPendingAlerts,
    required this.estFinancialLoss,
    required this.lossTrendPercent,
    required this.autoResolvedThisMonth,
    required this.recoveredCapital,
  });

  @override
  List<Object?> get props => [
        totalPendingAlerts,
        urgentPendingAlerts,
        estFinancialLoss,
        lossTrendPercent,
        autoResolvedThisMonth,
        recoveredCapital,
      ];
}
