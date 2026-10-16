import '../../../../core/network/DioClient.dart';
import '../../../../core/constants/ApiEndpoints.dart';
import '../models/promotion_model.dart';

abstract class PromotionRemoteDataSource {
  Future<Map<String, dynamic>> getPromotions(int pageIndex, int pageSize, String? searchKeyword);
  Future<PromotionDetailModel> getPromotionById(String id);
  Future<PromotionDetailModel> createPromotion(Map<String, dynamic> data);
  Future<PromotionDetailModel> updatePromotion(String id, Map<String, dynamic> data);
  Future<bool> togglePromotionStatus(String id);
}

class PromotionRemoteDataSourceImpl implements PromotionRemoteDataSource {
  final DioClient dioClient;

  PromotionRemoteDataSourceImpl({required this.dioClient});

  @override
  Future<Map<String, dynamic>> getPromotions(int pageIndex, int pageSize, String? searchKeyword) async {
    final response = await dioClient.dio.get(
      ApiEndpoints.promotions,
      queryParameters: {
        'pageIndex': pageIndex,
        'pageSize': pageSize,
        if (searchKeyword != null && searchKeyword.isNotEmpty) 'searchKeyword': searchKeyword,
      },
    );
    if (response.data['success'] == true) {
      return response.data['data'];
    } else {
      throw Exception(response.data['message'] ?? 'Lỗi khi tải danh sách khuyến mãi');
    }
  }

  @override
  Future<PromotionDetailModel> getPromotionById(String id) async {
    final response = await dioClient.dio.get('${ApiEndpoints.promotions}/$id');
    if (response.data['success'] == true) {
      return PromotionDetailModel.fromJson(response.data['data']);
    } else {
      throw Exception(response.data['message'] ?? 'Không thể tìm thấy khuyến mãi');
    }
  }

  @override
  Future<PromotionDetailModel> createPromotion(Map<String, dynamic> data) async {
    final response = await dioClient.dio.post(ApiEndpoints.promotions, data: data);
    if (response.data['success'] == true) {
      return PromotionDetailModel.fromJson(response.data['data']);
    } else {
      throw Exception(response.data['message'] ?? 'Không thể tạo khuyến mãi');
    }
  }

  @override
  Future<PromotionDetailModel> updatePromotion(String id, Map<String, dynamic> data) async {
    final response = await dioClient.dio.put('${ApiEndpoints.promotions}/$id', data: data);
    if (response.data['success'] == true) {
      return PromotionDetailModel.fromJson(response.data['data']);
    } else {
      throw Exception(response.data['message'] ?? 'Không thể cập nhật khuyến mãi');
    }
  }

  @override
  Future<bool> togglePromotionStatus(String id) async {
    final response = await dioClient.dio.patch('${ApiEndpoints.promotions}/$id/status');
    if (response.data['success'] == true) {
      return true;
    } else {
      throw Exception(response.data['message'] ?? 'Không thể thay đổi trạng thái khuyến mãi');
    }
  }
}
