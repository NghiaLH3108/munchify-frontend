import 'package:equatable/equatable.dart';
import 'product_entity.dart';

/// Một dòng trong giỏ hàng POS.
/// Được tạo từ [ProductEntity] khi nhân viên nhấn "Thêm".
class CartItemEntity extends Equatable {
  final int productId;
  final String productName;
  final String unitName;
  final double unitPrice;
  final int quantity;
  final bool isCombo;
  final String? imageUrl;

  const CartItemEntity({
    required this.productId,
    required this.productName,
    required this.unitName,
    required this.unitPrice,
    required this.quantity,
    required this.isCombo,
    this.imageUrl,
  });

  double get totalPrice => unitPrice * quantity;

  CartItemEntity copyWith({int? quantity}) {
    return CartItemEntity(
      productId: productId,
      productName: productName,
      unitName: unitName,
      unitPrice: unitPrice,
      quantity: quantity ?? this.quantity,
      isCombo: isCombo,
      imageUrl: imageUrl,
    );
  }

  /// Tạo từ [ProductEntity] với số lượng mặc định = 1.
  factory CartItemEntity.fromProduct(ProductEntity product) {
    return CartItemEntity(
      productId: product.id,
      productName: product.name,
      unitName: product.unitName,
      unitPrice: product.price,
      quantity: 1,
      isCombo: product.isCombo,
      imageUrl: product.imageUrl,
    );
  }

  @override
  List<Object?> get props => [
        productId,
        productName,
        unitName,
        unitPrice,
        quantity,
        isCombo,
      ];
}
