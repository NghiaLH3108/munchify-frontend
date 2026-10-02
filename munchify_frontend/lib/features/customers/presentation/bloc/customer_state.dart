import 'package:equatable/equatable.dart';
import '../../domain/entities/customer_entity.dart';

abstract class CustomerState extends Equatable {
  const CustomerState();

  @override
  List<Object?> get props => [];
}

class CustomerInitial extends CustomerState {}

class CustomerSearching extends CustomerState {}

class CustomerFound extends CustomerState {
  final CustomerEntity customer;

  const CustomerFound(this.customer);

  @override
  List<Object?> get props => [customer];
}

class CustomerNotFound extends CustomerState {
  final String phone;

  const CustomerNotFound(this.phone);

  @override
  List<Object?> get props => [phone];
}

class CustomerCreated extends CustomerState {
  final CustomerEntity customer;

  const CustomerCreated(this.customer);

  @override
  List<Object?> get props => [customer];
}

class CustomerSelected extends CustomerState {
  final CustomerEntity customer;
  final bool isRedeeming;
  final int pointsToRedeem;
  final int discountFromPoints;

  const CustomerSelected({
    required this.customer,
    this.isRedeeming = false,
    this.pointsToRedeem = 0,
    this.discountFromPoints = 0,
  });

  @override
  List<Object?> get props => [
        customer,
        isRedeeming,
        pointsToRedeem,
        discountFromPoints,
      ];

  CustomerSelected copyWith({
    CustomerEntity? customer,
    bool? isRedeeming,
    int? pointsToRedeem,
    int? discountFromPoints,
  }) {
    return CustomerSelected(
      customer: customer ?? this.customer,
      isRedeeming: isRedeeming ?? this.isRedeeming,
      pointsToRedeem: pointsToRedeem ?? this.pointsToRedeem,
      discountFromPoints: discountFromPoints ?? this.discountFromPoints,
    );
  }
}

class CustomerActionSuccess extends CustomerState {
  final String message;

  const CustomerActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class CustomerError extends CustomerState {
  final String message;

  const CustomerError(this.message);

  @override
  List<Object?> get props => [message];
}
