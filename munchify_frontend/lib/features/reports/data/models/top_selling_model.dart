import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/top_selling_entity.dart';

part 'top_selling_model.g.dart';

@JsonSerializable(createToJson: false)
class TopSellingModel {
  @JsonKey(name: 'productId', defaultValue: 0)
  final int productId;
  @JsonKey(name: 'productName', defaultValue: '')
  final String productName;
  @JsonKey(name: 'isCombo', defaultValue: false)
  final bool isCombo;
  @JsonKey(name: 'totalQuantity', defaultValue: 0)
  final int totalQuantity;
  @JsonKey(name: 'totalRevenue', defaultValue: 0)
  final num totalRevenue;

  const TopSellingModel({
    required this.productId,
    required this.productName,
    required this.isCombo,
    required this.totalQuantity,
    required this.totalRevenue,
  });

  factory TopSellingModel.fromJson(Map<String, dynamic> json) =>
      _$TopSellingModelFromJson(json);

  TopSellingEntity toEntity() => TopSellingEntity(
        productId: productId,
        productName: productName,
        isCombo: isCombo,
        totalQuantity: totalQuantity,
        totalRevenue: totalRevenue.toDouble(),
      );
}
