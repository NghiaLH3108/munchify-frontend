import 'package:dartz/dartz.dart';
import '../../../../core/errors/Failures.dart';
import '../entities/stock_movement_entity.dart';
import '../repositories/inventory_repository.dart';

class AdjustStockUseCase {
  final InventoryRepository repository;

  AdjustStockUseCase(this.repository);

  Future<Either<Failure, StockMovementEntity>> execute(AdjustStockParams params) {
    return repository.adjustStock(
      productId: params.productId,
      quantityChange: params.quantityChange,
      reason: params.reason,
      movementType: params.movementType,
    );
  }
}

class AdjustStockParams {
  final int productId;
  final int quantityChange;
  final String reason;
  final String movementType;

  AdjustStockParams({
    required this.productId,
    required this.quantityChange,
    required this.reason,
    required this.movementType,
  });
}
