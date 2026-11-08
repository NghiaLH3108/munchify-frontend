import '../../../../core/constants/AppConstants.dart';
import '../../domain/entities/product_entity.dart';

class ProductModel extends ProductEntity {
  const ProductModel({
    required super.id,
    required super.sku,
    required super.name,
    super.imageUrl,
    required super.categoryId,
    super.categoryName,
    required super.unitId,
    super.unitName,
    required super.price,
    required super.stockQuantity,
    required super.minStockLevel,
    required super.isActive,
    super.description,
    required super.showOnPos,
    required super.autoPrintKitchen,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      // ID: thử các tên field khác nhau của backend
      id: (json['id'] ?? json['productId'] ?? '').toString(),

      // SKU / Mã sản phẩm
      sku: (json['sku'] ?? json['productCode'] ?? json['code'] ?? '').toString(),

      // Tên sản phẩm
      name: (json['name'] ?? json['productName'] ?? '').toString(),

      // Hình ảnh
      imageUrl: AppConstants.resolveImageUrl(json['imageUrl'] as String?),

      // Danh mục
      categoryId: (json['categoryId'] ?? json['category']?['id'] ?? '').toString(),
      categoryName: (json['categoryName'] ?? json['category']?['categoryName'] ?? json['category']?['name']) as String?,

      // Đơn vị tính
      unitId: (json['unitId'] ?? json['unit']?['id'] ?? '').toString(),
      unitName: (json['unitName'] ?? json['unit']?['unitName'] ?? json['unit']?['name']) as String?,

      // Giá
      price: ((json['price'] ?? json['sellingPrice'] ?? 0) as num).toDouble(),

      // Tồn kho & định mức
      stockQuantity: (json['stockQuantity'] ?? json['currentStock'] ?? 0) as int,
      minStockLevel: (json['minStockLevel'] ?? json['minimumStock'] ?? 0) as int,

      // Trạng thái
      isActive: json['isActive'] ?? true,

      // Mô tả
      description: json['description'] as String?,

      // Hiển thị POS / in bếp
      showOnPos: json['showOnPos'] ?? json['isDisplayedOnPos'] ?? true,
      autoPrintKitchen: json['autoPrintKitchen'] ?? json['isPrintKitchen'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sku': sku,
      'name': name,
      'imageUrl': imageUrl,
      'categoryId': categoryId,
      'unitId': unitId,
      'price': price,
      'stockQuantity': stockQuantity,
      'minStockLevel': minStockLevel,
      'isActive': isActive,
      'description': description,
      'showOnPos': showOnPos,
      'autoPrintKitchen': autoPrintKitchen,
    };
  }
}
