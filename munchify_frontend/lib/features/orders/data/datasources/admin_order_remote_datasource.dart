import '../../../../core/constants/ApiEndpoints.dart';
import '../../../../core/network/DioClient.dart';
import '../models/admin_order_detail_model.dart';
import '../models/admin_order_filter_params.dart';
import '../models/admin_order_summary_model.dart';
import '../../domain/entities/paged_orders_result.dart';

abstract class AdminOrderRemoteDataSource {
  Future<PagedOrdersResult> getOrders(AdminOrderFilterParams params);
  Future<AdminOrderDetailModel> getOrderDetail(int orderId);
}

class AdminOrderRemoteDataSourceImpl implements AdminOrderRemoteDataSource {
  final DioClient dioClient;

  AdminOrderRemoteDataSourceImpl({required this.dioClient});

  @override
  Future<PagedOrdersResult> getOrders(AdminOrderFilterParams params) async {
    final response = await dioClient.dio.get(
      ApiEndpoints.orders,
      queryParameters: params.toMap(),
    );

    if (response.data != null && response.data['success'] == true) {
      final data = response.data['data'];
      final rawItems = data['items'] as List<dynamic>? ?? [];
      final items = rawItems
          .map((e) => AdminOrderSummaryModel.fromJson(e as Map<String, dynamic>))
          .toList();

      return PagedOrdersResult(
        items: items,
        totalCount: data['totalCount'] ?? 0,
        pageNumber: data['pageNumber'] ?? 1,
        pageSize: data['pageSize'] ?? 10,
        totalPages: data['totalPages'] ?? 1,
      );
    } else {
      throw Exception(
        response.data?['message'] ?? 'Không thể tải danh sách đơn hàng',
      );
    }
  }

  @override
  Future<AdminOrderDetailModel> getOrderDetail(int orderId) async {
    final response = await dioClient.dio.get(
      ApiEndpoints.orderById(orderId),
    );

    if (response.data != null && response.data['success'] == true) {
      final data = response.data['data'] as Map<String, dynamic>;
      return AdminOrderDetailModel.fromJson(data);
    } else {
      throw Exception(
        response.data?['message'] ?? 'Không thể tải chi tiết đơn hàng #$orderId',
      );
    }
  }
}
