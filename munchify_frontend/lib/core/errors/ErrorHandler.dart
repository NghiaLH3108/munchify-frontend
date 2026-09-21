import 'package:dio/dio.dart';

import 'Exceptions.dart';
import 'Failures.dart';

/// Converts raw exceptions (Dio errors, custom exceptions) into typed [Failure]
/// objects suitable for the domain layer's `Either<Failure, T>` return type.
///
/// Usage in a RepositoryImpl:
/// ```dart
/// } on DioException catch (e) {
///   return Left(ErrorHandler.handle(e));
/// } on CacheException catch (e) {
///   return Left(ErrorHandler.handle(e));
/// }
/// ```
class ErrorHandler {
  ErrorHandler._();

  /// Map any thrown [error] to the most specific [Failure] subclass.
  static Failure handle(dynamic error) {
    if (error is DioException) return _fromDio(error);
    if (error is ServerException) {
      return ServerFailure(message: error.message, statusCode: error.statusCode);
    }
    if (error is NetworkException) {
      return NetworkFailure(message: error.message);
    }
    if (error is AuthException) {
      return AuthFailure(message: error.message, statusCode: error.statusCode);
    }
    if (error is UnauthorizedException) {
      return AuthFailure(message: error.message, statusCode: 401);
    }
    if (error is ForbiddenException) {
      return PermissionFailure(message: error.message);
    }
    if (error is ValidationException) {
      return ValidationFailure(message: error.message);
    }
    if (error is NotFoundException) {
      return NotFoundFailure(message: error.message);
    }
    if (error is CacheException) {
      return CacheFailure(message: error.message);
    }
    return const UnexpectedFailure();
  }

  // ─── Dio-specific mapping ─────────────────────────────────────────────────

  static Failure _fromDio(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const NetworkFailure(
          message: 'Kết nối quá thời gian. Vui lòng kiểm tra mạng và thử lại.',
        );

      case DioExceptionType.connectionError:
        return const NetworkFailure();

      case DioExceptionType.badResponse:
        return _fromHttpResponse(e);

      case DioExceptionType.cancel:
        return const UnexpectedFailure(message: 'Yêu cầu đã bị huỷ.');

      default:
        return UnexpectedFailure(
          message: e.message ?? 'Lỗi kết nối không xác định.',
        );
    }
  }

  static Failure _fromHttpResponse(DioException e) {
    final statusCode = e.response?.statusCode;
    final message =
        _extractMessage(e.response?.data) ?? e.message ?? 'Lỗi máy chủ.';

    return switch (statusCode) {
      400 || 422 => ValidationFailure(message: message, statusCode: statusCode),
      401 => AuthFailure(
          message: 'Phiên đăng nhập hết hạn. Vui lòng đăng nhập lại.',
          statusCode: 401,
        ),
      403 => PermissionFailure(message: message),
      404 => NotFoundFailure(message: message),
      _ => ServerFailure(message: message, statusCode: statusCode),
    };
  }

  /// Extract human-readable message from backend JSON error bodies.
  /// Supports: { "message": "..." }, { "error": "..." }, { "title": "..." }
  static String? _extractMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      return (data['message'] ?? data['error'] ?? data['title']) as String?;
    }
    return null;
  }
}
