import 'package:equatable/equatable.dart';

/// Thành phần (component) bên trong 1 combo
class ComboItemEntity extends Equatable {
  final int componentProductId;
  final String componentProductName;
  final int quantity;
  final double unitPrice;
  final String unitName;
  final int componentStockQuantity;

  const ComboItemEntity({
    required this.componentProductId,
    required this.componentProductName,
    required this.quantity,
    required this.unitPrice,
    required this.unitName,
    required this.componentStockQuantity,
  });

  /// Tổng giá trị của component này (unitPrice × quantity)
  double get totalPrice => unitPrice * quantity;

  /// Component này có đủ hàng cho combo không
  bool get hasEnoughStock => componentStockQuantity >= quantity;

  @override
  List<Object?> get props => [
        componentProductId,
        componentProductName,
        quantity,
        unitPrice,
        unitName,
        componentStockQuantity,
      ];
}
