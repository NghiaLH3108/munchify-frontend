import 'package:equatable/equatable.dart';
import '../../domain/entities/user_entity.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class Authenticated extends AuthState {
  final UserEntity user;
  final String token;

  const Authenticated({
    required this.user,
    required this.token,
  });

  @override
  List<Object?> get props => [user, token];
}

class Unauthenticated extends AuthState {
  const Unauthenticated();
}

class AuthFailureState extends AuthState {
  final String message;

  const AuthFailureState(this.message);

  @override
  List<Object?> get props => [message];
}

class ForgotPasswordLoading extends AuthState {
  const ForgotPasswordLoading();
}

class ForgotPasswordSuccess extends AuthState {
  final String message;
  final String email;

  const ForgotPasswordSuccess({
    required this.message,
    required this.email,
  });

  @override
  List<Object?> get props => [message, email];
}

class ForgotPasswordFailure extends AuthState {
  final String message;

  const ForgotPasswordFailure(this.message);

  @override
  List<Object?> get props => [message];
}

class ResetPasswordLoading extends AuthState {
  const ResetPasswordLoading();
}

class ResetPasswordSuccess extends AuthState {
  final String message;

  const ResetPasswordSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class ResetPasswordFailure extends AuthState {
  final String message;

  const ResetPasswordFailure(this.message);

  @override
  List<Object?> get props => [message];
}
