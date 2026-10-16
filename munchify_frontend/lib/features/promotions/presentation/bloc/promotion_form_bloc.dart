import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/create_promotion_usecase.dart';
import '../../domain/usecases/update_promotion_usecase.dart';
import '../../../products/domain/usecases/get_products_usecase.dart';
import 'promotion_form_event.dart';
import 'promotion_form_state.dart';

class PromotionFormBloc extends Bloc<PromotionFormEvent, PromotionFormState> {
  final CreatePromotionUseCase createPromotionUseCase;
  final UpdatePromotionUseCase updatePromotionUseCase;
  final GetProductsUseCase getProductsUseCase;

  PromotionFormBloc({
    required this.createPromotionUseCase,
    required this.updatePromotionUseCase,
    required this.getProductsUseCase,
  }) : super(PromotionFormInitial()) {
    on<LoadPromotionProducts>(_onLoadPromotionProducts);
    on<SubmitPromotionForm>(_onSubmitPromotionForm);
    on<ValidatePromotionForm>(_onValidatePromotionForm);
  }

  Future<void> _onLoadPromotionProducts(
    LoadPromotionProducts event,
    Emitter<PromotionFormState> emit,
  ) async {
    emit(PromotionFormProductsLoading());
    final result = await getProductsUseCase();
    result.fold(
      (failure) => emit(PromotionFormError(failure.message)),
      (products) => emit(PromotionFormProductsLoaded(products)),
    );
  }

  void _onValidatePromotionForm(
      ValidatePromotionForm event, Emitter<PromotionFormState> emit) {
    if (event.startDate != null) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      if (event.startDate!.isBefore(today)) {
        emit(const PromotionFormValidationFailed('Ngày bắt đầu không được trong quá khứ.'));
        return;
      }
    }
    if (event.startDate != null && event.endDate != null) {
      if (!event.endDate!.isAfter(event.startDate!)) {
        emit(const PromotionFormValidationFailed('Ngày kết thúc phải sau ngày bắt đầu.'));
        return;
      }
    }
    emit(PromotionFormInitial());
  }

  Future<void> _onSubmitPromotionForm(
      SubmitPromotionForm event, Emitter<PromotionFormState> emit) async {
    emit(PromotionFormLoading());
    
    // Check validation first if possible (simplified here)
    if (event.data['startDate'] != null && event.data['endDate'] != null) {
      final startDate = DateTime.parse(event.data['startDate']);
      final endDate = DateTime.parse(event.data['endDate']);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      if (startDate.isBefore(today)) {
         emit(const PromotionFormError('Ngày bắt đầu không được trong quá khứ.'));
         return;
      }
      if (!endDate.isAfter(startDate)) {
         emit(const PromotionFormError('Ngày kết thúc phải sau ngày bắt đầu.'));
         return;
      }
    }

    if (event.id == null) {
      final result = await createPromotionUseCase(event.data);
      result.fold(
        (failure) => emit(PromotionFormError(failure.message)),
        (data) => emit(PromotionFormSuccess()),
      );
    } else {
      final result = await updatePromotionUseCase(event.id!, event.data);
      result.fold(
        (failure) => emit(PromotionFormError(failure.message)),
        (data) => emit(PromotionFormSuccess()),
      );
    }
  }
}
