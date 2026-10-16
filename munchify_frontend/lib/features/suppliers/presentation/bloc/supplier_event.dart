import 'package:equatable/equatable.dart';

abstract class SupplierEvent extends Equatable {
  const SupplierEvent();

  @override
  List<Object?> get props => [];
}

class LoadSuppliersEvent extends SupplierEvent {
  final String? search;
  final bool? isActive;

  const LoadSuppliersEvent({this.search, this.isActive});

  @override
  List<Object?> get props => [search, isActive];
}

class CreateSupplierEvent extends SupplierEvent {
  final String supplierName;
  final String? contactName;
  final String? phone;
  final String? address;
  final bool? isActive;
  final List<int>? categoryIds;

  const CreateSupplierEvent({
    required this.supplierName,
    this.contactName,
    this.phone,
    this.address,
    this.isActive,
    this.categoryIds,
  });

  @override
  List<Object?> get props => [supplierName, contactName, phone, address, isActive, categoryIds];
}

class UpdateSupplierEvent extends SupplierEvent {
  final int id;
  final String supplierName;
  final String? contactName;
  final String? phone;
  final String? address;
  final bool? isActive;
  final List<int>? categoryIds;

  const UpdateSupplierEvent({
    required this.id,
    required this.supplierName,
    this.contactName,
    this.phone,
    this.address,
    this.isActive,
    this.categoryIds,
  });

  @override
  List<Object?> get props => [id, supplierName, contactName, phone, address, isActive, categoryIds];
}

class DeleteSupplierEvent extends SupplierEvent {
  final int id;

  const DeleteSupplierEvent(this.id);

  @override
  List<Object?> get props => [id];
}
