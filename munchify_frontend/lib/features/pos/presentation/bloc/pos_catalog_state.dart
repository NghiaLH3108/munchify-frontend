import 'package:equatable/equatable.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/entities/product_entity.dart';

abstract class PosCatalogState extends Equatable {
  const PosCatalogState();
  
  @override
  List<Object?> get props => [];
}

class PosCatalogInitial extends PosCatalogState {}

class PosCatalogLoading extends PosCatalogState {}

class PosCatalogLoaded extends PosCatalogState {
  final List<CategoryEntity> categories;
  final List<ProductEntity> products;   // Sản phẩm đơn (isCombo=false)
  final List<ProductEntity> combos;     // Combo kèm comboItems (isCombo=true)
  final int? selectedCategoryId;
  final String? searchQuery;
  final String? selectedUnitName;

  const PosCatalogLoaded({
    required this.categories,
    required this.products,
    this.combos = const [],
    this.selectedCategoryId,
    this.searchQuery,
    this.selectedUnitName,
  });

  List<ProductEntity> get displayedProducts {
    if (selectedUnitName == null) return products;
    return products.where((p) => p.unitName == selectedUnitName).toList();
  }

  PosCatalogLoaded copyWith({
    List<CategoryEntity>? categories,
    List<ProductEntity>? products,
    List<ProductEntity>? combos,
    int? selectedCategoryId,
    String? searchQuery,
    String? selectedUnitName,
    bool clearUnitFilter = false,
    bool clearCategoryFilter = false,
  }) {
    return PosCatalogLoaded(
      categories: categories ?? this.categories,
      products: products ?? this.products,
      combos: combos ?? this.combos,
      selectedCategoryId: clearCategoryFilter ? null : (selectedCategoryId ?? this.selectedCategoryId),
      searchQuery: searchQuery ?? this.searchQuery,
      selectedUnitName: clearUnitFilter ? null : (selectedUnitName ?? this.selectedUnitName),
    );
  }

  @override
  List<Object?> get props => [categories, products, combos, selectedCategoryId, searchQuery, selectedUnitName];
}

class PosCatalogError extends PosCatalogState {
  final String message;

  const PosCatalogError({required this.message});

  @override
  List<Object?> get props => [message];
}
