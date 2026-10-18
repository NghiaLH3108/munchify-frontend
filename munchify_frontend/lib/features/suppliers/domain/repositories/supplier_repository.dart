import 'package:dartz/dartz.dart';
import '../../../../core/errors/Failures.dart';
import '../entities/supplier_entity.dart';

abstract class SupplierRepository {
  Future<Either<Failure, List<SupplierEntity>>> getSuppliers({
    String? search,
    bool? isActive,
  });

  Future<Either<Failure, SupplierEntity>> getSupplierById(int id);

  Future<Either<Failure, SupplierEntity>> createSupplier({
    required String supplierName,
    String? contactName,
    String? phone,
    String? address,
    bool? isActive,
    List<int>? categoryIds,
  });

  Future<Either<Failure, SupplierEntity>> updateSupplier({
    required int id,
    required String supplierName,
    String? contactName,
    String? phone,
    String? address,
    bool? isActive,
    List<int>? categoryIds,
  });

  Future<Either<Failure, bool>> deleteSupplier(int id);
}
