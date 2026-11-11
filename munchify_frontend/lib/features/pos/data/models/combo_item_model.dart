import '../../domain/entities/combo_item_entity.dart';

class ComboItemModel extends ComboItemEntity {
  const ComboItemModel({
    required int componentProductId,
    required String componentProductName,
    required int quantity,
    required double unitPrice,
    required String unitName,
    required int componentStockQuantity,
  }) : super(
          componentProductId: componentProductId,
          componentProductName: componentProductName,
          quantity: quantity,
          unitPrice: unitPrice,
          unitName: unitName,
          componentStockQuantity: componentStockQuantity,
        );

  factory ComboItemModel.fromJson(Map<String, dynamic> json) {
    return ComboItemModel(
      componentProductId: json['componentProductId'] ?? 0,
      componentProductName: json['componentProductName'] ?? '',
      quantity: json['quantity'] ?? 0,
      unitPrice: (json['unitPrice'] ?? 0).toDouble(),
      unitName: json['unitName'] ?? '',
      componentStockQuantity: json['componentStockQuantity'] ?? 0,
    );
  }
}
