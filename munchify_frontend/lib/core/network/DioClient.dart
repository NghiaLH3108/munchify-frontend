import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../constants/AppConstants.dart';
import 'ApiInterceptors.dart';

/// Pre-configured [Dio] HTTP client for Munchify POS.
///
/// Registered as a singleton in the DI container (e.g. get_it).
/// All DataSources receive this through constructor injection.
///
/// Interceptors applied (in order):
///   1. [AuthInterceptor]   — attaches JWT; clears tokens on 401.
///   2. [LoggingInterceptor] — prints request/response in debug mode.
class DioClient {
  late final Dio _dio;

  DioClient({required FlutterSecureStorage secureStorage}) {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.baseUrl,
        connectTimeout:
            const Duration(milliseconds: AppConstants.connectTimeoutMs),
        receiveTimeout:
            const Duration(milliseconds: AppConstants.receiveTimeoutMs),
        sendTimeout:
            const Duration(milliseconds: AppConstants.sendTimeoutMs),
        headers: const {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.addAll([
      AuthInterceptor(secureStorage: secureStorage),
      LoggingInterceptor(),
    ]);
  }

  /// The configured [Dio] instance.
  /// Inject into DataSource constructors via DI.
  Dio get dio => _dio;
}
