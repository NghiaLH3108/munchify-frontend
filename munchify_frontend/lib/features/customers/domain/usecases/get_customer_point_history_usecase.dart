import 'package:dartz/dartz.dart';
import '../../../../core/errors/Failures.dart';
import '../../../../core/utils/PagedResult.dart';
import '../entities/customer_point_history_entity.dart';
import '../repositories/customer_repository.dart';

class GetCustomerPointHistoryUseCase {
  final CustomerRepository repository;

  GetCustomerPointHistoryUseCase(this.repository);

  Future<Either<Failure, PagedResult<CustomerPointHistoryEntity>>> call({
    required int customerId,
    required int pageIndex,
    required int pageSize,
  }) async {
    return await repository.getCustomerHistory(customerId, pageIndex, pageSize);
  }
}