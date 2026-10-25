import 'package:equatable/equatable.dart';
import '../../data/models/admin_order_filter_params.dart';

abstract class AdminOrderEvent extends Equatable {
  const AdminOrderEvent();

  @override
  List<Object?> get props => [];
}

class FetchAdminOrdersEvent extends AdminOrderEvent {
  final AdminOrderFilterParams? filterParams;

  const FetchAdminOrdersEvent({this.filterParams});

  @override
  List<Object?> get props => [filterParams];
}

class ChangeOrderPageEvent extends AdminOrderEvent {
  final int page;

  const ChangeOrderPageEvent(this.page);

  @override
  List<Object?> get props => [page];
}

class FetchAdminOrderDetailEvent extends AdminOrderEvent {
  final int orderId;

  const FetchAdminOrderDetailEvent(this.orderId);

  @override
  List<Object?> get props => [orderId];
}
