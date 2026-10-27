import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_customers_usecase.dart';
import '../../domain/usecases/get_customer_point_history_usecase.dart';
import 'admin_customer_event.dart';
import 'admin_customer_state.dart';

class AdminCustomerBloc extends Bloc<AdminCustomerEvent, AdminCustomerState> {
  final GetCustomersUseCase getCustomersUseCase;
  final GetCustomerPointHistoryUseCase getCustomerPointHistoryUseCase;

  AdminCustomersLoaded? _lastCustomersLoaded;

  AdminCustomerBloc({
    required this.getCustomersUseCase,
    required this.getCustomerPointHistoryUseCase,
  }) : super(AdminCustomerInitial()) {
    on<LoadAdminCustomers>(_onLoadAdminCustomers);
    on<LoadCustomerPointHistory>(_onLoadCustomerPointHistory);
  }

  void _onLoadAdminCustomers(
    LoadAdminCustomers event,
    Emitter<AdminCustomerState> emit,
  ) async {
    if (_lastCustomersLoaded != null) {
      emit(_lastCustomersLoaded!.copyWith(
        isRefreshing: true,
        currentSearchKeyword: event.searchKeyword,
      ));
    } else {
      emit(AdminCustomerLoading());
    }

    final result = await getCustomersUseCase(
      pageIndex: event.pageIndex,
      pageSize: event.pageSize,
      searchKeyword: event.searchKeyword,
    );

    result.fold(
      (failure) {
        if (_lastCustomersLoaded != null) {
          emit(_lastCustomersLoaded!.copyWith(isRefreshing: false));
        } else {
          emit(AdminCustomerError(failure.message));
        }
      },
      (data) {
        final isUnfilteredSearch =
            event.searchKeyword == null || event.searchKeyword!.trim().isEmpty;
        final kpiItems = isUnfilteredSearch
            ? data.items
            : (_lastCustomersLoaded?.kpiCustomers ?? data.items);
        final kpiTotal = isUnfilteredSearch
            ? data.totalCount
            : (_lastCustomersLoaded?.kpiTotalCount ?? data.totalCount);

        final nextState = AdminCustomersLoaded(
          customersData: data,
          currentSearchKeyword: event.searchKeyword,
          isRefreshing: false,
          kpiCustomers: kpiItems,
          kpiTotalCount: kpiTotal,
        );
        _lastCustomersLoaded = nextState;
        emit(nextState);
      },
    );
  }

  void _onLoadCustomerPointHistory(
    LoadCustomerPointHistory event,
    Emitter<AdminCustomerState> emit,
  ) async {
    emit(CustomerPointHistoryLoading());
    final result = await getCustomerPointHistoryUseCase(
      customerId: event.customerId,
      pageIndex: event.pageIndex,
      pageSize: event.pageSize,
    );

    result.fold(
      (failure) => emit(AdminCustomerError(failure.message)),
      (data) => emit(CustomerPointHistoryLoaded(
        historyData: data,
        customerId: event.customerId,
      )),
    );
  }
}
