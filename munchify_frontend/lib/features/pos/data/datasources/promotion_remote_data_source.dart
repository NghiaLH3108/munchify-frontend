import '../../../../core/constants/ApiEndpoints.dart';
import '../../../../core/network/DioClient.dart';
import '../models/promotion_model.dart';

abstract class PromotionRemoteDataSource {
  Future<PromotionModel> applyPromotion({
    required String promotionCode,
    required double subtotal,
  });
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
}
