import '../../../../core/constants/ApiEndpoints.dart';
import '../../../../core/network/DioClient.dart';
import '../models/catalog_promotion_model.dart';
import '../models/promotion_model.dart';

abstract class PromotionRemoteDataSource {
  Future<PromotionModel> applyPromotion({
    required String promotionCode,
    required double subtotal,
  });

  /// Lấy danh sách promotion đang active và trong kỹ hiệu lực.
  Future<List<CatalogPromotionModel>> getActivePromotions();
}

class PromotionRemoteDataSourceImpl implements PromotionRemoteDataSource {
  final DioClient dioClient;

  PromotionRemoteDataSourceImpl({required this.dioClient});

  @override
  Future<PromotionModel> applyPromotion({
    required String promotionCode,
    required double subtotal,
  }) async {
    final response = await dioClient.dio.post(
      ApiEndpoints.applyPromotion,
      data: {
        'promotionCode': promotionCode,
        'subtotal': subtotal,
      },
    );

    if (response.data != null && response.data['success'] == true) {
      return PromotionModel.fromJson(response.data['data']);
    } else {
      throw Exception(
          response.data?['message'] ?? 'Mã khuyến mãi không hợp lệ');
    }
  }

  @override
  Future<List<CatalogPromotionModel>> getActivePromotions() async {
    final response = await dioClient.dio.get(ApiEndpoints.promotions);

    if (response.data != null && response.data['success'] == true) {
      final List<dynamic> data = response.data['data'] ?? [];
      final now = DateTime.now();
      return data
          .map((e) => CatalogPromotionModel.fromJson(e))
          .where((p) =>
              p.isActive &&
              now.isAfter(p.startDate) &&
              now.isBefore(p.endDate))
          .toList();
    } else {
      return [];
    }
  }
}
