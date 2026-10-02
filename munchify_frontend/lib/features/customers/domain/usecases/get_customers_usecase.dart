import 'package:dartz/dartz.dart';
import '../../../../core/errors/Failures.dart';
import '../../../../core/utils/PagedResult.dart';
import '../entities/customer_entity.dart';
import '../repositories/customer_repository.dart';

class GetCustomersUseCase {
  final CustomerRepository repository;

  GetCustomersUseCase(this.repository);

  Future<Either<Failure, PagedResult<CustomerEntity>>> call({
    required int pageIndex,
    required int pageSize,
    String? searchKeyword,
  }) async {
    return await repository.getAllCustomers(pageIndex, pageSize, searchKeyword);
  }
}