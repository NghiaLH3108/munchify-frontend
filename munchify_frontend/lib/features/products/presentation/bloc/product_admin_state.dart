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
  final String? successMessage;
  final String? errorMessage;
  final int? stamp;

  const ProductAdminLoaded({
    required this.products,
    required this.totalSkus,
    required this.activeCount,
    required this.lowStockCount,
    this.successMessage,
    this.errorMessage,
    this.stamp,
  });

  @override
  List<Object?> get props => [
        products,
        totalSkus,
        activeCount,
        lowStockCount,
        successMessage,
        errorMessage,
        stamp,
      ];
}

class ProductAdminError extends ProductAdminState {
  final String message;

  const ProductAdminError(this.message);

  @override
  List<Object?> get props => [message];
}
