import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/combo_form_options_entity.dart';

part 'combo_option_models.g.dart';

@JsonSerializable(createToJson: false)
class ComponentProductModel {
  @JsonKey(name: 'productId')
  final int id;
  @JsonKey(name: 'productCode', defaultValue: '')
  final String code;
  @JsonKey(name: 'productName', defaultValue: '')
  final String name;
  @JsonKey(name: 'price', defaultValue: 0)
  final num price;
  @JsonKey(name: 'stockQuantity', defaultValue: 0)
  final int stockQuantity;
  @JsonKey(name: 'unitName', defaultValue: '')
  final String unitName;

  const ComponentProductModel({
    required this.id,
    required this.code,
    required this.name,
    required this.price,
    required this.stockQuantity,
    required this.unitName,
  });

  factory ComponentProductModel.fromJson(Map<String, dynamic> json) =>
      _$ComponentProductModelFromJson(json);

  ComponentProductEntity toEntity() => ComponentProductEntity(
        id: id,
        code: code,
        name: name,
        price: price.toDouble(),
        stockQuantity: stockQuantity,
        unitName: unitName,
      );
}
