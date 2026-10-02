import 'package:munchify_frontend/core/constants/ApiEndpoints.dart';
import 'package:munchify_frontend/core/network/DioClient.dart';
import 'package:munchify_frontend/core/utils/PagedResult.dart';
import 'package:munchify_frontend/features/inventory/data/models/stock_movement_model.dart';

abstract class InventoryRemoteDataSource {
  Future<PagedResult<StockMovementModel>> getStockMovements({
    int? productId,
    String? movementType,
    DateTime? from,
    DateTime? to,
    int page = 1,
    int pageSize = 20,
  });

  Future<StockMovementModel> adjustStock({
    required int productId,
    required int quantityChange,
    required String reason,
    required String movementType,
  });
}

class InventoryRemoteDataSourceImpl implements InventoryRemoteDataSource {
  final DioClient dioClient;

  InventoryRemoteDataSourceImpl({required this.dioClient});

  @override
  Future<PagedResult<StockMovementModel>> getStockMovements({
    int? productId,
    String? movementType,
    DateTime? from,
    DateTime? to,
    int page = 1,
    int pageSize = 20,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'pageSize': pageSize,
    };

    if (productId != null) queryParams['productId'] = productId;
    if (movementType != null) queryParams['movementType'] = movementType;
    if (from != null) queryParams['from'] = from.toIso8601String();
    if (to != null) queryParams['to'] = to.toIso8601String();

    final response = await dioClient.dio.get(
      ApiEndpoints.stockMovements,
      queryParameters: queryParams,
    );

    if (response.statusCode == 200) {
      final data = response.data['data'];
      final items = (data['items'] as List)
          .map((item) => StockMovementModel.fromJson(item))
          .toList();

      return PagedResult<StockMovementModel>(
        items: items,
        totalCount: data['totalCount'],
        pageNumber: data['pageNumber'],
        pageSize: data['pageSize'],
      );
    } else {
      throw Exception('Failed to load stock movements');
    }
  }

  @override
  Future<StockMovementModel> adjustStock({
    required int productId,
    required int quantityChange,
    required String reason,
    required String movementType,
  }) async {
    final response = await dioClient.dio.post(
      ApiEndpoints.adjustStock,
      data: {
        'productId': productId,
        'quantityChange': quantityChange,
        'reason': reason,
        'movementType': movementType,
      },
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return StockMovementModel.fromJson(response.data['data']);
    } else {
      throw Exception(response.data['message'] ?? 'Failed to adjust stock');
    }
  }
}
