import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/add_product_usecase.dart';
import '../../domain/usecases/update_product_usecase.dart';
import 'product_form_event.dart';
import 'product_form_state.dart';

class ProductFormBloc extends Bloc<ProductFormEvent, ProductFormState> {
  final AddProductUseCase addProductUseCase;
  final UpdateProductUseCase updateProductUseCase;

  ProductFormBloc({
    required this.addProductUseCase,
    required this.updateProductUseCase,
  }) : super(ProductFormInitial()) {
    on<SubmitProductFormEvent>(_onSubmitProductForm);
  }

  Future<void> _onSubmitProductForm(
    SubmitProductFormEvent event,
    Emitter<ProductFormState> emit,
  ) async {
    emit(ProductFormSubmitting());

    if (event.productId == null) {
      final result = await addProductUseCase(event.request);
      result.fold(
        (failure) => emit(ProductFormError(failure.message)),
        (product) => emit(ProductFormSuccess(product)),
      );
    } else {
      final result = await updateProductUseCase(event.productId!, event.request);
      result.fold(
        (failure) => emit(ProductFormError(failure.message)),
        (product) => emit(ProductFormSuccess(product)),
      );
    }
  }
}
