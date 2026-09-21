import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../constants/StorageKeys.dart';

// ─── Auth Interceptor ────────────────────────────────────────────────────────

/// Attaches the JWT Bearer token to every outgoing request.
///
/// On 401 responses it wipes all stored credentials so the app can redirect
/// the user back to the Login screen. The [AuthBloc] listens for this event
/// via a stream and triggers the navigation side-effect.
class AuthInterceptor extends Interceptor {
  final FlutterSecureStorage _secureStorage;

  const AuthInterceptor({required FlutterSecureStorage secureStorage})
      : _secureStorage = secureStorage;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _secureStorage.read(key: StorageKeys.accessToken);
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
      // Session expired — purge all authentication data.
      await Future.wait([
        _secureStorage.delete(key: StorageKeys.accessToken),
        _secureStorage.delete(key: StorageKeys.refreshToken),
        _secureStorage.delete(key: StorageKeys.userRole),
        _secureStorage.delete(key: StorageKeys.userId),
        _secureStorage.delete(key: StorageKeys.userName),
      ]);
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
