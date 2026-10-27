import 'package:equatable/equatable.dart';

import '../../data/models/product_request_model.dart';

abstract class ProductFormEvent extends Equatable {
  const ProductFormEvent();

  @override
  List<Object?> get props => [];
}

class SubmitProductFormEvent extends ProductFormEvent {
  final String? productId; // If null, it's a create. If not, it's an update.
  final ProductRequestModel request;

  const SubmitProductFormEvent({this.productId, required this.request});

  @override
  List<Object?> get props => [productId, request];
}
