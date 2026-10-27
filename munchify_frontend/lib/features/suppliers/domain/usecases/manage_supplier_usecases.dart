import 'package:dartz/dartz.dart';
import '../../../../core/errors/Failures.dart';
import '../entities/supplier_entity.dart';
import '../repositories/supplier_repository.dart';

class GetSuppliersUseCase {
  final SupplierRepository repository;
  GetSuppliersUseCase(this.repository);

  Future<Either<Failure, List<SupplierEntity>>> call({
    String? search,
    bool? isActive,
  }) {
    return repository.getSuppliers(search: search, isActive: isActive);
  }
}

class CreateSupplierUseCase {
  final SupplierRepository repository;
  CreateSupplierUseCase(this.repository);

  Future<Either<Failure, SupplierEntity>> call({
    required String supplierName,
    String? contactName,
    String? phone,
    String? address,
    bool? isActive,
    List<int>? categoryIds,
  }) {
    return repository.createSupplier(
      supplierName: supplierName,
      contactName: contactName,
      phone: phone,
      address: address,
      isActive: isActive,
      categoryIds: categoryIds,
    );
  }
}

class UpdateSupplierUseCase {
  final SupplierRepository repository;
  UpdateSupplierUseCase(this.repository);

  Future<Either<Failure, SupplierEntity>> call({
    required int id,
    required String supplierName,
    String? contactName,
    String? phone,
    String? address,
    bool? isActive,
    List<int>? categoryIds,
  }) {
    return repository.updateSupplier(
      id: id,
      supplierName: supplierName,
      contactName: contactName,
      phone: phone,
      address: address,
      isActive: isActive,
      categoryIds: categoryIds,
    );
  }
}

class DeleteSupplierUseCase {
  final SupplierRepository repository;
  DeleteSupplierUseCase(this.repository);

  Future<Either<Failure, bool>> call(int id) {
    return repository.deleteSupplier(id);
  }
}
