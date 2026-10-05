import '../../domain/entities/forecast_item_entity.dart';

class ForecastItemModel extends ForecastItemEntity {
  const ForecastItemModel({
    required int productId,
    required String productName,
    required String unitName,
    required double stockQuantity,
    required double minStockLevel,
    required double avgDailyUsage,
    required double daysRemaining,
    required String riskLevel,
    required double suggestedImportQty,
    int? defaultSupplierId,
    String? defaultSupplierName,
  }) : super(
          productId: productId,
          productName: productName,
          unitName: unitName,
          stockQuantity: stockQuantity,
          minStockLevel: minStockLevel,
          avgDailyUsage: avgDailyUsage,
          daysRemaining: daysRemaining,
          riskLevel: riskLevel,
          suggestedImportQty: suggestedImportQty,
          defaultSupplierId: defaultSupplierId,
          defaultSupplierName: defaultSupplierName,
        );

  factory ForecastItemModel.fromJson(Map<String, dynamic> json) {
    return ForecastItemModel(
      productId: json['productId'],
      productName: json['productName'] ?? '',
      unitName: json['unitName'] ?? '',
      stockQuantity: (json['stockQuantity'] as num?)?.toDouble() ?? 0.0,
      minStockLevel: (json['minStockLevel'] as num?)?.toDouble() ?? 0.0,
      avgDailyUsage: (json['avgDailyUsage'] as num?)?.toDouble() ?? 0.0,
      daysRemaining: (json['daysRemaining'] as num?)?.toDouble() ?? 0.0,
      riskLevel: json['riskLevel'] ?? '',
      suggestedImportQty: (json['suggestedImportQty'] as num?)?.toDouble() ?? 0.0,
      defaultSupplierId: json['defaultSupplierId'] as int?,
      defaultSupplierName: json['defaultSupplierName'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'productName': productName,
      'unitName': unitName,
      'stockQuantity': stockQuantity,
      'minStockLevel': minStockLevel,
      'avgDailyUsage': avgDailyUsage,
      'daysRemaining': daysRemaining,
      'riskLevel': riskLevel,
      'suggestedImportQty': suggestedImportQty,
      'defaultSupplierId': defaultSupplierId,
      'defaultSupplierName': defaultSupplierName,
    };
  }
}
