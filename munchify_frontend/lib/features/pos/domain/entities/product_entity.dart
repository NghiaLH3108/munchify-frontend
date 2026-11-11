import 'package:equatable/equatable.dart';
import 'combo_item_entity.dart';

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
  final List<ComboItemEntity> comboItems;

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
    this.comboItems = const [],
  });

  /// Tổng giá trị gốc nếu mua lẻ từng component
  double get componentsTotalPrice =>
      comboItems.fold(0.0, (sum, item) => sum + item.totalPrice);

  /// Số tiền tiết kiệm khi mua combo = tổng lẻ - giá combo
  double get savingAmount =>
      isCombo ? (componentsTotalPrice - price).clamp(0.0, double.infinity) : 0.0;

  /// Combo có thể thêm vào giỏ nếu TẤT CẢ components còn đủ hàng
  bool get isComboAvailable =>
      isCombo ? comboItems.every((item) => item.hasEnoughStock) : stockQuantity > 0;

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
        comboItems,
      ];
}
