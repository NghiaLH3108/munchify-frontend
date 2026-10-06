import 'package:equatable/equatable.dart';

class DamagedExpiredRecordEntity extends Equatable {
  final int recordId;
  final int importDetailId;
  final int productId;
  final String productName;
  final String unitName;
  final int quantity;
  final String status;
  final String? aiAnalysis;
  final DateTime createdAt;
  final DateTime? processedAt;

  const DamagedExpiredRecordEntity({
    required this.recordId,
    required this.importDetailId,
    required this.productId,
    required this.productName,
    required this.unitName,
    required this.quantity,
    required this.status,
    this.aiAnalysis,
    required this.createdAt,
    this.processedAt,
  });

  @override
  List<Object?> get props => [
        recordId,
        importDetailId,
        productId,
        productName,
        unitName,
        quantity,
        status,
        aiAnalysis,
        createdAt,
        processedAt,
      ];
}
