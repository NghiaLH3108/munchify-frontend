import 'package:dartz/dartz.dart';
import '../../../../core/errors/Failures.dart';
import '../../../../core/utils/PagedResult.dart';
import '../entities/stock_movement_entity.dart';

abstract class InventoryRepository {
  Future<Either<Failure, PagedResult<StockMovementEntity>>> getStockMovements({
    int? productId,
    String? movementType,
    DateTime? from,
    DateTime? to,
    int page = 1,
    int pageSize = 20,
  });

  Future<Either<Failure, StockMovementEntity>> adjustStock({
    required int productId,
    required int quantityChange,
    required String reason,
    required String movementType,
  });
}
