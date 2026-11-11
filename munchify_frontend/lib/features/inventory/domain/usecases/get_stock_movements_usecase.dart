import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/Failures.dart';
import '../../../../core/utils/PagedResult.dart';
import '../entities/stock_movement_entity.dart';
import '../repositories/inventory_repository.dart';

class GetStockMovementsUseCase {
  final InventoryRepository repository;

  GetStockMovementsUseCase(this.repository);

  Future<Either<Failure, PagedResult<StockMovementEntity>>> execute(
      GetStockMovementsParams params) {
    return repository.getStockMovements(
      productId: params.productId,
      movementType: params.movementType,
      from: params.from,
      to: params.to,
      page: params.page,
      pageSize: params.pageSize,
    );
  }
}

class GetStockMovementsParams extends Equatable {
  final int? productId;
  final String? movementType;
  final DateTime? from;
  final DateTime? to;
  final int page;
  final int pageSize;

  const GetStockMovementsParams({
    this.productId,
    this.movementType,
    this.from,
    this.to,
    this.page = 1,
    this.pageSize = 20,
  });

  @override
  List<Object?> get props => [productId, movementType, from, to, page, pageSize];
}
