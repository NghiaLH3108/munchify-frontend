import 'package:flutter/foundation.dart';

/// Xác định luồng đăng nhập theo nền tảng chạy:
/// - Web / Windows / macOS / Linux  -> giao diện Admin
/// - Android / iOS (app)            -> giao diện Staff
class PlatformHelper {
  PlatformHelper._();

  static bool get isStaffPlatform {
    if (kIsWeb) return false;
    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
  }

  static bool get isAdminPlatform => !isStaffPlatform;
}
