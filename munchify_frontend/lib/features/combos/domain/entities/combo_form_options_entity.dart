import 'package:equatable/equatable.dart';

/// Single product that can be picked as a combo component.
class ComponentProductEntity extends Equatable {
  final int id;
  final String code;
  final String name;
  final double price;
  final int stockQuantity;
  final String unitName;

  const ComponentProductEntity({
    required this.id,
    required this.code,
    required this.name,
    required this.price,
    required this.stockQuantity,
    required this.unitName,
  });

  @override
  List<Object?> get props => [id, code, name, price, stockQuantity, unitName];
}

/// Generic id/name pair for dropdowns (category, unit).
class ComboOptionEntity extends Equatable {
  final int id;
  final String name;

  const ComboOptionEntity({required this.id, required this.name});

  @override
  List<Object?> get props => [id, name];
}

/// Data required to render the combo form (dropdowns + component picker).
class ComboFormOptionsEntity extends Equatable {
  final List<ComboOptionEntity> categories;
  final List<ComboOptionEntity> units;
  final List<ComponentProductEntity> products;

  const ComboFormOptionsEntity({
    required this.categories,
    required this.units,
    required this.products,
  });

  @override
  List<Object?> get props => [categories, units, products];
}
