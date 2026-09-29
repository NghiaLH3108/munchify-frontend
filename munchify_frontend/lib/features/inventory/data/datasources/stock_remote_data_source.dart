import 'package:dio/dio.dart';
import 'package:munchify_frontend/core/network/DioClient.dart';
import '../../../../core/constants/ApiEndpoints.dart';
import '../models/stock_import_model.dart';

abstract class StockRemoteDataSource {
  Future<List<StockImportModel>> getStockImports();
  Future<StockImportModel> getStockImportById(int id);
  Future<int> createDraftImport(int supplierId, String? notes, List<Map<String, dynamic>> items);
  Future<bool> completeImport(int id);
  Future<bool> cancelImport(int id);
}

class StockRemoteDataSourceImpl implements StockRemoteDataSource {
  final DioClient dio; 

  StockRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<StockImportModel>> getStockImports() async {
    final response = await dio.dio.get(ApiEndpoints.stockImports);
    final data = response.data['data'] as List;
    return data.map((json) => StockImportModel.fromJson(json)).toList();
  }

  @override
  Future<StockImportModel> getStockImportById(int id) async {
    final response = await dio.dio.get('${ApiEndpoints.stockImports}/$id');
    return StockImportModel.fromJson(response.data['data']);
  }

  @override
  Future<int> createDraftImport(int supplierId, String? notes, List<Map<String, dynamic>> items) async {
    final response = await dio.dio.post(ApiEndpoints.stockImports, data: {
      'supplierId': supplierId,
      'notes': notes,
      'items': items,
    });
    return response.data['data'] as int;
  }

  @override
  Future<bool> completeImport(int id) async {
    final response = await dio.dio.put('${ApiEndpoints.stockImports}/$id/complete');
    return response.data['data'] as bool;
  }

  @override
  Future<bool> cancelImport(int id) async {
    final response = await dio.dio.delete('${ApiEndpoints.stockImports}/$id');
    return response.data['data'] as bool;
  }
}

