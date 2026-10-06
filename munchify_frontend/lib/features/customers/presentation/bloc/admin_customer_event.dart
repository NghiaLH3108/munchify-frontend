import 'package:equatable/equatable.dart';

abstract class AdminCustomerEvent extends Equatable {
  const AdminCustomerEvent();

  @override
  List<Object?> get props => [];
}

class LoadAdminCustomers extends AdminCustomerEvent {
  final int pageIndex;
  final int pageSize;
  final String? searchKeyword;

  const LoadAdminCustomers({
    required this.pageIndex,
    required this.pageSize,
    this.searchKeyword,
  });

  @override
  List<Object?> get props => [pageIndex, pageSize, searchKeyword];
}

class LoadCustomerPointHistory extends AdminCustomerEvent {
  final int customerId;
  final int pageIndex;
  final int pageSize;

  const LoadCustomerPointHistory({
    required this.customerId,
    required this.pageIndex,
    required this.pageSize,
  });

  @override
  List<Object?> get props => [customerId, pageIndex, pageSize];
}
