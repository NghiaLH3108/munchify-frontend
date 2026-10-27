import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../features/auth/data/datasources/auth_local_data_source.dart';
import '../constants/StorageKeys.dart';
import 'session_events.dart';

// ─── Auth Interceptor ────────────────────────────────────────────────────────

/// Attaches the JWT Bearer token to every outgoing request.
///
/// On 401 responses it wipes all stored credentials so the app can redirect
/// the user back to the Login screen. The [AuthBloc] listens for this event
/// via a stream and triggers the navigation side-effect.
class AuthInterceptor extends Interceptor {
  final FlutterSecureStorage secureStorage;

  const AuthInterceptor({required this.secureStorage});

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    String? token;
    try {
      token = await secureStorage.read(key: StorageKeys.accessToken);
    } catch (_) {
      token = AuthLocalDataSourceImpl.cachedAccessToken;
      try {
        await secureStorage.deleteAll();
      } catch (_) {}
    }
    token ??= AuthLocalDataSourceImpl.cachedAccessToken;
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    return handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401) {
      AuthLocalDataSourceImpl.cachedAccessToken = null;
      try {
        await secureStorage.delete(key: StorageKeys.accessToken);
      } catch (_) {}
      try {
        await secureStorage.delete(key: StorageKeys.refreshToken);
      } catch (_) {}
      try {
        await secureStorage.delete(key: StorageKeys.userRole);
      } catch (_) {}
      try {
        await secureStorage.delete(key: StorageKeys.userId);
      } catch (_) {}
      try {
        await secureStorage.delete(key: StorageKeys.userName);
      } catch (_) {}
      // Không phát sự kiện nếu lỗi đến từ chính request đăng nhập
      if (!err.requestOptions.path.contains('/auth/login')) {
        SessionEvents.notifyUnauthorized();
      }
    } else if (err.response?.statusCode == 403) {
      SessionEvents.notifyForbidden();
    }
    return handler.next(err);
  }
}

// ─── Logging Interceptor ─────────────────────────────────────────────────────

/// Prints request/response details to the console in debug builds only.
/// Automatically stripped from release builds via `assert`.
class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    assert(() {
      // ignore: avoid_print
      print('[Munchify] --> ${options.method} ${options.uri}');
      if (options.data != null) {
        // ignore: avoid_print
        print('[Munchify] Body: ${options.data}');
      }
      return true;
    }());
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    assert(() {
      // ignore: avoid_print
      print(
        '[Munchify] <-- ${response.statusCode} ${response.requestOptions.uri}',
      );
      return true;
    }());
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    assert(() {
      // ignore: avoid_print
      print(
        '[Munchify] ERROR ${err.response?.statusCode}: '
        '${err.requestOptions.uri} — ${err.message}',
      );
      return true;
    }());
    handler.next(err);
  }
}
