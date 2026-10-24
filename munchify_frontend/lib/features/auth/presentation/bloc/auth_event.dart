import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Checks whether user is already logged in (JWT token exists and valid).
class CheckAuthStatusEvent extends AuthEvent {
  const CheckAuthStatusEvent();
}

/// Submits credentials for authentication.
class LoginSubmittedEvent extends AuthEvent {
  final String username;
  final String password;

  const LoginSubmittedEvent({
    required this.username,
    required this.password,
  });

  @override
  List<Object?> get props => [username, password];
}

/// Requests user logout and session cleanup.
class LogoutRequestedEvent extends AuthEvent {
  const LogoutRequestedEvent();
}

/// Requests password reset OTP sent to specified email address.
class ForgotPasswordEvent extends AuthEvent {
  final String email;

  const ForgotPasswordEvent({required this.email});

  @override
  List<Object?> get props => [email];
}

/// Submits OTP and new password to complete password reset.
class ResetPasswordEvent extends AuthEvent {
  final String email;
  final String otp;
  final String newPassword;

  const ResetPasswordEvent({
    required this.email,
    required this.otp,
    required this.newPassword,
  });

  @override
  List<Object?> get props => [email, otp, newPassword];
}

/// Resets transient state flags (e.g. after showing error toast or navigating).
class ResetAuthStatusEvent extends AuthEvent {
  const ResetAuthStatusEvent();
}
