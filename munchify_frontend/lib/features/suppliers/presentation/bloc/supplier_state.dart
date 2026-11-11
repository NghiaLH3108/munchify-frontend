import 'package:equatable/equatable.dart';
import '../../domain/entities/supplier_entity.dart';

abstract class SupplierState extends Equatable {
  const SupplierState();

  @override
  List<Object?> get props => [];
}

class SupplierInitial extends SupplierState {}

class SupplierLoading extends SupplierState {}

class SupplierLoaded extends SupplierState {
  final List<SupplierEntity> suppliers;
  final String? message;

  const SupplierLoaded({
    required this.suppliers,
    this.message,
  });

  @override
  List<Object?> get props => [suppliers, message];
}

class SupplierActionSuccess extends SupplierState {
  final String message;
  const SupplierActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class SupplierError extends SupplierState {
  final String message;
  const SupplierError(this.message);

  @override
  List<Object?> get props => [message];
}
