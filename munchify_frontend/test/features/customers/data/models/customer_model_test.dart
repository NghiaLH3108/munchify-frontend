import 'package:flutter_test/flutter_test.dart';
import 'package:munchify_frontend/features/customers/data/models/customer_model.dart';
import 'package:munchify_frontend/features/customers/domain/entities/customer_entity.dart';

void main() {
  final tCustomerModel = CustomerModel(
    customerId: 1,
    customerName: 'Nguyen Van A',
    phone: '0912345678',
    loyaltyPoints: 10,
    createdAt: DateTime.parse('2026-01-01T00:00:00Z'),
  );

  test('should be a subclass of CustomerEntity', () async {
    // assert
    expect(tCustomerModel, isA<CustomerEntity>());
  });

  group('fromJson', () {
    test('should return a valid model when JSON is provided', () async {
      // arrange
      final Map<String, dynamic> jsonMap = {
        'customerId': 1,
        'customerName': 'Nguyen Van A',
        'phone': '0912345678',
        'loyaltyPoints': 10,
        'createdAt': '2026-01-01T00:00:00.000Z',
      };
      // act
      final result = CustomerModel.fromJson(jsonMap);
      // assert
      expect(result, tCustomerModel);
    });
  });

  group('toJson', () {
    test('should return a JSON map containing proper data', () async {
      // act
      final result = tCustomerModel.toJson();
      // assert
      final expectedMap = {
        'customerId': 1,
        'customerName': 'Nguyen Van A',
        'phone': '0912345678',
        'loyaltyPoints': 10,
        'createdAt': '2026-01-01T00:00:00.000Z',
      };
      expect(result, expectedMap);
    });
  });
}
