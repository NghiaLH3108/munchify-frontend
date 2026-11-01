import 'package:equatable/equatable.dart';

class DamagedExpiredRecordEntity extends Equatable {
  final int recordId;
  final int? importDetailId;
  final String? batchCode;
  final DateTime? expiryDate;
  final int productId;
  final String productName;
  final String unitName;
  final int quantity;
  final String reportType;
  final String status;
  final String? reason;
  final String? aiAnalysis;
  final DateTime createdAt;
  final DateTime? processedAt;

  const DamagedExpiredRecordEntity({
    required this.recordId,
    this.importDetailId,
    this.batchCode,
    this.expiryDate,
    required this.productId,
    required this.productName,
    required this.unitName,
    required this.quantity,
    this.reportType = 'EXPIRED',
    required this.status,
    this.reason,
    this.aiAnalysis,
    required this.createdAt,
    this.processedAt,
  });

  @override
  List<Object?> get props => [
        recordId,
        importDetailId,
        batchCode,
        expiryDate,
        productId,
        productName,
        unitName,
        quantity,
        reportType,
        status,
        reason,
        aiAnalysis,
        createdAt,
        processedAt,
      ];
}
