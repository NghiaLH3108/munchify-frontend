import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_promotions_usecase.dart';
import '../../domain/usecases/toggle_promotion_status_usecase.dart';
import 'promotion_admin_event.dart';
import 'promotion_admin_state.dart';

class PromotionAdminBloc extends Bloc<PromotionAdminEvent, PromotionAdminState> {
  final GetPromotionsUseCase getPromotionsUseCase;
  final TogglePromotionStatusUseCase togglePromotionStatusUseCase;

  PromotionsLoaded? _lastLoadedState;

  PromotionAdminBloc({
    required this.getPromotionsUseCase,
    required this.togglePromotionStatusUseCase,
  }) : super(PromotionAdminInitial()) {
    on<LoadPromotions>(_onLoadPromotions);
    on<TogglePromotionStatus>(_onTogglePromotionStatus);
  }

  Future<void> _onLoadPromotions(
      LoadPromotions event, Emitter<PromotionAdminState> emit) async {
    if (_lastLoadedState != null) {
      emit(_lastLoadedState!.copyWith(
        isRefreshing: true,
        searchKeyword: event.searchKeyword,
        pageIndex: event.pageIndex,
      ));
    } else {
      emit(PromotionAdminLoading());
    }

    final result = await getPromotionsUseCase(
        event.pageIndex, event.pageSize, event.searchKeyword);

    result.fold(
      (failure) {
        emit(PromotionAdminError(failure.message));
        if (_lastLoadedState != null) {
          emit(_lastLoadedState!.copyWith(isRefreshing: false));
        }
      },
      (data) {
        final isUnfiltered = (event.searchKeyword == null ||
                event.searchKeyword!.trim().isEmpty) &&
            event.pageIndex == 1;
        final kpiItems = isUnfiltered
            ? data.items
            : (_lastLoadedState?.kpiPromotions ?? data.items);
        final kpiTotal = isUnfiltered
            ? data.totalCount
            : (_lastLoadedState?.kpiTotalCount ?? data.totalCount);

        final nextState = PromotionsLoaded(
          promotionsData: data,
          kpiPromotions: kpiItems,
          kpiTotalCount: kpiTotal,
          searchKeyword: event.searchKeyword,
          pageIndex: event.pageIndex,
          isRefreshing: false,
        );
        _lastLoadedState = nextState;
        emit(nextState);
      },
    );
  }

  Future<void> _onTogglePromotionStatus(
      TogglePromotionStatus event, Emitter<PromotionAdminState> emit) async {
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
