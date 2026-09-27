import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/stock_import_entity.dart';

part 'stock_import_model.g.dart';

@JsonSerializable(explicitToJson: true)
class StockImportModel extends StockImportEntity {
  @override
  final List<ImportDetailModel> details;

  const StockImportModel({
    required super.importId,
    required super.importCode,
    required super.supplierId,
    required super.supplierName,
    required super.userId,
    required super.userName,
    required super.totalAmount,
    required super.status,
    required super.importDate,
    super.notes,
    required this.details,
  }) : super(details: details);

  factory StockImportModel.fromJson(Map<String, dynamic> json) =>
      _$StockImportModelFromJson(json);

  Map<String, dynamic> toJson() => _$StockImportModelToJson(this);
}

@JsonSerializable()
class ImportDetailModel extends ImportDetailEntity {
  const ImportDetailModel({
    required super.productId,
    required super.productName,
    required super.unitName,
    required super.quantity,
    required super.importPrice,
    required super.totalAmount,
  });

  factory ImportDetailModel.fromJson(Map<String, dynamic> json) =>
      _$ImportDetailModelFromJson(json);

  Map<String, dynamic> toJson() => _$ImportDetailModelToJson(this);
}
