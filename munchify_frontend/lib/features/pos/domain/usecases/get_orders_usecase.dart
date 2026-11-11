import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/Failures.dart';
import '../entities/order_entity.dart';
import '../repositories/order_repository.dart';

class GetOrdersUseCase {
  final OrderRepository repository;

  GetOrdersUseCase(this.repository);

  Future<Either<Failure, List<OrderEntity>>> execute({
    int page = 1,
    int pageSize = 20,
  }) {
    return repository.getOrders(page: page, pageSize: pageSize);
  }
}
