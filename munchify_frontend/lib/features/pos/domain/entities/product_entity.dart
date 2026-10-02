import 'package:equatable/equatable.dart';

class ProductEntity extends Equatable {
  final int id;
  final String code;
  final String name;
  final double price;
  final int stockQuantity;
  final int categoryId;
  final String unitName;
  final String? imageUrl;
  final bool isCombo;

  const ProductEntity({
    required this.id,
    required this.code,
    required this.name,
    required this.price,
    required this.stockQuantity,
    required this.categoryId,
    required this.unitName,
    this.imageUrl,
    required this.isCombo,
  });

  @override
  List<Object?> get props => [
        id,
        code,
        name,
        price,
        stockQuantity,
        categoryId,
        unitName,
        imageUrl,
        isCombo,
      ];
}
