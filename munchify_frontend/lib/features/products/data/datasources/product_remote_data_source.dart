import 'package:dio/dio.dart';
import '../../../../core/constants/ApiEndpoints.dart';
import '../../../../core/network/DioClient.dart';
import '../models/product_model.dart';
import '../models/product_request_model.dart';

abstract class ProductRemoteDataSource {
  Future<List<ProductModel>> getProducts({
    String? search,
    String? categoryId,
    bool? isActive,
    bool? lowStockWarning,
  });
  Future<ProductModel> addProduct(ProductRequestModel request);
  Future<ProductModel> updateProduct(String id, ProductRequestModel request);
  Future<void> toggleProductStatus(String id, bool isActive);
}

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final DioClient dioClient;

  ProductRemoteDataSourceImpl({required this.dioClient});

  @override
  Future<List<ProductModel>> getProducts({
    String? search,
    String? categoryId,
    bool? isActive,
    bool? lowStockWarning,
  }) async {
    final response = await dioClient.dio.get(
      ApiEndpoints.products,
      queryParameters: {
        if (search != null && search.isNotEmpty) 'searchTerm': search,
        if (categoryId != null && categoryId.isNotEmpty) 'categoryId': categoryId,
        if (isActive != null) 'isActive': isActive,
        if (lowStockWarning != null && lowStockWarning) 'lowStockWarning': lowStockWarning,
        'pageSize': 100, // Load enough items for admin table
      },
    );
    if (response.data != null && response.data['success'] == true) {
      final dataObj = response.data['data'];
      List<dynamic> items = [];
      if (dataObj is List) {
        items = dataObj;
      } else if (dataObj != null && dataObj['items'] is List) {
        items = dataObj['items'] as List;
      }
      return items.map((json) => ProductModel.fromJson(json)).toList();
    } else {
      throw Exception(response.data?['message'] ?? 'Failed to fetch products');
    }
  }

  @override
  Future<ProductModel> addProduct(ProductRequestModel request) async {
    try {
      final response = await dioClient.dio.post(
        ApiEndpoints.products,
        data: request.toJson(),
      );
      final data = response.data['data'] ?? response.data;
      return ProductModel.fromJson(data);
    } on DioException catch (e) {
      final message = e.response?.data != null ? e.response!.data.toString() : e.message;
      if (message != null && (message.contains('An error occurred while saving the entity changes') || message.contains('UNIQUE'))) {
        throw Exception('Mã SKU này đã tồn tại trong hệ thống. Vui lòng nhập mã khác!');
      }
      throw Exception('Failed to add product: $message');
    }
  }

  @override
  Future<ProductModel> updateProduct(String id, ProductRequestModel request) async {
    try {
      final response = await dioClient.dio.put(
        '${ApiEndpoints.products}/$id',
        data: request.toJson(),
      );
      final data = response.data['data'] ?? response.data;
      return ProductModel.fromJson(data);
    } on DioException catch (e) {
      final message = e.response?.data != null ? e.response!.data.toString() : e.message;
      if (message != null && (message.contains('An error occurred while saving the entity changes') || message.contains('UNIQUE'))) {
        throw Exception('Mã SKU này đã tồn tại trong hệ thống. Vui lòng nhập mã khác!');
      }
      throw Exception('Failed to update product: $message');
    }
  }

  @override
  Future<void> toggleProductStatus(String id, bool isActive) async {
    await dioClient.dio.patch(
      '${ApiEndpoints.products}/$id/status',
      data: {'isActive': isActive},
    );
  }
}
