import 'package:equatable/equatable.dart';

/// Base class for all domain-level failures.
///
/// Use with `Either<Failure, T>` in Use Cases and Repository interfaces
/// to ensure exhaustive error handling without throwing exceptions across layers.
abstract class Failure extends Equatable {
  final String message;
  final int? statusCode;

  const Failure({required this.message, this.statusCode});

  @override
  List<Object?> get props => [message, statusCode];

  @override
  String toString() => '$runtimeType(message: $message, statusCode: $statusCode)';
}

// ─── Concrete Failure Types ───────────────────────────────────────────────────

/// HTTP 5xx or unexpected API response.
class ServerFailure extends Failure {
  const ServerFailure({required super.message, super.statusCode});
}

/// No internet connection or connection timeout.
class NetworkFailure extends Failure {
  const NetworkFailure({
    super.message = 'Không có kết nối mạng. Vui lòng kiểm tra lại.',
    super.statusCode,
  });
}

/// Local storage read/write error (SecureStorage or SharedPreferences).
class CacheFailure extends Failure {
  const CacheFailure({required super.message, super.statusCode});
}

/// HTTP 401 Unauthorized — session expired or invalid credentials.
/// Presentation layer should wipe tokens and redirect to Login.
class AuthFailure extends Failure {
  const AuthFailure({required super.message, super.statusCode});
}

/// HTTP 403 Forbidden — authenticated but insufficient role/permission.
class PermissionFailure extends Failure {
  const PermissionFailure({
    super.message = 'Bạn không có quyền thực hiện thao tác này.',
    super.statusCode = 403,
  });
}

/// HTTP 400 / 422 — request body failed backend validation.
class ValidationFailure extends Failure {
  const ValidationFailure({required super.message, super.statusCode});
}

/// HTTP 404 — requested resource not found.
class NotFoundFailure extends Failure {
  const NotFoundFailure({
    super.message = 'Không tìm thấy dữ liệu yêu cầu.',
    super.statusCode = 404,
  });
}

/// Catch-all for any unclassified error.
class UnexpectedFailure extends Failure {
  const UnexpectedFailure({
    super.message = 'Đã xảy ra lỗi không xác định. Vui lòng thử lại.',
    super.statusCode,
  });
}
