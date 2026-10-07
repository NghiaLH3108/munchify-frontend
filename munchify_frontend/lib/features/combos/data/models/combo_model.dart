import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/combo_entity.dart';

part 'combo_model.g.dart';

@JsonSerializable(createToJson: false)
class ComboItemModel {
  @JsonKey(name: 'componentProductId')
  final int componentProductId;
  @JsonKey(name: 'componentProductName', defaultValue: '')
  final String componentProductName;
  @JsonKey(name: 'quantity', defaultValue: 0)
  final int quantity;
  @JsonKey(name: 'unitPrice', defaultValue: 0)
  final num unitPrice;
  @JsonKey(name: 'unitName', defaultValue: '')
  final String unitName;
  @JsonKey(name: 'componentStockQuantity', defaultValue: 0)
  final int componentStockQuantity;

  const ComboItemModel({
    required this.componentProductId,
    required this.componentProductName,
    required this.quantity,
    required this.unitPrice,
    required this.unitName,
    required this.componentStockQuantity,
  });

  factory ComboItemModel.fromJson(Map<String, dynamic> json) =>
      _$ComboItemModelFromJson(json);

  ComboComponentEntity toEntity() => ComboComponentEntity(
        componentProductId: componentProductId,
        componentProductName: componentProductName,
        quantity: quantity,
        unitPrice: unitPrice.toDouble(),
        unitName: unitName,
        componentStockQuantity: componentStockQuantity,
      );
}

@JsonSerializable(createToJson: false)
class ComboModel {
  @JsonKey(name: 'productId')
  final int id;
  @JsonKey(name: 'productCode', defaultValue: '')
  final String code;
  @JsonKey(name: 'productName', defaultValue: '')
  final String name;
  @JsonKey(name: 'description')
  final String? description;
  @JsonKey(name: 'price', defaultValue: 0)
  final num price;
  @JsonKey(name: 'basePrice', defaultValue: 0)
  final num basePrice;
  @JsonKey(name: 'categoryId', defaultValue: 0)
  final int categoryId;
  @JsonKey(name: 'categoryName', defaultValue: '')
  final String categoryName;
  @JsonKey(name: 'unitId', defaultValue: 0)
  final int unitId;
  @JsonKey(name: 'unitName', defaultValue: '')
  final String unitName;
  @JsonKey(name: 'imageUrl')
  final String? imageUrl;
  @JsonKey(name: 'isActive', defaultValue: true)
  final bool isActive;
  @JsonKey(name: 'comboItems', defaultValue: <ComboItemModel>[])
  final List<ComboItemModel> comboItems;
  @JsonKey(name: 'createdAt')
  final DateTime? createdAt;
  @JsonKey(name: 'updatedAt')
  final DateTime? updatedAt;

  const ComboModel({
    required this.id,
    required this.code,
    required this.name,
    this.description,
    required this.price,
    required this.basePrice,
    required this.categoryId,
    required this.categoryName,
    required this.unitId,
    required this.unitName,
    this.imageUrl,
    required this.isActive,
    required this.comboItems,
    this.createdAt,
    this.updatedAt,
  });

  factory ComboModel.fromJson(Map<String, dynamic> json) =>
      _$ComboModelFromJson(json);

  ComboEntity toEntity() => ComboEntity(
        id: id,
        code: code,
        name: name,
        description: description,
        price: price.toDouble(),
        basePrice: basePrice.toDouble(),
        categoryId: categoryId,
        categoryName: categoryName,
        unitId: unitId,
        unitName: unitName,
        imageUrl: imageUrl,
        isActive: isActive,
        items: comboItems.map((e) => e.toEntity()).toList(),
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
}
