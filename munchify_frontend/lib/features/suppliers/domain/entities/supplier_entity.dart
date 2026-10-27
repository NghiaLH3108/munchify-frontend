import 'package:equatable/equatable.dart';

class SupplierEntity extends Equatable {
  final int supplierId;
  final String supplierName;
  final String? contactName;
  final String? phone;
  final String? address;
  final bool isActive;
  final DateTime createdAt;
  final List<int> categoryIds;
  final List<String> categoryNames;

  const SupplierEntity({
    required this.supplierId,
    required this.supplierName,
    this.contactName,
    this.phone,
    this.address,
    required this.isActive,
    required this.createdAt,
    this.categoryIds = const [],
    this.categoryNames = const [],
  });

  @override
  List<Object?> get props => [
        supplierId,
        supplierName,
        contactName,
        phone,
        address,
        isActive,
        createdAt,
        categoryIds,
        categoryNames,
      ];
}
