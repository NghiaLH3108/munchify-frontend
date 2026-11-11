import 'package:equatable/equatable.dart';
import 'user_entity.dart';

/// Pure domain entity representing authentication response (login).
class AuthResult extends Equatable {
  final String token;
  final UserEntity user;

  const AuthResult({
    required this.token,
    required this.user,
  });

  @override
  List<Object?> get props => [token, user];
}
