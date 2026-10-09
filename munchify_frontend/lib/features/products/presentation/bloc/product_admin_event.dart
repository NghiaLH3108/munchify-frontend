import 'package:equatable/equatable.dart';

abstract class ProductAdminEvent extends Equatable {
  const ProductAdminEvent();

  @override
  List<Object?> get props => [];
}

class LoadProductsEvent extends ProductAdminEvent {
  final String? search;
  final String? categoryId;
  final bool? isActive;
  final bool? lowStockWarning;

  const LoadProductsEvent({
    this.search,
    this.categoryId,
    this.isActive,
    this.lowStockWarning,
  });

  @override
  List<Object?> get props => [search, categoryId, isActive, lowStockWarning];
}

class ToggleProductStatusEvent extends ProductAdminEvent {
  final String productId;
  final bool isActive;

  const ToggleProductStatusEvent(this.productId, this.isActive);

  @override
  List<Object?> get props => [productId, isActive];
}
