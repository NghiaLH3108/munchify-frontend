import '../../../../core/network/DioClient.dart';
import '../../../../core/constants/ApiEndpoints.dart';
import '../models/unit_model.dart';

abstract class UnitRemoteDataSource {
  Future<List<UnitModel>> getUnits({
    String searchTerm = '',
    bool? isActive,
    int page = 1,
    int pageSize = 10,
  });
  Future<UnitModel> getUnitById(int id);
  Future<UnitModel> createUnit({
    required String unitName,
    String? description,
    bool isActive = true,
  });
  Future<UnitModel> updateUnit({
    required int id,
    required String unitName,
    String? description,
    required bool isActive,
  });
  Future<bool> deleteUnit(int id);
}

class UnitRemoteDataSourceImpl implements UnitRemoteDataSource {
  final DioClient dioClient;

  UnitRemoteDataSourceImpl({required this.dioClient});

  @override
  Future<List<UnitModel>> getUnits({
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
      ApiEndpoints.units,
      queryParameters: queryParameters,
    );

    if (response.data != null && response.data['success'] == true) {
      final items = response.data['data']['items'] as List;
      return items.map((e) => UnitModel.fromJson(e)).toList();
    } else {
      throw Exception(response.data?['message'] ?? 'Failed to fetch units');
    }
  }

  @override
  Future<UnitModel> getUnitById(int id) async {
    final response = await dioClient.dio.get('${ApiEndpoints.units}/$id');
    if (response.data != null && response.data['success'] == true) {
      return UnitModel.fromJson(response.data['data']);
    } else {
      throw Exception(response.data?['message'] ?? 'Failed to fetch unit');
    }
  }

  @override
  Future<UnitModel> createUnit({
    required String unitName,
    String? description,
    bool isActive = true,
  }) async {
    final response = await dioClient.dio.post(
      ApiEndpoints.units,
      data: {
        'unitName': unitName,
        'description': description,
        'isActive': isActive,
      },
    );
    if (response.data != null && response.data['success'] == true) {
      return UnitModel.fromJson(response.data['data']);
    } else {
      throw Exception(response.data?['message'] ?? 'Failed to create unit');
    }
  }

  @override
  Future<UnitModel> updateUnit({
    required int id,
    required String unitName,
    String? description,
    required bool isActive,
  }) async {
    final response = await dioClient.dio.put(
      '${ApiEndpoints.units}/$id',
      data: {
        'unitName': unitName,
        'description': description,
        'isActive': isActive,
      },
    );
    if (response.data != null && response.data['success'] == true) {
      return UnitModel.fromJson(response.data['data']);
    } else {
      throw Exception(response.data?['message'] ?? 'Failed to update unit');
    }
  }

  @override
  Future<bool> deleteUnit(int id) async {
    final response =
        await dioClient.dio.delete('${ApiEndpoints.units}/$id');
    if (response.data != null && response.data['success'] == true) {
      return true;
    } else {
      throw Exception(response.data?['message'] ?? 'Failed to delete unit');
    }
  }
}
