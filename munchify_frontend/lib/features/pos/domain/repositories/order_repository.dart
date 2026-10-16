import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/Failures.dart';
import '../entities/order_entity.dart';

abstract class OrderRepository {
  Future<Either<Failure, OrderEntity>> createOrder({
    int? customerId,
    String? promotionCode,
    required String paymentMethod,
    int pointsToRedeem = 0,
    required List<Map<String, int>> items,
  });

  Future<Either<Failure, List<OrderEntity>>> getOrders({
    int page = 1,
    int pageSize = 20,
  });
}
