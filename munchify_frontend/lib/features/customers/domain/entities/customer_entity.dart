import 'package:equatable/equatable.dart';

class CustomerEntity extends Equatable {
  final int customerId;
  final String customerName;
  final String phone;
  final int loyaltyPoints;
  final DateTime createdAt;

  const CustomerEntity({
    required this.customerId,
    required this.customerName,
    required this.phone,
    required this.loyaltyPoints,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        customerId,
        customerName,
        phone,
        loyaltyPoints,
        createdAt,
      ];
}
