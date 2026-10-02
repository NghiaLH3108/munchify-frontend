import '../../domain/entities/product_entity.dart';

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
        );

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] ?? json['productId'] ?? 0,
      code: json['code'] ?? json['productCode'] ?? '',
      name: json['name'] ?? json['productName'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      stockQuantity: json['stockQuantity'] ?? 0,
      categoryId: json['categoryId'] ?? 0,
      unitName: json['unitName'] ?? '',
      imageUrl: json['imageUrl'],
      isCombo: json['isCombo'] ?? false,
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
