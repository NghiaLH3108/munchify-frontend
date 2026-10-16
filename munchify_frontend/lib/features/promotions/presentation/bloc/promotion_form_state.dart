import 'package:equatable/equatable.dart';
import '../../../products/domain/entities/product_entity.dart';

abstract class PromotionFormState extends Equatable {
  const PromotionFormState();

  @override
  List<Object?> get props => [];
}

class PromotionFormInitial extends PromotionFormState {}

class PromotionFormProductsLoading extends PromotionFormState {}

class PromotionFormProductsLoaded extends PromotionFormState {
  final List<ProductEntity> products;

  const PromotionFormProductsLoaded(this.products);

  @override
  List<Object?> get props => [products];
}

class PromotionFormLoading extends PromotionFormState {}

class PromotionFormSuccess extends PromotionFormState {}

class PromotionFormError extends PromotionFormState {
  final String message;

  const PromotionFormError(this.message);

  @override
  List<Object?> get props => [message];
}

class PromotionFormValidationFailed extends PromotionFormState {
  final String message;

  const PromotionFormValidationFailed(this.message);

  @override
  List<Object?> get props => [message];
}
