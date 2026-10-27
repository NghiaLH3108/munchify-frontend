import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/Failures.dart';
import '../../data/models/admin_order_filter_params.dart';
import '../entities/paged_orders_result.dart';
import '../repositories/admin_order_repository.dart';

class GetAdminOrdersUseCase {
  final AdminOrderRepository repository;

  GetAdminOrdersUseCase(this.repository);

  Future<Either<Failure, PagedOrdersResult>> execute(AdminOrderFilterParams params) {
    return repository.getOrders(params);
  }
}
