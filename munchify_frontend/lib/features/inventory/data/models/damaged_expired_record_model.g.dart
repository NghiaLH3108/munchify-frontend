// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'damaged_expired_record_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DamagedExpiredRecordModel _$DamagedExpiredRecordModelFromJson(
  Map<String, dynamic> json,
) => DamagedExpiredRecordModel(
  recordId: (json['recordId'] as num).toInt(),
  importDetailId: (json['importDetailId'] as num?)?.toInt(),
  productId: (json['productId'] as num).toInt(),
  productName: (json['productName'] as String?) ?? 'Unknown',
  unitName: (json['unitName'] as String?) ?? 'Món',
  quantity: (json['quantity'] as num).toInt(),
  reportType: (json['reportType'] as String?) ?? 'EXPIRED',
  status: (json['status'] as String?) ?? 'PENDING',
  reason: json['reason'] as String?,
  aiAnalysis: json['aiAnalysis'] as String?,
  createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'] as String) : DateTime.now(),
  processedAt: json['processedAt'] == null
      ? null
      : DateTime.parse(json['processedAt'] as String),
);

Map<String, dynamic> _$DamagedExpiredRecordModelToJson(
  DamagedExpiredRecordModel instance,
) => <String, dynamic>{
  'recordId': instance.recordId,
  'importDetailId': instance.importDetailId,
  'productId': instance.productId,
  'productName': instance.productName,
  'unitName': instance.unitName,
  'quantity': instance.quantity,
  'reportType': instance.reportType,
  'status': instance.status,
  'reason': instance.reason,
  'aiAnalysis': instance.aiAnalysis,
  'createdAt': instance.createdAt.toIso8601String(),
  'processedAt': instance.processedAt?.toIso8601String(),
};
