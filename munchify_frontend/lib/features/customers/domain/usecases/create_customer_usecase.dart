import 'package:dartz/dartz.dart';
import '../../../../core/errors/Failures.dart';
import '../entities/customer_entity.dart';
import '../repositories/customer_repository.dart';

class CreateCustomerUseCase {
  final CustomerRepository repository;

  CreateCustomerUseCase(this.repository);

  Future<Either<Failure, CustomerEntity>> call({
    required String customerName,
    required String phone,
  }) {
    return repository.createCustomer(
      customerName: customerName,
      phone: phone,
    );
  }
}
