import 'package:dartz/dartz.dart';
import 'package:munchify_frontend/core/errors/Failures.dart';
import 'package:munchify_frontend/features/inventory/domain/entities/stock_movement_entity.dart';
import 'package:munchify_frontend/features/inventory/domain/repositories/inventory_repository.dart';

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
