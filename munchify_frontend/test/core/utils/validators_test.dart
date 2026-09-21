import 'package:flutter_test/flutter_test.dart';
import 'package:munchify_frontend/core/utils/Validators.dart';

void main() {
  group('Validators', () {
    group('validateUsername', () {
      test('returns error when null or empty', () {
        expect(Validators.validateUsername(null), 'Vui lòng nhập tên đăng nhập');
        expect(Validators.validateUsername(''), 'Vui lòng nhập tên đăng nhập');
        expect(Validators.validateUsername('   '), 'Vui lòng nhập tên đăng nhập');
      });

      test('returns error when length < 3', () {
        expect(Validators.validateUsername('ab'), 'Tên đăng nhập phải có ít nhất 3 ký tự');
      });

      test('returns null for valid username', () {
        expect(Validators.validateUsername('admin'), isNull);
        expect(Validators.validateUsername('staff01'), isNull);
      });
    });

    group('validatePassword', () {
      test('returns error when null or empty', () {
        expect(Validators.validatePassword(null), 'Vui lòng nhập mật khẩu');
        expect(Validators.validatePassword(''), 'Vui lòng nhập mật khẩu');
      });

      test('returns error when length < 6', () {
        expect(Validators.validatePassword('12345'), 'Mật khẩu phải có ít nhất 6 ký tự');
      });

      test('returns null for valid password', () {
        expect(Validators.validatePassword('123456'), isNull);
        expect(Validators.validatePassword('Password@123'), isNull);
      });
    });

    group('validatePhoneNumber', () {
      test('returns error when null or empty', () {
        expect(Validators.validatePhoneNumber(null), 'Vui lòng nhập số điện thoại');
        expect(Validators.validatePhoneNumber(''), 'Vui lòng nhập số điện thoại');
      });

      test('returns error for invalid Vietnam phone format', () {
        expect(Validators.validatePhoneNumber('0123456789'), 'Số điện thoại không hợp lệ (VD: 0912.345.678)');
        expect(Validators.validatePhoneNumber('091234567'), 'Số điện thoại không hợp lệ (VD: 0912.345.678)');
        expect(Validators.validatePhoneNumber('091234567899'), 'Số điện thoại không hợp lệ (VD: 0912.345.678)');
        expect(Validators.validatePhoneNumber('abcd'), 'Số điện thoại không hợp lệ (VD: 0912.345.678)');
      });

      test('returns null for valid Vietnam phone numbers', () {
        expect(Validators.validatePhoneNumber('0912345678'), isNull);
        expect(Validators.validatePhoneNumber('0381234567'), isNull);
        expect(Validators.validatePhoneNumber('0861234567'), isNull);
      });
    });

    group('validateEmail', () {
      test('returns null when null or empty because optional', () {
        expect(Validators.validateEmail(null), isNull);
        expect(Validators.validateEmail(''), isNull);
        expect(Validators.validateEmail('   '), isNull);
      });

      test('returns error for invalid email format', () {
        expect(Validators.validateEmail('invalid-email'), 'Địa chỉ email không hợp lệ');
        expect(Validators.validateEmail('test@com'), 'Địa chỉ email không hợp lệ');
      });

      test('returns null for valid email', () {
        expect(Validators.validateEmail('staff@munchify.com'), isNull);
        expect(Validators.validateEmail('huy.cg@gmail.com'), isNull);
      });
    });

    group('validateCashTendered', () {
      test('returns error when empty', () {
        expect(Validators.validateCashTendered(null, orderTotal: 50000), 'Vui lòng nhập số tiền khách đưa');
      });

      test('returns error when amount is less than total', () {
        expect(
          Validators.validateCashTendered('40000', orderTotal: 50000),
          'Số tiền khách đưa phải lớn hơn hoặc bằng tổng tiền cần thanh toán',
        );
      });

      test('returns null when amount is greater than or equal to total', () {
        expect(Validators.validateCashTendered('50000', orderTotal: 50000), isNull);
        expect(Validators.validateCashTendered('100.000', orderTotal: 50000), isNull);
      });
    });
  });
}
