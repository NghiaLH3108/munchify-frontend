import 'package:dio/dio.dart';
import '../../../../core/constants/ApiEndpoints.dart';
import '../models/category_model.dart';
import '../models/product_model.dart';

import '../../../../core/network/DioClient.dart';

abstract class PosRemoteDataSource {
  Future<List<CategoryModel>> getCategories();
  Future<List<ProductModel>> getProducts({String? searchTerm, int? categoryId});
}

class PosRemoteDataSourceImpl implements PosRemoteDataSource {
  final DioClient dioClient;

  PosRemoteDataSourceImpl({required this.dioClient});

  @override
  Future<List<CategoryModel>> getCategories() async {
    final response = await dioClient.dio.get(ApiEndpoints.categories);
    final responseData = response.data['data'] ?? response.data;
    List dataList = [];
    if (responseData is List) {
      dataList = responseData;
    } else if (responseData is Map && responseData.containsKey('items')) {
      dataList = responseData['items'] as List;
    }
    return dataList.map((json) => CategoryModel.fromJson(json)).toList();
  }

  @override
  Future<List<ProductModel>> getProducts({String? searchTerm, int? categoryId}) async {
    final response = await dioClient.dio.get(
      ApiEndpoints.products,
      queryParameters: {
        if (searchTerm != null && searchTerm.isNotEmpty) 'searchTerm': searchTerm,
        if (categoryId != null) 'categoryId': categoryId,
        'isActive': true,
        'pageSize': 100, // Load all products for POS
      },
    );
    final responseData = response.data['data'] ?? response.data;
    List dataList = [];
    if (responseData is List) {
      dataList = responseData;
    } else if (responseData is Map && responseData.containsKey('items')) {
      dataList = responseData['items'] as List;
    }
    return dataList.map((json) => ProductModel.fromJson(json)).toList();
  }
}
