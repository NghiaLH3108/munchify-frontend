import 'package:equatable/equatable.dart';

abstract class CustomerEvent extends Equatable {
  const CustomerEvent();

  @override
  List<Object?> get props => [];
}

class SearchCustomerByPhoneEvent extends CustomerEvent {
  final String phone;

  const SearchCustomerByPhoneEvent(this.phone);

  @override
  List<Object?> get props => [phone];
}

class SuggestCustomersByPhoneEvent extends CustomerEvent {
  final String query;

  const SuggestCustomersByPhoneEvent(this.query);

  @override
  List<Object?> get props => [query];
}

class CreateCustomerEvent extends CustomerEvent {
  final String customerName;
  final String phone;

  const CreateCustomerEvent({
    required this.customerName,
    required this.phone,
  });

  @override
  List<Object?> get props => [customerName, phone];
}

class SelectCustomerEvent extends CustomerEvent {
  final dynamic customer;

  const SelectCustomerEvent(this.customer);

  @override
  List<Object?> get props => [customer];
}

class ClearSelectedCustomerEvent extends CustomerEvent {
  const ClearSelectedCustomerEvent();
}

class ToggleRedeemPointsEvent extends CustomerEvent {
  final bool isRedeeming;

  const ToggleRedeemPointsEvent(this.isRedeeming);

  @override
  List<Object?> get props => [isRedeeming];
}

class UpdateRedeemPointsEvent extends CustomerEvent {
  final int pointsToRedeem;

  const UpdateRedeemPointsEvent(this.pointsToRedeem);

  @override
  List<Object?> get props => [pointsToRedeem];
}
