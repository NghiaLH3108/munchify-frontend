import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_promotions_usecase.dart';
import '../../domain/usecases/toggle_promotion_status_usecase.dart';
import 'promotion_admin_event.dart';
import 'promotion_admin_state.dart';

class PromotionAdminBloc extends Bloc<PromotionAdminEvent, PromotionAdminState> {
  final GetPromotionsUseCase getPromotionsUseCase;
  final TogglePromotionStatusUseCase togglePromotionStatusUseCase;

  PromotionAdminBloc({
    required this.getPromotionsUseCase,
    required this.togglePromotionStatusUseCase,
  }) : super(PromotionAdminInitial()) {
    on<LoadPromotions>(_onLoadPromotions);
    on<TogglePromotionStatus>(_onTogglePromotionStatus);
  }

  Future<void> _onLoadPromotions(
      LoadPromotions event, Emitter<PromotionAdminState> emit) async {
    emit(PromotionAdminLoading());
    final result = await getPromotionsUseCase(
        event.pageIndex, event.pageSize, event.searchKeyword);

    result.fold(
      (failure) => emit(PromotionAdminError(failure.message)),
      (data) => emit(PromotionsLoaded(
        promotionsData: data,
        searchKeyword: event.searchKeyword,
        pageIndex: event.pageIndex,
      )),
    );
  }

  Future<void> _onTogglePromotionStatus(
      TogglePromotionStatus event, Emitter<PromotionAdminState> emit) async {
    // We could emit a loading state or just keep the current list and do a background update.
    // For simplicity, let's do a full reload after toggle.
    final currentState = state;
    if (currentState is PromotionsLoaded) {
      emit(PromotionAdminLoading());
    }

    final result = await togglePromotionStatusUseCase(event.id);
    result.fold(
      (failure) => emit(PromotionAdminError(failure.message)),
      (_) => add(LoadPromotions(
        pageIndex: event.pageIndex,
        pageSize: event.pageSize,
        searchKeyword: event.searchKeyword,
      )),
    );
  }
}
