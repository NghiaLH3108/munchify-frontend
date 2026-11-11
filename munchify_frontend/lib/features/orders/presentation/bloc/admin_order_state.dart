import 'package:equatable/equatable.dart';
import '../../data/models/admin_order_filter_params.dart';
import '../../domain/entities/admin_order_detail_entity.dart';
import '../../domain/entities/paged_orders_result.dart';

abstract class AdminOrderState extends Equatable {
  const AdminOrderState();

  @override
  List<Object?> get props => [];
}

class AdminOrderInitial extends AdminOrderState {}

class AdminOrderLoading extends AdminOrderState {}

class AdminOrderLoaded extends AdminOrderState {
  final PagedOrdersResult pagedOrders;
  final AdminOrderFilterParams filterParams;
  final AdminOrderDetailEntity? selectedOrderDetail;
  final bool isLoadingDetail;

  const AdminOrderLoaded({
    required this.pagedOrders,
    required this.filterParams,
    this.selectedOrderDetail,
    this.isLoadingDetail = false,
  });

  AdminOrderLoaded copyWith({
    PagedOrdersResult? pagedOrders,
    AdminOrderFilterParams? filterParams,
    AdminOrderDetailEntity? selectedOrderDetail,
    bool? isLoadingDetail,
    bool clearSelected = false,
  }) {
    return AdminOrderLoaded(
      pagedOrders: pagedOrders ?? this.pagedOrders,
      filterParams: filterParams ?? this.filterParams,
      selectedOrderDetail: clearSelected ? null : (selectedOrderDetail ?? this.selectedOrderDetail),
      isLoadingDetail: isLoadingDetail ?? this.isLoadingDetail,
    );
  }

  @override
  List<Object?> get props => [
        pagedOrders,
        filterParams,
        selectedOrderDetail,
        isLoadingDetail,
      ];
}

class AdminOrderError extends AdminOrderState {
  final String message;

  const AdminOrderError(this.message);

  @override
  List<Object?> get props => [message];
}
