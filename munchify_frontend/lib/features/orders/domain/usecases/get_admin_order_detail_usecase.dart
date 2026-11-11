import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/Failures.dart';
import '../entities/admin_order_detail_entity.dart';
import '../repositories/admin_order_repository.dart';

class GetAdminOrderDetailUseCase {
  final AdminOrderRepository repository;

  GetAdminOrderDetailUseCase(this.repository);

  Future<Either<Failure, AdminOrderDetailEntity>> execute(int orderId) {
    return repository.getOrderDetail(orderId);
  }
}
