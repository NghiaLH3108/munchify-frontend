import 'package:equatable/equatable.dart';

/// One component line inside a combo (e.g. "2 × Trà sữa").
class ComboComponentEntity extends Equatable {
  final int componentProductId;
  final String componentProductName;
  final int quantity;
  final double unitPrice;
  final String unitName;
  final int componentStockQuantity;

  const ComboComponentEntity({
    required this.componentProductId,
    required this.componentProductName,
    required this.quantity,
    required this.unitPrice,
    required this.unitName,
    required this.componentStockQuantity,
  });

  double get totalPrice => unitPrice * quantity;

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

class ComboEntity extends Equatable {
  final int id;
  final String code;
  final String name;
  final String? description;
  final double price;
  final double basePrice;
  final int categoryId;
  final String categoryName;
  final int unitId;
  final String unitName;
  final String? imageUrl;
  final bool isActive;
  final List<ComboComponentEntity> items;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ComboEntity({
    required this.id,
    required this.code,
    required this.name,
    this.description,
    required this.price,
    this.basePrice = 0,
    required this.categoryId,
    required this.categoryName,
    required this.unitId,
    required this.unitName,
    this.imageUrl,
    required this.isActive,
    this.items = const [],
    this.createdAt,
    this.updatedAt,
  });

  /// Total price if every component were bought separately.
  double get retailTotal =>
      items.fold(0.0, (sum, item) => sum + item.totalPrice);

  /// Customer saving = retail total - combo price (never negative).
  double get savingAmount =>
      (retailTotal - price).clamp(0.0, double.infinity).toDouble();

  @override
  List<Object?> get props => [
        id,
        code,
        name,
        description,
        price,
        basePrice,
        categoryId,
        categoryName,
        unitId,
        unitName,
        imageUrl,
        isActive,
        items,
        createdAt,
        updatedAt,
      ];
}

class ComboPageEntity extends Equatable {
  final List<ComboEntity> items;
  final int totalCount;
  final int page;
  final int pageSize;

  const ComboPageEntity({
    required this.items,
    required this.totalCount,
    required this.page,
    required this.pageSize,
  });

  int get totalPages => pageSize > 0 ? (totalCount / pageSize).ceil() : 0;

  @override
  List<Object?> get props => [items, totalCount, page, pageSize];
}
