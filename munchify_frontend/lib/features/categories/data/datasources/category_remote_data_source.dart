import '../../../../core/network/DioClient.dart';
import '../../../../core/constants/ApiEndpoints.dart';
import '../models/category_model.dart';

abstract class CategoryRemoteDataSource {
  Future<List<CategoryModel>> getCategories({
    String searchTerm = '',
    bool? isActive,
    int page = 1,
    int pageSize = 10,
  });
  Future<CategoryModel> getCategoryById(int id);
  Future<CategoryModel> createCategory({
    required String categoryName,
    String? description,
    required bool isActive,
  });
  Future<CategoryModel> updateCategory({
    required int id,
    required String categoryName,
    String? description,
    required bool isActive,
  });
  Future<bool> deleteCategory(int id);
}

class CategoryRemoteDataSourceImpl implements CategoryRemoteDataSource {
  final DioClient dioClient;

  CategoryRemoteDataSourceImpl({required this.dioClient});

  @override
  Future<List<CategoryModel>> getCategories({
    String searchTerm = '',
    bool? isActive,
    int page = 1,
    int pageSize = 10,
  }) async {
    final queryParameters = {
      'searchTerm': searchTerm,
      'isActive': ?isActive,
      'page': page,
      'pageSize': pageSize,
    };

    final response = await dioClient.dio.get(
      ApiEndpoints.categories,
      queryParameters: queryParameters,
    );

    if (response.data != null && response.data['success'] == true) {
      final items = response.data['data']['items'] as List;
      return items.map((e) => CategoryModel.fromJson(e)).toList();
    } else {
      throw Exception(response.data?['message'] ?? 'Failed to fetch categories');
    }
  }

  @override
  Future<CategoryModel> getCategoryById(int id) async {
    final response = await dioClient.dio.get('${ApiEndpoints.categories}/$id');
    if (response.data != null && response.data['success'] == true) {
      return CategoryModel.fromJson(response.data['data']);
    } else {
      throw Exception(response.data?['message'] ?? 'Failed to fetch category');
    }
  }

  @override
  Future<CategoryModel> createCategory({
    required String categoryName,
    String? description,
    required bool isActive,
  }) async {
    final response = await dioClient.dio.post(
      ApiEndpoints.categories,
      data: {
        'categoryName': categoryName,
        'description': description,
        'isActive': isActive,
      },
    );
    if (response.data != null && response.data['success'] == true) {
      return CategoryModel.fromJson(response.data['data']);
    } else {
      throw Exception(response.data?['message'] ?? 'Failed to create category');
    }
  }

  @override
  Future<CategoryModel> updateCategory({
    required int id,
    required String categoryName,
    String? description,
    required bool isActive,
  }) async {
    final response = await dioClient.dio.put(
      '${ApiEndpoints.categories}/$id',
      data: {
        'categoryName': categoryName,
        'description': description,
        'isActive': isActive,
      },
    );
    if (response.data != null && response.data['success'] == true) {
      return CategoryModel.fromJson(response.data['data']);
    } else {
      throw Exception(response.data?['message'] ?? 'Failed to update category');
    }
  }

  @override
  Future<bool> deleteCategory(int id) async {
    final response = await dioClient.dio.delete('${ApiEndpoints.categories}/$id');
    if (response.data != null && response.data['success'] == true) {
      return true;
    } else {
      throw Exception(response.data?['message'] ?? 'Failed to delete category');
    }
  }
}
