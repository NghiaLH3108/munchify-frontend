import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:munchify_frontend/core/constants/AppConstants.dart';

void main() {
  group('Loyalty Points Rate and Specification Compliance', () {
    test('Exchange rate must be strictly 1 point = 100 VND (10 points = 1,000 VND)', () {
      expect(AppConstants.pointsToVndRate, equals(100));
    });

    test('10 points must yield exactly 1,000 VND discount', () {
      const points = 10;
      final discount = points * AppConstants.pointsToVndRate;
      expect(discount, equals(1000));
    });

    test('100 points must yield exactly 10,000 VND discount', () {
      const points = 100;
      final discount = points * AppConstants.pointsToVndRate;
      expect(discount, equals(10000));
    });

    test('Earning rate must be strictly 10,000 VND spent = 1 point earned', () {
      expect(AppConstants.vndPerPointEarned, equals(10000));
    });
  });

  group('Voucher Deducted FIRST, Loyalty Points Deducted AFTER (Devil\'s Advocate Grill)', () {
    /// Calculation engine matching OrderService.cs & checkout_screen.dart:
    ({
      double amountAfterVoucher,
      int maxPointsNeeded,
      int actualPointsRedeemed,
      double pointsDiscountAmount,
      double finalTotal,
      int pointsEarned,
    }) calculateOrder({
      required double subtotal,
      required double voucherDiscount,
      required int pointsToRedeem,
      bool hasCustomer = true,
    }) {
      final amountAfterVoucher = max(0.0, subtotal - voucherDiscount);
      final maxPointsNeeded = (amountAfterVoucher / AppConstants.pointsToVndRate).ceil();
      final actualPointsRedeemed = max(0, min(pointsToRedeem, maxPointsNeeded));
      final pointsDiscountAmount = actualPointsRedeemed * AppConstants.pointsToVndRate.toDouble();
      final finalTotal = max(0.0, amountAfterVoucher - pointsDiscountAmount);
      final pointsEarned = hasCustomer ? (finalTotal / AppConstants.vndPerPointEarned).floor() : 0;

      return (
        amountAfterVoucher: amountAfterVoucher,
        maxPointsNeeded: maxPointsNeeded,
        actualPointsRedeemed: actualPointsRedeemed,
        pointsDiscountAmount: pointsDiscountAmount,
        finalTotal: finalTotal,
        pointsEarned: pointsEarned,
      );
    }

    test('Edge Case 1: Over-redemption protection when voucher covers majority of bill', () {
      // Subtotal: 100,000đ. Voucher: 80,000đ.
      // Customer balance / requested: 500 points (value: 50,000đ).
      // Voucher MUST be applied first -> Remaining: 20,000đ.
      // Max points needed: 20,000 / 100 = 200 points.
      // Points redeemed MUST be clamped to 200, protecting remaining 300 points from being swallowed.
      final result = calculateOrder(
        subtotal: 100000,
        voucherDiscount: 80000,
        pointsToRedeem: 500,
      );

      expect(result.amountAfterVoucher, equals(20000.0));
      expect(result.maxPointsNeeded, equals(200));
      expect(result.actualPointsRedeemed, equals(200));
      expect(result.pointsDiscountAmount, equals(20000.0));
      expect(result.finalTotal, equals(0.0));
      expect(result.pointsEarned, equals(0));
    });

    test('Edge Case 2: 100% Voucher coverage must redeem 0 points', () {
      // Subtotal: 150,000đ. Voucher: 150,000đ.
      // Customer requests 1,000 points.
      // Remaining after voucher is 0đ -> Points redeemed MUST be 0.
      final result = calculateOrder(
        subtotal: 150000,
        voucherDiscount: 150000,
        pointsToRedeem: 1000,
      );

      expect(result.amountAfterVoucher, equals(0.0));
      expect(result.maxPointsNeeded, equals(0));
      expect(result.actualPointsRedeemed, equals(0));
      expect(result.pointsDiscountAmount, equals(0.0));
      expect(result.finalTotal, equals(0.0));
      expect(result.pointsEarned, equals(0));
    });

    test('Edge Case 3: Voucher exceeds Subtotal (Over-discount)', () {
      // Subtotal: 50,000đ. Voucher: 70,000đ.
      // Customer requests 100 points.
      // Remaining is clamped to 0 -> Points redeemed MUST be 0.
      final result = calculateOrder(
        subtotal: 50000,
        voucherDiscount: 70000,
        pointsToRedeem: 100,
      );

      expect(result.amountAfterVoucher, equals(0.0));
      expect(result.maxPointsNeeded, equals(0));
      expect(result.actualPointsRedeemed, equals(0));
      expect(result.finalTotal, equals(0.0));
      expect(result.pointsEarned, equals(0));
    });

    test('Edge Case 4: Ceiling rounding protects order payment from negative cents', () {
      // Remaining amount: 1,050đ.
      // 1,050 / 100 = 10.5 -> ceil is 11 points (1,100đ discount).
      // Final total clamped to 0đ.
      final result = calculateOrder(
        subtotal: 11050,
        voucherDiscount: 10000,
        pointsToRedeem: 50,
      );

      expect(result.amountAfterVoucher, equals(1050.0));
      expect(result.maxPointsNeeded, equals(11));
      expect(result.actualPointsRedeemed, equals(11));
      expect(result.pointsDiscountAmount, equals(1100.0));
      expect(result.finalTotal, equals(0.0));
      expect(result.pointsEarned, equals(0));
    });

    test('Edge Case 5: Partial Voucher and Partial Points', () {
      // Subtotal: 250,000đ. Voucher: 50,000đ.
      // Customer redeems 400 points (value: 40,000đ).
      // Amount after voucher: 200,000đ.
      // Points discount: 40,000đ.
      // Final Total: 160,000đ.
      // Points Earned: 160,000 / 10,000 = 16 points.
      final result = calculateOrder(
        subtotal: 250000,
        voucherDiscount: 50000,
        pointsToRedeem: 400,
      );

      expect(result.amountAfterVoucher, equals(200000.0));
      expect(result.maxPointsNeeded, equals(2000));
      expect(result.actualPointsRedeemed, equals(400));
      expect(result.pointsDiscountAmount, equals(40000.0));
      expect(result.finalTotal, equals(160000.0));
      expect(result.pointsEarned, equals(16));
    });

    test('Edge Case 6: No Voucher, Points redemption only', () {
      // Subtotal: 80,000đ. Voucher: 0đ.
      // Customer redeems 300 points (value: 30,000đ).
      // Final total: 50,000đ.
      // Points Earned: 50,000 / 10,000 = 5 points.
      final result = calculateOrder(
        subtotal: 80000,
        voucherDiscount: 0,
        pointsToRedeem: 300,
      );

      expect(result.amountAfterVoucher, equals(80000.0));
      expect(result.actualPointsRedeemed, equals(300));
      expect(result.pointsDiscountAmount, equals(30000.0));
      expect(result.finalTotal, equals(50000.0));
      expect(result.pointsEarned, equals(5));
    });

    test('Edge Case 7: Points Earned calculation threshold with 10k VND per point', () {
      // Final total: 300,000đ -> 30 points.
      final res1 = calculateOrder(subtotal: 300000, voucherDiscount: 0, pointsToRedeem: 0);
      expect(res1.pointsEarned, equals(30));

      // Final total: 9,999đ -> 0 points.
      final res2 = calculateOrder(subtotal: 9999, voucherDiscount: 0, pointsToRedeem: 0);
      expect(res2.pointsEarned, equals(0));
    });
  });

  group('Loyalty Points Earning Rate - 10,000 VND = 1 Point (Devil\'s Advocate Grill)', () {
    ({
      double finalTotal,
      int pointsEarned,
    }) calculatePointsEarned({
      required double totalAmount,
      bool hasCustomer = true,
    }) {
      final pointsEarned = hasCustomer ? (totalAmount / AppConstants.vndPerPointEarned).floor() : 0;
      return (
        finalTotal: totalAmount,
        pointsEarned: pointsEarned,
      );
    }

    test('Purchase exactly 10,000 VND must earn exactly 1 point', () {
      final res = calculatePointsEarned(totalAmount: 10000);
      expect(res.pointsEarned, equals(1));
    });

    test('Purchase 25,000 VND must earn exactly 2 points (floor rounding)', () {
      final res = calculatePointsEarned(totalAmount: 25000);
      expect(res.pointsEarned, equals(2));
    });

    test('Purchase 9,999 VND must earn 0 points (below threshold)', () {
      final res = calculatePointsEarned(totalAmount: 9999);
      expect(res.pointsEarned, equals(0));
    });

    test('Purchase 19,999 VND must earn exactly 1 point (floor rounding)', () {
      final res = calculatePointsEarned(totalAmount: 19999);
      expect(res.pointsEarned, equals(1));
    });

    test('0 VND order (100% discount) must earn 0 points', () {
      final res = calculatePointsEarned(totalAmount: 0);
      expect(res.pointsEarned, equals(0));
    });

    test('Guest customer (customer == null / hasCustomer == false) must earn 0 points even with large order', () {
      final res1 = calculatePointsEarned(totalAmount: 100000, hasCustomer: false);
      expect(res1.pointsEarned, equals(0));

      final res2 = calculatePointsEarned(totalAmount: 5000000, hasCustomer: false);
      expect(res2.pointsEarned, equals(0));
    });

    test('Member customer (hasCustomer == true) earns points proportional to 10k VND rate', () {
      final res100k = calculatePointsEarned(totalAmount: 100000, hasCustomer: true);
      expect(res100k.pointsEarned, equals(10));

      final res1m = calculatePointsEarned(totalAmount: 1000000, hasCustomer: true);
      expect(res1m.pointsEarned, equals(100));
    });
  });
}
