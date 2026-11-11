import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/damaged_expired_record_entity.dart';

part 'damaged_expired_record_model.g.dart';

@JsonSerializable()
class DamagedExpiredRecordModel extends DamagedExpiredRecordEntity {
  @override
  final int recordId;
  @override
  final int? importDetailId;
  @override
  final String? batchCode;
  @override
  final DateTime? expiryDate;
  @override
  final int productId;
  @override
  final String productName;
  @override
  final String unitName;
  @override
  final int quantity;
  @override
  final String reportType;
  @override
  final String status;
  @override
  final String? reason;
  @override
  final String? aiAnalysis;
  @override
  final DateTime createdAt;
  @override
  final DateTime? processedAt;

  const DamagedExpiredRecordModel({
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
  }) : super(
          recordId: recordId,
          importDetailId: importDetailId,
          batchCode: batchCode,
          expiryDate: expiryDate,
          productId: productId,
          productName: productName,
          unitName: unitName,
          quantity: quantity,
          reportType: reportType,
          status: status,
          reason: reason,
          aiAnalysis: aiAnalysis,
          createdAt: createdAt,
          processedAt: processedAt,
        );

  factory DamagedExpiredRecordModel.fromJson(Map<String, dynamic> json) =>
      _$DamagedExpiredRecordModelFromJson(json);

  Map<String, dynamic> toJson() => _$DamagedExpiredRecordModelToJson(this);
}
