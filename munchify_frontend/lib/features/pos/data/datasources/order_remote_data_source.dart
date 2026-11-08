import '../../../../core/constants/ApiEndpoints.dart';
import '../../../../core/network/DioClient.dart';
import '../models/order_model.dart';

abstract class OrderRemoteDataSource {
  Future<OrderModel> createOrder({
    int? customerId,
    String? promotionCode,
    required String paymentMethod,
    int pointsToRedeem = 0,
    double? cashGiven,
    required List<Map<String, int>> items,
  });

  Future<List<OrderModel>> getOrders({int page = 1, int pageSize = 20});
}

class OrderRemoteDataSourceImpl implements OrderRemoteDataSource {
  final DioClient dioClient;

  OrderRemoteDataSourceImpl({required this.dioClient});

  @override
  Future<OrderModel> createOrder({
    int? customerId,
    String? promotionCode,
    required String paymentMethod,
    int pointsToRedeem = 0,
    double? cashGiven,
    required List<Map<String, int>> items,
  }) async {
    final body = <String, dynamic>{
      'paymentMethod': paymentMethod,
      'pointsToRedeem': pointsToRedeem,
      'items': items
          .map((i) => {'productId': i['productId'], 'quantity': i['quantity']})
          .toList(),
    };
    if (customerId != null) body['customerId'] = customerId;
    if (promotionCode != null && promotionCode.isNotEmpty) {
      body['promotionCode'] = promotionCode;
    }
    if (cashGiven != null) body['cashGiven'] = cashGiven;

    final response = await dioClient.dio.post(ApiEndpoints.orders, data: body);

    if (response.data != null && response.data['success'] == true) {
      return OrderModel.fromJson(response.data['data']);
    } else {
      throw Exception(
          response.data?['message'] ?? 'Không thể tạo đơn hàng');
    }
  }

  @override
  Future<List<OrderModel>> getOrders({int page = 1, int pageSize = 20}) async {
    final response = await dioClient.dio.get(
      ApiEndpoints.orders,
      queryParameters: {'page': page, 'pageSize': pageSize},
    );

    if (response.data != null && response.data['success'] == true) {
      final data = response.data['data'];
      List items = [];
      if (data is List) {
        items = data;
      } else if (data is Map && data.containsKey('items')) {
        items = data['items'] as List;
      }
      final orders = items
          .map((e) => OrderModel.fromJson(e as Map<String, dynamic>))
          .toList();

      // Nếu backend đang chạy bản chưa kèm orderDetails trong danh sách summary,
      // tự động gọi GET /api/orders/{id} song song để lấy đầy đủ danh sách sản phẩm
      final needDetailFetch = orders.any(
        (o) => o.orderDetails.isEmpty && o.itemCount > 0 && o.orderId > 0,
      );
      if (needDetailFetch) {
        final hydrated = await Future.wait(
          orders.map((order) async {
            if (order.orderDetails.isNotEmpty || order.orderId <= 0) {
              return order;
            }
            try {
              final detailRes = await dioClient.dio.get(
                '${ApiEndpoints.orders}/${order.orderId}',
              );
              if (detailRes.data != null && detailRes.data['success'] == true) {
                return OrderModel.fromJson(
                  detailRes.data['data'] as Map<String, dynamic>,
                );
              }
            } catch (_) {
              // Giữ nguyên order summary nếu lấy chi tiết lỗi
            }
            return order;
          }),
        );
        return hydrated;
      }

      return orders;
    } else {
      throw Exception(
          response.data?['message'] ?? 'Không thể tải lịch sử đơn hàng');
    }
  }
}
