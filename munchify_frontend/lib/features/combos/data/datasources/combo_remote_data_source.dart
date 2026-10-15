import '../../../../core/constants/ApiEndpoints.dart';
import '../../../../core/network/DioClient.dart';
import '../../domain/entities/combo_input.dart';
import '../models/combo_model.dart';
import '../models/combo_option_models.dart';
import '../../domain/entities/combo_form_options_entity.dart';

class ComboPageModel {
  final List<ComboModel> items;
  final int totalCount;
  final int page;
  final int pageSize;

  const ComboPageModel({
    required this.items,
    required this.totalCount,
    required this.page,
    required this.pageSize,
  });
}

abstract class ComboRemoteDataSource {
  Future<ComboPageModel> getCombos({
    String searchTerm = '',
    bool? isActive,
    int page = 1,
    int pageSize = 10,
  });
  Future<ComboModel> createCombo(ComboInput input);
  Future<ComboModel> updateCombo(int id, ComboInput input);
  Future<String> deleteCombo(int id);
  Future<ComboFormOptionsEntity> getFormOptions();
}

class ComboRemoteDataSourceImpl implements ComboRemoteDataSource {
  final DioClient dioClient;

  ComboRemoteDataSourceImpl({required this.dioClient});

  Map<String, dynamic> _toBody(ComboInput input) => {
        'productCode': input.code,
        'productName': input.name,
        'description': input.description,
        'price': input.price,
        'imageUrl': input.imageUrl,
        'isActive': input.isActive,
        'items': input.items
            .map((e) => {
                  'componentProductId': e.componentProductId,
                  'quantity': e.quantity,
                })
            .toList(),
      };

  List _extractList(dynamic responseData) {
    final data = responseData?['data'] ?? responseData;
    if (data is List) return data;
    if (data is Map && data['items'] is List) return data['items'] as List;
    return const [];
  }

  @override
  Future<ComboPageModel> getCombos({
    String searchTerm = '',
    bool? isActive,
    int page = 1,
    int pageSize = 10,
  }) async {
    final response = await dioClient.dio.get(
      ApiEndpoints.combos,
      queryParameters: {
        if (searchTerm.isNotEmpty) 'searchTerm': searchTerm,
        'isActive': ?isActive,
        'page': page,
        'pageSize': pageSize,
      },
    );

    if (response.data != null && response.data['success'] == true) {
      final data = response.data['data'] as Map<String, dynamic>;
      final items = (data['items'] as List)
          .map((e) => ComboModel.fromJson(e as Map<String, dynamic>))
          .toList();
      return ComboPageModel(
        items: items,
        totalCount: (data['totalCount'] as num?)?.toInt() ?? items.length,
        page: (data['pageNumber'] as num?)?.toInt() ?? page,
        pageSize: (data['pageSize'] as num?)?.toInt() ?? pageSize,
      );
    }
    throw Exception(response.data?['message'] ?? 'Không thể tải danh sách combo');
  }

  @override
  Future<ComboModel> createCombo(ComboInput input) async {
    final response =
        await dioClient.dio.post(ApiEndpoints.combos, data: _toBody(input));
    if (response.data != null && response.data['success'] == true) {
      return ComboModel.fromJson(response.data['data']);
    }
    throw Exception(response.data?['message'] ?? 'Không thể tạo combo');
  }

  @override
  Future<ComboModel> updateCombo(int id, ComboInput input) async {
    final response = await dioClient.dio
        .put('${ApiEndpoints.combos}/$id', data: _toBody(input));
    if (response.data != null && response.data['success'] == true) {
      return ComboModel.fromJson(response.data['data']);
    }
    throw Exception(response.data?['message'] ?? 'Không thể cập nhật combo');
  }

  @override
  Future<String> deleteCombo(int id) async {
    final response = await dioClient.dio.delete('${ApiEndpoints.combos}/$id');
    if (response.data != null && response.data['success'] == true) {
      return (response.data['message'] as String?) ?? 'Đã xóa combo.';
    }
    throw Exception(response.data?['message'] ?? 'Không thể xóa combo');
  }

  @override
  Future<ComboFormOptionsEntity> getFormOptions() async {
    final results = await Future.wait([
      dioClient.dio.get(ApiEndpoints.categories, queryParameters: {
        'isActive': true,
        'page': 1,
        'pageSize': 100,
      }),
      dioClient.dio.get(ApiEndpoints.units, queryParameters: {
        'isActive': true,
        'page': 1,
        'pageSize': 100,
      }),
      dioClient.dio.get(ApiEndpoints.products, queryParameters: {
        'isActive': true,
        'isCombo': false, // components must be single products
        'page': 1,
        'pageSize': 100,
      }),
    ]);

    final categories = _extractList(results[0].data)
        .map((e) => ComboOptionEntity(
              id: (e['categoryId'] as num).toInt(),
              name: (e['categoryName'] ?? '') as String,
            ))
        .toList();

    final units = _extractList(results[1].data)
        .map((e) => ComboOptionEntity(
              id: (e['unitId'] as num).toInt(),
              name: (e['unitName'] ?? '') as String,
            ))
        .toList();

    final products = _extractList(results[2].data)
        .map((e) =>
            ComponentProductModel.fromJson(e as Map<String, dynamic>).toEntity())
        .toList();

    return ComboFormOptionsEntity(
      categories: categories,
      units: units,
      products: products,
    );
  }
}
