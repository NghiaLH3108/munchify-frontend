/// Form field and business-rule validators for Munchify POS.
///
/// Every method follows the Flutter [FormField.validator] signature:
///   `String? Function(String? value)`
///
/// Returns `null` when the value is **valid**, or a Vietnamese error string.
///
/// Usage with [TextFormField]:
/// ```dart
/// TextFormField(validator: Validators.validatePhoneNumber)
/// ```
class Validators {
  Validators._();

  // ─── Auth ─────────────────────────────────────────────────────────────────

  /// Validates a non-empty username of at least 3 characters.
  static String? validateUsername(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Vui lòng nhập tên đăng nhập';
    }
    if (value.trim().length < 3) {
      return 'Tên đăng nhập phải có ít nhất 3 ký tự';
    }
    return null;
  }

  /// Validates a non-empty password of at least 6 characters.
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập mật khẩu';
    }
    if (value.length < 6) {
      return 'Mật khẩu phải có ít nhất 6 ký tự';
    }
    return null;
  }

  // ─── Contact ──────────────────────────────────────────────────────────────

  /// Validates Vietnamese mobile phone numbers (10 digits, starting with 03/05/07/08/09).
  static String? validatePhoneNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Vui lòng nhập số điện thoại';
    }
    final regex = RegExp(r'^(0[3|5|7|8|9])[0-9]{8}$');
    if (!regex.hasMatch(value.trim())) {
      return 'Số điện thoại không hợp lệ (VD: 0912.345.678)';
    }
    return null;
  }

  /// Optional email validator — returns `null` when [value] is empty (field is optional).
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final regex = RegExp(r'^[\w\-.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!regex.hasMatch(value.trim())) {
      return 'Địa chỉ email không hợp lệ';
    }
    return null;
  }

  // ─── Generic ──────────────────────────────────────────────────────────────

  /// Ensures the field is not blank. [fieldName] appears in the error message.
  static String? validateRequired(
    String? value, {
    String fieldName = 'Trường này',
  }) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName không được để trống';
    }
    return null;
  }

  // ─── Numeric ──────────────────────────────────────────────────────────────

  /// Validates that [value] is a positive number (> 0). Used for prices and import quantities.
  static String? validatePositiveNumber(
    String? value, {
    String fieldName = 'Giá trị',
  }) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName không được để trống';
    }
    final number = double.tryParse(value.trim().replaceAll(',', ''));
    if (number == null) return '$fieldName phải là số hợp lệ';
    if (number <= 0) return '$fieldName phải lớn hơn 0';
    return null;
  }

  /// Validates that [value] is a non-negative integer (>= 0). Used for stock quantities.
  static String? validateNonNegativeInt(
    String? value, {
    String fieldName = 'Số lượng',
  }) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName không được để trống';
    }
    final number = int.tryParse(value.trim());
    if (number == null) return '$fieldName phải là số nguyên';
    if (number < 0) return '$fieldName không được âm';
    return null;
  }

  /// Validates a stock adjustment delta — can be negative (write-off) or positive (addition).
  static String? validateAdjustmentDelta(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Số lượng điều chỉnh không được để trống';
    }
    final number = int.tryParse(value.trim());
    if (number == null) return 'Số lượng điều chỉnh phải là số nguyên';
    if (number == 0) return 'Số lượng điều chỉnh không được bằng 0';
    return null;
  }

  // ─── Business Rules ───────────────────────────────────────────────────────

  /// Validates cash tendered — must be >= [orderTotal].
  static String? validateCashTendered(String? value, {required double orderTotal}) {
    if (value == null || value.trim().isEmpty) {
      return 'Vui lòng nhập số tiền khách đưa';
    }
    final tendered = double.tryParse(
      value.trim().replaceAll('.', '').replaceAll(',', ''),
    );
    if (tendered == null) return 'Số tiền không hợp lệ';
    if (tendered < orderTotal) {
      return 'Số tiền khách đưa phải lớn hơn hoặc bằng tổng tiền cần thanh toán';
    }
    return null;
  }
}
