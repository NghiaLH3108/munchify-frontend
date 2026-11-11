import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/admin_order_filter_params.dart';
import '../../domain/usecases/get_admin_order_detail_usecase.dart';
import '../../domain/usecases/get_admin_orders_usecase.dart';
import 'admin_order_event.dart';
import 'admin_order_state.dart';

class AdminOrderBloc extends Bloc<AdminOrderEvent, AdminOrderState> {
  final GetAdminOrdersUseCase getAdminOrdersUseCase;
  final GetAdminOrderDetailUseCase getAdminOrderDetailUseCase;

  AdminOrderFilterParams _currentFilter = const AdminOrderFilterParams();

  AdminOrderBloc({
    required this.getAdminOrdersUseCase,
    required this.getAdminOrderDetailUseCase,
  }) : super(AdminOrderInitial()) {
    on<FetchAdminOrdersEvent>(_onFetchOrders);
    on<ChangeOrderPageEvent>(_onChangePage);
    on<FetchAdminOrderDetailEvent>(_onFetchOrderDetail);
  }

  Future<void> _onFetchOrders(
    FetchAdminOrdersEvent event,
    Emitter<AdminOrderState> emit,
  ) async {
    if (event.filterParams != null) {
      _currentFilter = event.filterParams!;
    }

    emit(AdminOrderLoading());

    final result = await getAdminOrdersUseCase.execute(_currentFilter);

    result.fold(
      (failure) => emit(AdminOrderError(failure.message)),
      (pagedResult) => emit(AdminOrderLoaded(
        pagedOrders: pagedResult,
        filterParams: _currentFilter,
      )),
    );
  }

  Future<void> _onChangePage(
    ChangeOrderPageEvent event,
    Emitter<AdminOrderState> emit,
  ) async {
    _currentFilter = _currentFilter.copyWith(page: event.page);

    if (state is AdminOrderLoaded) {
      final current = state as AdminOrderLoaded;
      emit(current.copyWith(isLoadingDetail: false));
    } else {
      emit(AdminOrderLoading());
    }

    final result = await getAdminOrdersUseCase.execute(_currentFilter);

    result.fold(
      (failure) => emit(AdminOrderError(failure.message)),
      (pagedResult) => emit(AdminOrderLoaded(
        pagedOrders: pagedResult,
        filterParams: _currentFilter,
      )),
    );
  }

  Future<void> _onFetchOrderDetail(
    FetchAdminOrderDetailEvent event,
    Emitter<AdminOrderState> emit,
  ) async {
    if (state is AdminOrderLoaded) {
      final current = state as AdminOrderLoaded;
      emit(current.copyWith(isLoadingDetail: true));

      final result = await getAdminOrderDetailUseCase.execute(event.orderId);

      result.fold(
        (failure) => emit(AdminOrderError(failure.message)),
        (detail) => emit(current.copyWith(
          selectedOrderDetail: detail,
          isLoadingDetail: false,
        )),
      );
    }
  }
}
