import 'package:equatable/equatable.dart';
import '../../domain/entities/product_entity.dart';

abstract class ProductAdminState extends Equatable {
  const ProductAdminState();
  
  @override
  List<Object?> get props => [];
}

class ProductAdminInitial extends ProductAdminState {}

class ProductAdminLoading extends ProductAdminState {}

class ProductAdminLoaded extends ProductAdminState {
  final List<ProductEntity> products;
  final int totalSkus;
  final int activeCount;
  final int lowStockCount;

  const ProductAdminLoaded({
    required this.products,
    required this.totalSkus,
    required this.activeCount,
    required this.lowStockCount,
  });

  @override
  List<Object?> get props => [products, totalSkus, activeCount, lowStockCount];
}

class ProductAdminError extends ProductAdminState {
  final String message;

  const ProductAdminError(this.message);

  @override
  List<Object?> get props => [message];
}
