import 'package:flutter_test/flutter_test.dart';
import 'package:munchify_frontend/features/promotions/data/models/promotion_model.dart';
import 'package:munchify_frontend/features/promotions/domain/entities/promotion_entity.dart';

void main() {
  final tStartDate = DateTime(2026, 10, 1);
  final tEndDate = DateTime(2026, 10, 31);

  final tPromotionModel = PromotionModel(
    promotionId: 1,
    promotionCode: 'SUMMER2026',
    promotionName: 'Khuyến mãi mùa hè',
    description: 'Giảm giá 15% cho tất cả món',
    discountType: 'PERCENTAGE',
    discountValue: 15.0,
    minimumOrderAmount: 100000.0,
    startDate: tStartDate,
    endDate: tEndDate,
    isActive: true,
  );

  final tPromotionDetailModel = PromotionDetailModel(
    promotionId: 1,
    promotionCode: 'SUMMER2026',
    promotionName: 'Khuyến mãi mùa hè',
    description: 'Giảm giá 15% cho tất cả món',
    discountType: 'PERCENTAGE',
    discountValue: 15.0,
    minimumOrderAmount: 100000.0,
    startDate: tStartDate,
    endDate: tEndDate,
    isActive: true,
    products: const [
      {'productId': 1, 'productName': 'Bánh tráng cuốn'}
    ],
  );

  group('PromotionModel', () {
    test('should be a subclass of PromotionEntity', () {
      expect(tPromotionModel, isA<PromotionEntity>());
    });

    test('fromJson should return a valid PromotionModel', () {
      final jsonMap = {
        'promotionId': 1,
        'promotionCode': 'SUMMER2026',
        'promotionName': 'Khuyến mãi mùa hè',
        'description': 'Giảm giá 15% cho tất cả món',
        'discountType': 'PERCENTAGE',
        'discountValue': 15,
        'minimumOrderAmount': 100000,
        'startDate': tStartDate.toIso8601String(),
        'endDate': tEndDate.toIso8601String(),
        'isActive': true,
      };

      final result = PromotionModel.fromJson(jsonMap);
      expect(result.promotionId, 1);
      expect(result.promotionCode, 'SUMMER2026');
      expect(result.discountType, 'PERCENTAGE');
      expect(result.discountValue, 15.0);
    });

    test('toJson should return correct JSON map', () {
      final jsonMap = tPromotionModel.toJson();
      expect(jsonMap['promotionId'], 1);
      expect(jsonMap['promotionCode'], 'SUMMER2026');
      expect(jsonMap['discountValue'], 15.0);
      expect(jsonMap['isActive'], true);
    });
  });

  group('PromotionDetailModel', () {
    test('should be a subclass of PromotionDetailEntity', () {
      expect(tPromotionDetailModel, isA<PromotionDetailEntity>());
    });

    test('fromJson should return a valid PromotionDetailModel', () {
      final jsonMap = {
        'promotionId': 1,
        'promotionCode': 'SUMMER2026',
        'promotionName': 'Khuyến mãi mùa hè',
        'description': 'Giảm giá 15% cho tất cả món',
        'discountType': 'PERCENTAGE',
        'discountValue': 15.0,
        'minimumOrderAmount': 100000.0,
        'startDate': tStartDate.toIso8601String(),
        'endDate': tEndDate.toIso8601String(),
        'isActive': true,
        'products': [
          {'productId': 1, 'productName': 'Bánh tráng cuốn'}
        ],
      };

      final result = PromotionDetailModel.fromJson(jsonMap);
      expect(result.products.length, 1);
      expect(result.promotionName, 'Khuyến mãi mùa hè');
    });

    test('toJson should return correct JSON map', () {
      final jsonMap = tPromotionDetailModel.toJson();
      expect(jsonMap['promotionId'], 1);
      expect(jsonMap['products'], isA<List>());
    });
  });
}
