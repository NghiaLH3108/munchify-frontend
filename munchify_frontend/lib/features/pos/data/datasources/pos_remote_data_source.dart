import 'package:dio/dio.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../models/category_model.dart';
import '../models/product_model.dart';

abstract class PosRemoteDataSource {
  Future<List<CategoryModel>> getCategories();
  Future<List<ProductModel>> getProducts({String? searchTerm, int? categoryId});
}

class PosRemoteDataSourceImpl implements PosRemoteDataSource {
  final Dio dio;

  PosRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<CategoryModel>> getCategories() async {
    final response = await dio.get(ApiEndpoints.categories);
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
    final response = await dio.get(
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
