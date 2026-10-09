import 'package:equatable/equatable.dart';

class ProductEntity extends Equatable {
  final String id;
  final String sku;
  final String name;
  final String? imageUrl;
  final String categoryId;
  final String? categoryName;
  final String unitId;
  final String? unitName;
  final double price;
  final int stockQuantity;
  final int minStockLevel;
  final bool isActive;
  final String? description;
  final bool showOnPos;
  final bool autoPrintKitchen;

  const ProductEntity({
    required this.id,
    required this.sku,
    required this.name,
    this.imageUrl,
    required this.categoryId,
    this.categoryName,
    required this.unitId,
    this.unitName,
    required this.price,
    required this.stockQuantity,
    required this.minStockLevel,
    required this.isActive,
    this.description,
    required this.showOnPos,
    required this.autoPrintKitchen,
  });

  @override
  List<Object?> get props => [
        id,
        sku,
        name,
        imageUrl,
        categoryId,
        categoryName,
        unitId,
        unitName,
        price,
        stockQuantity,
        minStockLevel,
        isActive,
        description,
        showOnPos,
        autoPrintKitchen,
      ];
}
