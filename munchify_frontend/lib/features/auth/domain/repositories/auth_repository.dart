import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/Failures.dart';
import '../entities/auth_result.dart';
import '../entities/user_entity.dart';

/// Contract for Authentication repository operations in Munchify POS.
///
/// Follows Clean Architecture: Pure Dart interface in Domain layer.
abstract class AuthRepository {
  /// Authenticates user with username & password.
  Future<Either<Failure, AuthResult>> login({
    required String username,
    required String password,
  });

  /// Fetches current authenticated user profile using stored JWT token.
  Future<Either<Failure, UserEntity>> getCurrentUser();

  /// Logs out current user and wipes stored tokens & session info.
  Future<Either<Failure, void>> logout();
}

