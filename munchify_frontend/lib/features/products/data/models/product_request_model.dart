class ProductRequestModel {
  final String sku;
  final String name;
  final String? imageUrl;
  final String categoryId;
  final String unitId;
  final double price;
  final int minStockLevel;
  final String? description;
  final bool showOnPos;
  final bool autoPrintKitchen;
  final bool isActive;

  ProductRequestModel({
    required this.sku,
    required this.name,
    this.imageUrl,
    required this.categoryId,
    required this.unitId,
    required this.price,
    required this.minStockLevel,
    this.description,
    this.showOnPos = true,
    this.autoPrintKitchen = true,
    this.isActive = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'productName': name,
      'categoryId': int.tryParse(categoryId) ?? 1,
      'unitId': int.tryParse(unitId) ?? 1,
      'productCode': sku,
      'description': description ?? '',
      'price': price,
      'minStockLevel': minStockLevel,
      'imageUrl': imageUrl,
      'isCombo': false,
      'isActive': isActive,
      'comboItems': [],
    };
  }
}
