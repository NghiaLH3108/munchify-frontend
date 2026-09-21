/// Data-layer exceptions for Munchify POS.
///
/// These are thrown inside DataSources and caught in RepositoryImpl,
/// where they are converted to the appropriate [Failure] subclass.
/// Exceptions must NEVER propagate beyond the Data layer.

// ─── Network / Server ─────────────────────────────────────────────────────────

/// Thrown when the server returns a non-2xx HTTP response.
class ServerException implements Exception {
  final String message;
  final int? statusCode;

  const ServerException({required this.message, this.statusCode});

  @override
  String toString() =>
      'ServerException(statusCode: $statusCode, message: $message)';
}

/// Thrown on connection timeout, send timeout, receive timeout, or no connectivity.
class NetworkException implements Exception {
  final String message;

  const NetworkException({
    this.message = 'Không có kết nối mạng. Vui lòng kiểm tra lại.',
  });

  @override
  String toString() => 'NetworkException(message: $message)';
}

// ─── Authentication ───────────────────────────────────────────────────────────

/// Thrown when credentials are rejected (HTTP 401 during login).
class AuthException implements Exception {
  final String message;
  final int? statusCode;

  const AuthException({required this.message, this.statusCode});

  @override
  String toString() =>
      'AuthException(statusCode: $statusCode, message: $message)';
}

/// Thrown when the interceptor detects a 401 on a non-login request,
/// indicating the JWT session has expired.
class UnauthorizedException implements Exception {
  final String message;

  const UnauthorizedException({
    this.message = 'Phiên đăng nhập hết hạn. Vui lòng đăng nhập lại.',
  });

  @override
  String toString() => 'UnauthorizedException(message: $message)';
}

/// Thrown when the server returns HTTP 403 Forbidden.
class ForbiddenException implements Exception {
  final String message;

  const ForbiddenException({
    this.message = 'Bạn không có quyền thực hiện thao tác này.',
  });

  @override
  String toString() => 'ForbiddenException(message: $message)';
}

// ─── Validation ───────────────────────────────────────────────────────────────

/// Thrown when the server returns HTTP 400 or 422 (validation error).
class ValidationException implements Exception {
  final String message;
  final Map<String, List<String>>? fieldErrors;

  const ValidationException({required this.message, this.fieldErrors});

  @override
  String toString() =>
      'ValidationException(message: $message, fields: $fieldErrors)';
}

// ─── Local Storage ────────────────────────────────────────────────────────────

/// Thrown when a SecureStorage or SharedPreferences read/write fails.
class CacheException implements Exception {
  final String message;

  const CacheException({required this.message});

  @override
  String toString() => 'CacheException(message: $message)';
}

// ─── Not Found ────────────────────────────────────────────────────────────────

/// Thrown when the server returns HTTP 404.
class NotFoundException implements Exception {
  final String message;

  const NotFoundException({
    this.message = 'Không tìm thấy dữ liệu yêu cầu.',
  });

  @override
  String toString() => 'NotFoundException(message: $message)';
}
