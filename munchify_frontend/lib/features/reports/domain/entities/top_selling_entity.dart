import 'package:equatable/equatable.dart';

class TopSellingEntity extends Equatable {
  final int productId;
  final String productName;
  final bool isCombo;
  final int totalQuantity;
  final double totalRevenue;

  const TopSellingEntity({
    required this.productId,
    required this.productName,
    required this.isCombo,
    required this.totalQuantity,
    required this.totalRevenue,
  });

  @override
  List<Object?> get props =>
      [productId, productName, isCombo, totalQuantity, totalRevenue];
}
