import 'dart:typed_data';
import 'package:dio/dio.dart';
import '../../../../core/constants/ApiEndpoints.dart';
import '../../../../core/network/DioClient.dart';
import '../../domain/entities/report_filter.dart';
import '../models/revenue_summary_model.dart';
import '../models/top_selling_model.dart';

abstract class ReportRemoteDataSource {
  Future<RevenueSummaryModel> getRevenueSummary(ReportFilter filter);
  Future<List<TopSellingModel>> getTopSelling(ReportFilter filter,
      {int limit = 10});
  Future<Uint8List> exportToExcel(ReportFilter filter);
}

class ReportRemoteDataSourceImpl implements ReportRemoteDataSource {
  final DioClient dioClient;

  ReportRemoteDataSourceImpl({required this.dioClient});

  @override
  Future<RevenueSummaryModel> getRevenueSummary(ReportFilter filter) async {
    final response = await dioClient.dio.get(
      ApiEndpoints.reportsRevenue,
      queryParameters: filter.toQuery(),
    );
    if (response.data != null && response.data['success'] == true) {
      return RevenueSummaryModel.fromJson(
          response.data['data'] as Map<String, dynamic>);
    }
    throw Exception(response.data?['message'] ?? 'Không thể tải báo cáo doanh thu');
  }

  @override
  Future<List<TopSellingModel>> getTopSelling(ReportFilter filter,
      {int limit = 10}) async {
    final response = await dioClient.dio.get(
      ApiEndpoints.reportsTopSelling,
      queryParameters: {...filter.toQuery(), 'limit': limit},
    );
    if (response.data != null && response.data['success'] == true) {
      return (response.data['data'] as List)
          .map((e) => TopSellingModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception(response.data?['message'] ?? 'Không thể tải top bán chạy');
  }

  @override
  Future<Uint8List> exportToExcel(ReportFilter filter) async {
    final response = await dioClient.dio.get<List<int>>(
      ApiEndpoints.reportsExport,
      queryParameters: filter.toQuery(),
      options: Options(responseType: ResponseType.bytes),
    );
    final data = response.data;
    if (data == null || data.isEmpty) {
      throw Exception('Không thể xuất báo cáo');
    }
    return Uint8List.fromList(data);
  }
}
