import 'package:dartz/dartz.dart';
import 'package:munchify_frontend/core/errors/Failures.dart';
import 'package:munchify_frontend/core/network/NetworkInfo.dart';
import 'package:munchify_frontend/core/utils/PagedResult.dart';
import 'package:munchify_frontend/features/inventory/data/datasources/inventory_remote_datasource.dart';
import 'package:munchify_frontend/features/inventory/domain/entities/stock_movement_entity.dart';
import 'package:munchify_frontend/features/inventory/domain/repositories/inventory_repository.dart';

class InventoryRepositoryImpl implements InventoryRepository {
  final InventoryRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  InventoryRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, PagedResult<StockMovementEntity>>> getStockMovements({
    int? productId,
    String? movementType,
    DateTime? from,
    DateTime? to,
    int page = 1,
    int pageSize = 20,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.getStockMovements(
          productId: productId,
          movementType: movementType,
          from: from,
          to: to,
          page: page,
          pageSize: pageSize,
        );
        return Right(result);
      } catch (e) {
        print('Lỗi InventoryRepositoryImpl: $e');
        return Left(ServerFailure(message: 'Lỗi khi tải lịch sử: $e'));
      }
    } else {
      return const Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, StockMovementEntity>> adjustStock({
    required int productId,
    required int quantityChange,
    required String reason,
    required String movementType,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.adjustStock(
          productId: productId,
          quantityChange: quantityChange,
          reason: reason,
          movementType: movementType,
        );
        return Right(result);
      } catch (e) {
        return Left(ServerFailure(message: 'Lỗi khi điều chỉnh tồn kho: $e'));
      }
    } else {
      return const Left(NetworkFailure());
    }
  }
}
