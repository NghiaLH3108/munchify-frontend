import '../../domain/entities/product_entity.dart';
import 'combo_item_model.dart';

class ProductModel extends ProductEntity {
  const ProductModel({
    required int id,
    required String code,
    required String name,
    required double price,
    required int stockQuantity,
    required int categoryId,
    required String unitName,
    String? imageUrl,
    required bool isCombo,
    List<ComboItemModel> comboItems = const [],
  }) : super(
          id: id,
          code: code,
          name: name,
          price: price,
          stockQuantity: stockQuantity,
          categoryId: categoryId,
          unitName: unitName,
          imageUrl: imageUrl,
          isCombo: isCombo,
          comboItems: comboItems,
        );

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final rawComboItems = json['comboItems'] as List<dynamic>? ?? [];
    return ProductModel(
      id: json['id'] ?? json['productId'] ?? 0,
      code: json['code'] ?? json['productCode'] ?? '',
      name: json['name'] ?? json['productName'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      stockQuantity: json['stockQuantity'] ?? 0,
      categoryId: json['categoryId'] ?? 0,
      unitName: (json['unitName'] != null && json['unitName'].toString().isNotEmpty)
          ? json['unitName']
          : ((json['isCombo'] ?? false) ? 'Combo' : 'Phần'),
      imageUrl: json['imageUrl'],
      isCombo: json['isCombo'] ?? false,
      comboItems: rawComboItems
          .map((item) => ComboItemModel.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'name': name,
      'price': price,
      'stockQuantity': stockQuantity,
      'categoryId': categoryId,
      'unitName': unitName,
      'imageUrl': imageUrl,
      'isCombo': isCombo,
    };
  }
}
