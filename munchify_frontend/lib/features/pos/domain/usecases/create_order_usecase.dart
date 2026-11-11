import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/Failures.dart';
import '../entities/order_entity.dart';
import '../repositories/order_repository.dart';

class CreateOrderUseCase {
  final OrderRepository repository;

  CreateOrderUseCase(this.repository);

  Future<Either<Failure, OrderEntity>> execute({
    int? customerId,
    String? promotionCode,
    required String paymentMethod,
    int pointsToRedeem = 0,
    double? cashGiven,
    required List<Map<String, int>> items,
  }) {
    return repository.createOrder(
      customerId: customerId,
      promotionCode: promotionCode,
      paymentMethod: paymentMethod,
      pointsToRedeem: pointsToRedeem,
      cashGiven: cashGiven,
      items: items,
    );
  }
}
