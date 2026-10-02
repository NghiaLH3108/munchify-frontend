import 'package:dartz/dartz.dart';
import '../../../../core/errors/Failures.dart';
import '../entities/customer_entity.dart';

abstract class CustomerRepository {
  Future<Either<Failure, CustomerEntity>> searchByPhone(String phone);
  Future<Either<Failure, CustomerEntity>> createCustomer({
    required String customerName,
    required String phone,
  });
}
