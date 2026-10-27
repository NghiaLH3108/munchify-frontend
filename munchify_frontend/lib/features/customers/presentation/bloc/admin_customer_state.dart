import 'package:equatable/equatable.dart';
import '../../../../core/utils/PagedResult.dart';
import '../../domain/entities/customer_entity.dart';
import '../../domain/entities/customer_point_history_entity.dart';

abstract class AdminCustomerState extends Equatable {
  const AdminCustomerState();

  @override
  List<Object?> get props => [];
}

class AdminCustomerInitial extends AdminCustomerState {}

class AdminCustomerLoading extends AdminCustomerState {}

class AdminCustomersLoaded extends AdminCustomerState {
  final PagedResult<CustomerEntity> customersData;
  final String? currentSearchKeyword;
  final bool isRefreshing;
  final List<CustomerEntity>? kpiCustomers;
  final int? kpiTotalCount;

  const AdminCustomersLoaded({
    required this.customersData,
    this.currentSearchKeyword,
    this.isRefreshing = false,
    this.kpiCustomers,
    this.kpiTotalCount,
  });

  AdminCustomersLoaded copyWith({
    PagedResult<CustomerEntity>? customersData,
    String? currentSearchKeyword,
    bool? isRefreshing,
    List<CustomerEntity>? kpiCustomers,
    int? kpiTotalCount,
  }) {
    return AdminCustomersLoaded(
      customersData: customersData ?? this.customersData,
      currentSearchKeyword: currentSearchKeyword ?? this.currentSearchKeyword,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      kpiCustomers: kpiCustomers ?? this.kpiCustomers,
      kpiTotalCount: kpiTotalCount ?? this.kpiTotalCount,
    );
  }

  @override
  List<Object?> get props => [
        customersData,
        currentSearchKeyword,
        isRefreshing,
        kpiCustomers,
        kpiTotalCount,
      ];
}

class CustomerPointHistoryLoading extends AdminCustomerState {}

class CustomerPointHistoryLoaded extends AdminCustomerState {
  final PagedResult<CustomerPointHistoryEntity> historyData;
  final int customerId;

  const CustomerPointHistoryLoaded({
    required this.historyData,
    required this.customerId,
  });

  @override
  List<Object?> get props => [historyData, customerId];
}

class AdminCustomerError extends AdminCustomerState {
  final String message;

  const AdminCustomerError(this.message);

  @override
  List<Object?> get props => [message];
}
