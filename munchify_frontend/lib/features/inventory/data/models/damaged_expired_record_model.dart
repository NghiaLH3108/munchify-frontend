import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/damaged_expired_record_entity.dart';

part 'damaged_expired_record_model.g.dart';

@JsonSerializable()
class DamagedExpiredRecordModel extends DamagedExpiredRecordEntity {
  @override
  final int recordId;
  @override
  final int importDetailId;
  @override
  final int productId;
  @override
  final String productName;
  @override
  final String unitName;
  @override
  final int quantity;
  @override
  final String status;
  @override
  final String? aiAnalysis;
  @override
  final DateTime createdAt;
  @override
  final DateTime? processedAt;

  const DamagedExpiredRecordModel({
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
  }) : super(
          recordId: recordId,
          importDetailId: importDetailId,
          productId: productId,
          productName: productName,
          unitName: unitName,
          quantity: quantity,
          status: status,
          aiAnalysis: aiAnalysis,
          createdAt: createdAt,
          processedAt: processedAt,
        );

  factory DamagedExpiredRecordModel.fromJson(Map<String, dynamic> json) =>
      _$DamagedExpiredRecordModelFromJson(json);

  Map<String, dynamic> toJson() => _$DamagedExpiredRecordModelToJson(this);
}
