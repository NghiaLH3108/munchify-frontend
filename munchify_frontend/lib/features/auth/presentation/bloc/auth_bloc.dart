import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/datasources/auth_local_data_source.dart';
import '../../domain/usecases/forgot_password_usecase.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/reset_password_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';
import '../../../../core/utils/platform_helper.dart';
import '../../domain/entities/user_entity.dart';

const String _kStaffOnAdminPlatformMsg =
    'Tài khoản nhân viên không có quyền truy cập trang quản trị. Vui lòng sử dụng ứng dụng di động.';

const String _kAdminOnStaffPlatformMsg =
    'Tài khoản quản trị viên không được phép đăng nhập trên ứng dụng di động. Vui lòng sử dụng trình duyệt Web hoặc ứng dụng Desktop.';

/// Web/Windows chỉ dành cho ADMIN. App mobile (Android/iOS) chỉ dành cho STAFF.
bool _isRoleAllowedOnPlatform(UserEntity user) {
  if (PlatformHelper.isAdminPlatform) return user.isAdmin || user.isStaff;
  return user.isStaff;
}

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final LogoutUseCase logoutUseCase;
  final GetCurrentUserUseCase getCurrentUserUseCase;
  final ForgotPasswordUseCase forgotPasswordUseCase;
  final ResetPasswordUseCase resetPasswordUseCase;
  final AuthLocalDataSource localDataSource;

  AuthBloc({
    required this.loginUseCase,
    required this.logoutUseCase,
    required this.getCurrentUserUseCase,
    required this.forgotPasswordUseCase,
    required this.resetPasswordUseCase,
    required this.localDataSource,
  }) : super(const AuthInitial()) {
    on<CheckAuthStatusEvent>(_onCheckAuthStatus);
    on<LoginSubmittedEvent>(_onLoginSubmitted);
    on<LogoutRequestedEvent>(_onLogoutRequested);
    on<ForgotPasswordEvent>(_onForgotPassword);
    on<ResetPasswordEvent>(_onResetPassword);
    on<ResetAuthStatusEvent>(_onResetAuthStatus);
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatusEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final token = await localDataSource.getToken();
      if (token != null && token.isNotEmpty) {
        final result = await getCurrentUserUseCase();
        await result.fold(
          (failure) async {
            await localDataSource.clearAuthData();
            emit(const Unauthenticated());
          },
          (user) async {
            if (!_isRoleAllowedOnPlatform(user)) {
              await localDataSource.clearAuthData();
              emit(const Unauthenticated());
              return;
            }
            emit(Authenticated(user: user, token: token));
          },
        );
      } else {
        emit(const Unauthenticated());
      }
    } catch (_) {
      emit(const Unauthenticated());
    }
  }

  Future<void> _onLoginSubmitted(
    LoginSubmittedEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await loginUseCase(
      username: event.username,
      password: event.password,
    );

    await result.fold(
      (failure) async => emit(AuthFailureState(failure.message)),
      (authResult) async {
        if (!_isRoleAllowedOnPlatform(authResult.user)) {
          await localDataSource.clearAuthData();
          emit(
            AuthFailureState(
              PlatformHelper.isStaffPlatform
                  ? _kAdminOnStaffPlatformMsg
                  : _kStaffOnAdminPlatformMsg,
            ),
          );
          return;
        }
        emit(
          Authenticated(
            user: authResult.user,
            token: authResult.token,
          ),
        );
      },
    );
  }

  Future<void> _onLogoutRequested(
    LogoutRequestedEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    await logoutUseCase();
    emit(const Unauthenticated());
  }

  Future<void> _onForgotPassword(
    ForgotPasswordEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const ForgotPasswordLoading());
    final result = await forgotPasswordUseCase(event.email);
    result.fold(
      (failure) => emit(ForgotPasswordFailure(failure.message)),
      (message) => emit(ForgotPasswordSuccess(
        message: message,
        email: event.email,
      )),
    );
  }

  Future<void> _onResetPassword(
    ResetPasswordEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const ResetPasswordLoading());
    final result = await resetPasswordUseCase(
      email: event.email,
      otp: event.otp,
      newPassword: event.newPassword,
    );
    result.fold(
      (failure) => emit(ResetPasswordFailure(failure.message)),
      (message) => emit(ResetPasswordSuccess(message)),
    );
  }

  void _onResetAuthStatus(
    ResetAuthStatusEvent event,
    Emitter<AuthState> emit,
  ) {
    if (state is AuthFailureState ||
        state is ForgotPasswordFailure ||
        state is ResetPasswordFailure) {
      emit(const Unauthenticated());
    }
  }
}
