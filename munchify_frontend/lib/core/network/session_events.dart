import 'dart:async';

/// Phát sự kiện khi server trả 401 (token hết hạn / không hợp lệ) hoặc 403.
/// AuthGate lắng nghe để đưa người dùng về màn hình đăng nhập.
class SessionEvents {
  SessionEvents._();

  static final StreamController<void> _unauthorized =
      StreamController<void>.broadcast();
  static final StreamController<void> _forbidden =
      StreamController<void>.broadcast();

  static Stream<void> get onUnauthorized => _unauthorized.stream;
  static Stream<void> get onForbidden => _forbidden.stream;

  static void notifyUnauthorized() => _unauthorized.add(null);
  static void notifyForbidden() => _forbidden.add(null);
}
