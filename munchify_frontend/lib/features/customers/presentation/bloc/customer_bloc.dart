import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/AppConstants.dart';
import '../../domain/entities/customer_entity.dart';
import '../../domain/usecases/search_customer_usecase.dart';
import '../../domain/usecases/create_customer_usecase.dart';
import '../../domain/usecases/get_customers_usecase.dart';
import 'customer_event.dart';
import 'customer_state.dart';

class CustomerBloc extends Bloc<CustomerEvent, CustomerState> {
  final SearchCustomerUseCase searchCustomer;
  final CreateCustomerUseCase createCustomer;
  final GetCustomersUseCase? getCustomers;

  CustomerBloc({
    required this.searchCustomer,
    required this.createCustomer,
    this.getCustomers,
  }) : super(CustomerInitial()) {
    on<SearchCustomerByPhoneEvent>(_onSearchByPhone);
    on<SuggestCustomersByPhoneEvent>(_onSuggestByPhone);
    on<CreateCustomerEvent>(_onCreateCustomer);
    on<SelectCustomerEvent>(_onSelectCustomer);
    on<ClearSelectedCustomerEvent>(_onClearCustomer);
    on<ToggleRedeemPointsEvent>(_onToggleRedeem);
    on<UpdateRedeemPointsEvent>(_onUpdateRedeemPoints);
  }

  Future<void> _onSearchByPhone(
    SearchCustomerByPhoneEvent event,
    Emitter<CustomerState> emit,
  ) async {
    emit(CustomerSearching());
    final result = await searchCustomer(event.phone);
    result.fold(
      (failure) => emit(CustomerNotFound(event.phone)),
      (customer) => emit(CustomerFound(customer)),
    );
  }

  Future<void> _onSuggestByPhone(
    SuggestCustomersByPhoneEvent event,
    Emitter<CustomerState> emit,
  ) async {
    final trimmed = event.query.trim();
    if (trimmed.isEmpty) {
      emit(CustomerInitial());
      return;
    }

    emit(CustomerSearching());

    if (getCustomers != null) {
      final result = await getCustomers!(
        pageIndex: 1,
        pageSize: 10,
        searchKeyword: trimmed,
      );
      result.fold(
        (failure) => emit(CustomerError(failure.message)),
        (pagedResult) {
          if (pagedResult.items.isEmpty) {
            emit(CustomerNotFound(trimmed));
          } else {
            emit(CustomerSuggestionsLoaded(
              customers: pagedResult.items,
              query: trimmed,
            ));
          }
        },
      );
    } else {
      // Fallback nếu không có getCustomers
      final result = await searchCustomer(trimmed);
      result.fold(
        (failure) => emit(CustomerNotFound(trimmed)),
        (customer) => emit(CustomerSuggestionsLoaded(
          customers: [customer],
          query: trimmed,
        )),
      );
    }
  }

  Future<void> _onCreateCustomer(
    CreateCustomerEvent event,
    Emitter<CustomerState> emit,
  ) async {
    emit(CustomerSearching());
    final result = await createCustomer(
      customerName: event.customerName,
      phone: event.phone,
    );
    result.fold(
      (failure) => emit(CustomerError(failure.message)),
      (customer) {
        emit(CustomerCreated(customer));
        emit(CustomerSelected(customer: customer));
      },
    );
  }

  void _onSelectCustomer(
    SelectCustomerEvent event,
    Emitter<CustomerState> emit,
  ) {
    final customer = event.customer as CustomerEntity;
    emit(CustomerSelected(customer: customer));
  }

  void _onClearCustomer(
    ClearSelectedCustomerEvent event,
    Emitter<CustomerState> emit,
  ) {
    emit(CustomerInitial());
  }

  void _onToggleRedeem(
    ToggleRedeemPointsEvent event,
    Emitter<CustomerState> emit,
  ) {
    final current = state;
    if (current is CustomerSelected) {
      if (event.isRedeeming) {
        // Bật quy đổi → mặc định dùng tối đa điểm
        final maxPoints = current.customer.loyaltyPoints;
        final discount = maxPoints * AppConstants.pointsToVndRate;
        emit(current.copyWith(
          isRedeeming: true,
          pointsToRedeem: maxPoints,
          discountFromPoints: discount,
        ));
      } else {
        // Tắt quy đổi → reset về 0
        emit(current.copyWith(
          isRedeeming: false,
          pointsToRedeem: 0,
          discountFromPoints: 0,
        ));
      }
    }
  }

  void _onUpdateRedeemPoints(
    UpdateRedeemPointsEvent event,
    Emitter<CustomerState> emit,
  ) {
    final current = state;
    if (current is CustomerSelected) {
      // Ràng buộc: 0 ≤ pointsToRedeem ≤ customer.loyaltyPoints
      final clampedPoints = event.pointsToRedeem.clamp(
        0,
        current.customer.loyaltyPoints,
      );
      final discount = clampedPoints * AppConstants.pointsToVndRate;
      emit(current.copyWith(
        pointsToRedeem: clampedPoints,
        discountFromPoints: discount,
      ));
    }
  }
}
