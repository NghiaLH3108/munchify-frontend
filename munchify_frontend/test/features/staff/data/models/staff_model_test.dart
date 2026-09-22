import 'package:flutter_test/flutter_test.dart';
import 'package:munchify_frontend/features/staff/data/models/staff_model.dart';
import 'package:munchify_frontend/features/staff/data/models/paged_staff_result.dart';

void main() {
  group('StaffModel', () {
    final staffJson = {
      'userId': 1,
      'username': 'admin_test',
      'fullName': 'Nguyen Van A',
      'phone': '0912345678',
      'email': 'admin@munchify.com',
      'role': 'ADMIN',
      'isActive': true,
      'createdAt': '2026-09-20T10:00:00.000Z',
      'updatedAt': '2026-09-21T10:00:00.000Z',
    };

    test('fromJson creates valid StaffModel instance', () {
      final model = StaffModel.fromJson(staffJson);

      expect(model.userId, 1);
      expect(model.username, 'admin_test');
      expect(model.fullName, 'Nguyen Van A');
      expect(model.phone, '0912345678');
      expect(model.email, 'admin@munchify.com');
      expect(model.role, 'ADMIN');
      expect(model.isActive, isTrue);
      expect(model.createdAt, DateTime.parse('2026-09-20T10:00:00.000Z'));
      expect(model.updatedAt, DateTime.parse('2026-09-21T10:00:00.000Z'));
    });

    test('toJson generates correct Map', () {
      final model = StaffModel.fromJson(staffJson);
      final json = model.toJson();

      expect(json['userId'], 1);
      expect(json['username'], 'admin_test');
      expect(json['role'], 'ADMIN');
      expect(json['isActive'], isTrue);
    });
  });

  group('PagedStaffResult', () {
    final pagedJson = {
      'items': [
        {
          'userId': 1,
          'username': 'staff1',
          'fullName': 'Staff One',
          'phone': '0901234567',
          'email': null,
          'role': 'STAFF',
          'isActive': true,
          'createdAt': '2026-09-20T00:00:00.000Z',
          'updatedAt': '2026-09-20T00:00:00.000Z',
        }
      ],
      'totalCount': 1,
      'page': 1,
      'pageSize': 10,
      'totalPages': 1,
    };

    test('fromJson creates valid PagedStaffResult', () {
      final pagedResult = PagedStaffResult.fromJson(pagedJson);

      expect(pagedResult.totalCount, 1);
      expect(pagedResult.page, 1);
      expect(pagedResult.pageSize, 10);
      expect(pagedResult.totalPages, 1);
      expect(pagedResult.items.length, 1);
      expect(pagedResult.items.first.username, 'staff1');
    });
  });
}
