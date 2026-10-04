
import '../../../../core/constants/ApiEndpoints.dart';
import '../models/stock_import_model.dart';
import '../models/damaged_expired_record_model.dart';
import 'package:munchify_frontend/core/network/DioClient.dart';



import '../models/ai_expiry_summary_model.dart';

abstract class StockRemoteDataSource {
  Future<List<StockImportModel>> getStockImports();
  Future<StockImportModel> getStockImportById(int id);
  Future<int> createDraftImport(int supplierId, String? notes, List<Map<String, dynamic>> items);
  Future<bool> completeImport(int id);
  Future<bool> cancelImport(int id);
  
  // AI Expiry Insights
  Future<List<DamagedExpiredRecordModel>> getPendingDamagedExpiredRecords();
  Future<AiExpirySummaryModel> getAiExpirySummaryMetrics();
  Future<bool> approveDamagedExpiredRecord(int id);
}

class StockRemoteDataSourceImpl implements StockRemoteDataSource {
  final DioClient dioClient;

  StockRemoteDataSourceImpl({required this.dioClient});

  @override
  Future<List<StockImportModel>> getStockImports() async {
    final response = await dioClient.dio.get(ApiEndpoints.stockImports);
    final data = response.data['data'] as List;
    return data.map((json) => StockImportModel.fromJson(json)).toList();
  }

  @override
  Future<StockImportModel> getStockImportById(int id) async {
    final response = await dioClient.dio.get('${ApiEndpoints.stockImports}/$id');
    return StockImportModel.fromJson(response.data['data']);
  }

  @override
  Future<int> createDraftImport(int supplierId, String? notes, List<Map<String, dynamic>> items) async {
    final response = await dioClient.dio.post(ApiEndpoints.stockImports, data: {
      'supplierId': supplierId,
      'notes': notes,
      'items': items,
    });
    return response.data['data'] as int;
  }

  @override
  Future<bool> completeImport(int id) async {
    final response = await dioClient.dio.put('${ApiEndpoints.stockImports}/$id/complete');
    return response.data['data'] as bool;
  }

  @override
  Future<bool> cancelImport(int id) async {
    final response = await dioClient.dio.delete('${ApiEndpoints.stockImports}/$id');
    return response.data['data'] as bool;
  }

  @override
  Future<List<DamagedExpiredRecordModel>> getPendingDamagedExpiredRecords() async {
    final response = await dioClient.dio.get(ApiEndpoints.damagedExpiredPending());
    final data = response.data['data'] as List;
    return data.map((json) => DamagedExpiredRecordModel.fromJson(json)).toList();
  }

  @override
  Future<AiExpirySummaryModel> getAiExpirySummaryMetrics() async {
    final response = await dioClient.dio.get(ApiEndpoints.damagedExpiredSummaryMetrics());
    return AiExpirySummaryModel.fromJson(response.data['data']);
  }

  @override
  Future<bool> approveDamagedExpiredRecord(int id) async {
    final response = await dioClient.dio.put(ApiEndpoints.damagedExpiredApprove(id));
    return response.data['data'] as bool;
  }
}
