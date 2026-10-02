import 'package:dartz/dartz.dart';
import '../../../../core/errors/Failures.dart';
import '../entities/customer_entity.dart';
import '../repositories/customer_repository.dart';

class SearchCustomerUseCase {
  final CustomerRepository repository;

  SearchCustomerUseCase(this.repository);

  Future<Either<Failure, CustomerEntity>> call(String phone) {
    return repository.searchByPhone(phone);
  }
}
