import '../../../../core/constants/ApiEndpoints.dart';
import '../../../../core/network/DioClient.dart';
import '../models/supplier_model.dart';

abstract class SupplierRemoteDataSource {
  Future<List<SupplierModel>> getSuppliers({String? search, bool? isActive});
  Future<SupplierModel> getSupplierById(int id);
  Future<SupplierModel> createSupplier(Map<String, dynamic> data);
  Future<SupplierModel> updateSupplier(int id, Map<String, dynamic> data);
  Future<bool> deleteSupplier(int id);
}

class SupplierRemoteDataSourceImpl implements SupplierRemoteDataSource {
  final DioClient dioClient;

  SupplierRemoteDataSourceImpl({required this.dioClient});

  @override
  Future<List<SupplierModel>> getSuppliers({String? search, bool? isActive}) async {
    final queryParams = <String, dynamic>{};
    if (search != null && search.isNotEmpty) {
      queryParams['search'] = search;
    }
    if (isActive != null) {
      queryParams['isActive'] = isActive;
    }

    final response = await dioClient.dio.get(
      ApiEndpoints.suppliers,
      queryParameters: queryParams,
    );

    final responseData = response.data;
    List rawList = [];
    if (responseData is Map && responseData.containsKey('data')) {
      rawList = responseData['data'] as List? ?? [];
    } else if (responseData is List) {
      rawList = responseData;
    }

    return rawList.map((item) => SupplierModel.fromJson(item as Map<String, dynamic>)).toList();
  }

  @override
  Future<SupplierModel> getSupplierById(int id) async {
    final response = await dioClient.dio.get('${ApiEndpoints.suppliers}/$id');
    final responseData = response.data;
    final itemData = (responseData is Map && responseData.containsKey('data'))
        ? responseData['data']
        : responseData;
    return SupplierModel.fromJson(itemData as Map<String, dynamic>);
  }

  @override
  Future<SupplierModel> createSupplier(Map<String, dynamic> data) async {
    final response = await dioClient.dio.post(
      ApiEndpoints.suppliers,
      data: data,
    );
    final responseData = response.data;
    final itemData = (responseData is Map && responseData.containsKey('data'))
        ? responseData['data']
        : responseData;
    return SupplierModel.fromJson(itemData as Map<String, dynamic>);
  }

  @override
  Future<SupplierModel> updateSupplier(int id, Map<String, dynamic> data) async {
    final response = await dioClient.dio.put(
      '${ApiEndpoints.suppliers}/$id',
      data: data,
    );
    final responseData = response.data;
    final itemData = (responseData is Map && responseData.containsKey('data'))
        ? responseData['data']
        : responseData;
    return SupplierModel.fromJson(itemData as Map<String, dynamic>);
  }

  @override
  Future<bool> deleteSupplier(int id) async {
    final response = await dioClient.dio.delete('${ApiEndpoints.suppliers}/$id');
    return response.statusCode == 200 || response.statusCode == 204;
  }
}
