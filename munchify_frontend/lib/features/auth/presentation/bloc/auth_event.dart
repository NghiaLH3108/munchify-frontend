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

/// Resets transient state flags (e.g. after showing error toast or navigating).
class ResetAuthStatusEvent extends AuthEvent {
  const ResetAuthStatusEvent();
}
