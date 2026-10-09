import 'package:equatable/equatable.dart';
import '../../domain/entities/product_entity.dart';

abstract class ProductFormState extends Equatable {
  const ProductFormState();
  
  @override
  List<Object?> get props => [];
}

class ProductFormInitial extends ProductFormState {}

class ProductFormSubmitting extends ProductFormState {}

class ProductFormSuccess extends ProductFormState {
  final ProductEntity product;
  const ProductFormSuccess(this.product);

  @override
  List<Object?> get props => [product];
}

class ProductFormError extends ProductFormState {
  final String message;
  const ProductFormError(this.message);

  @override
  List<Object?> get props => [message];
}
