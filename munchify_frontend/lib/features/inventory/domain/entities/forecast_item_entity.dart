import 'package:equatable/equatable.dart';

class ForecastItemEntity extends Equatable {
  final int productId;
  final String productName;
  final String unitName;
  final double stockQuantity;
  final double minStockLevel;
  final double avgDailyUsage;
  final double daysRemaining;
  final String riskLevel;
  final double suggestedImportQty;
  final int? defaultSupplierId;
  final String? defaultSupplierName;

  const ForecastItemEntity({
    required this.productId,
    required this.productName,
    required this.unitName,
    required this.stockQuantity,
    required this.minStockLevel,
    required this.avgDailyUsage,
    required this.daysRemaining,
    required this.riskLevel,
    required this.suggestedImportQty,
    this.defaultSupplierId,
    this.defaultSupplierName,
  });

  @override
  List<Object?> get props => [
        productId,
        productName,
        unitName,
        stockQuantity,
        minStockLevel,
        avgDailyUsage,
        daysRemaining,
        riskLevel,
        suggestedImportQty,
        defaultSupplierId,
        defaultSupplierName,
      ];
}
