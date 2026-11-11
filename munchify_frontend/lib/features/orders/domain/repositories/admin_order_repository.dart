import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/Failures.dart';
import '../../data/models/admin_order_filter_params.dart';
import '../entities/admin_order_detail_entity.dart';
import '../entities/paged_orders_result.dart';

abstract class AdminOrderRepository {
  Future<Either<Failure, PagedOrdersResult>> getOrders(AdminOrderFilterParams params);
  Future<Either<Failure, AdminOrderDetailEntity>> getOrderDetail(int orderId);
}
