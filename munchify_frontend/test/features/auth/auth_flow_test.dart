import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:munchify_frontend/core/errors/Failures.dart';
import 'package:munchify_frontend/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:munchify_frontend/features/auth/data/models/auth_result_model.dart';
import 'package:munchify_frontend/features/auth/data/models/user_model.dart';
import 'package:munchify_frontend/features/auth/domain/entities/auth_result.dart';
import 'package:munchify_frontend/features/auth/domain/entities/user_entity.dart';
import 'package:munchify_frontend/features/auth/domain/repositories/auth_repository.dart';
import 'package:munchify_frontend/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:munchify_frontend/features/auth/domain/usecases/login_usecase.dart';
import 'package:munchify_frontend/features/auth/domain/usecases/logout_usecase.dart';
import 'package:munchify_frontend/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:munchify_frontend/features/auth/presentation/bloc/auth_event.dart';
import 'package:munchify_frontend/features/auth/presentation/bloc/auth_state.dart';

// ─── FAKE IMPLEMENTATIONS FOR ADVERSARIAL TESTING ────────────────────────────

class FakeAuthLocalDataSource implements AuthLocalDataSource {
  String? _token;
  String? _role;
  String? _userId;
  String? _userName;

  @override
  Future<void> saveAuthData({
    required String token,
    required UserModel user,
  }) async {
    _token = token;
    _role = user.role;
    _userId = user.userId.toString();
    _userName = user.fullName.isNotEmpty ? user.fullName : user.username;
  }

  @override
  Future<String?> getToken() async => _token;

  @override
  Future<String?> getUserRole() async => _role;

  @override
  Future<String?> getUserId() async => _userId;

  @override
  Future<String?> getUserName() async => _userName;

  @override
  Future<bool> hasToken() async => _token != null && _token!.isNotEmpty;

  @override
  Future<void> clearAuthData() async {
    _token = null;
    _role = null;
    _userId = null;
    _userName = null;
  }
}

class FakeAuthRepository implements AuthRepository {
  Either<Failure, AuthResult>? loginResult;
  Either<Failure, UserEntity>? getCurrentUserResult;
  Either<Failure, void>? logoutResult;

  String? lastLoginUser;
  String? lastLoginPass;

  @override
  Future<Either<Failure, AuthResult>> login({
    required String username,
    required String password,
  }) async {
    lastLoginUser = username;
    lastLoginPass = password;
    return loginResult ??
        const Left(ServerFailure(message: 'Tên đăng nhập hoặc mật khẩu không chính xác'));
  }

  @override
  Future<Either<Failure, UserEntity>> getCurrentUser() async {
    return getCurrentUserResult ??
        const Left(ServerFailure(message: 'Phiên đăng nhập đã hết hạn'));
  }

  @override
  Future<Either<Failure, void>> logout() async {
    return logoutResult ?? const Right(null);
  }
}

void main() {
  const tUser = UserEntity(
    userId: 1,
    username: 'admin',
    fullName: 'Quản Trị Viên',
    email: 'admin@munchify.vn',
    phone: '0901234567',
    role: 'ADMIN',
    isActive: true,
  );

  const tStaffUser = UserEntity(
    userId: 2,
    username: 'staff01',
    fullName: 'Nhân Viên Thu Ngân',
    email: 'staff01@munchify.vn',
    phone: '0909999888',
    role: 'STAFF',
    isActive: true,
  );

  const tAuthResult = AuthResult(
    token: 'jwt_mock_token_secret_123',
    user: tUser,
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // GROUP 1: MODEL & ENTITY INTEGRITY
  // ═══════════════════════════════════════════════════════════════════════════
  group('UserModel & AuthResultModel Serialization', () {
    test('deserializes UserModel from standard JSON response', () {
      final json = {
        'userId': 1,
        'username': 'admin',
        'fullName': 'Quản Trị Viên',
        'email': 'admin@munchify.vn',
        'phone': '0901234567',
        'role': 'ADMIN',
        'isActive': true,
      };

      final model = UserModel.fromJson(json);

      expect(model.userId, 1);
      expect(model.username, 'admin');
      expect(model.fullName, 'Quản Trị Viên');
      expect(model.email, 'admin@munchify.vn');
      expect(model.phone, '0901234567');
      expect(model.role, 'ADMIN');
      expect(model.isActive, isTrue);
      expect(model.isAdmin, isTrue);
      expect(model.isStaff, isFalse);
    });

    test('deserializes UserModel with string userId and PascalCase keys', () {
      final json = {
        'UserId': '42',
        'Username': 'staff_alex',
        'FullName': 'Alex Nguyen',
        'Role': 'STAFF',
        'IsActive': true,
      };

      final model = UserModel.fromJson(json);

      expect(model.userId, 42);
      expect(model.username, 'staff_alex');
      expect(model.fullName, 'Alex Nguyen');
      expect(model.email, isNull);
      expect(model.phone, isNull);
      expect(model.role, 'STAFF');
      expect(model.isStaff, isTrue);
      expect(model.isAdmin, isFalse);
    });

    test('serializes UserModel to JSON accurately', () {
      const model = UserModel(
        userId: 10,
        username: 'cashier',
        fullName: 'Thu Ngân 1',
        email: 'cashier@munchify.vn',
        phone: '0988776655',
        role: 'STAFF',
        isActive: true,
      );

      final json = model.toJson();

      expect(json['userId'], 10);
      expect(json['username'], 'cashier');
      expect(json['role'], 'STAFF');
      expect(json['isActive'], isTrue);
    });

    test('deserializes AuthResultModel wrapped in ApiResponse data envelope', () {
      final apiEnvelope = {
        'success': true,
        'message': 'Đăng nhập thành công',
        'data': {
          'token': 'jwt_secure_token_sample',
          'user': {
            'userId': 1,
            'username': 'admin',
            'fullName': 'Quản Trị Viên',
            'email': 'admin@munchify.vn',
            'role': 'ADMIN',
            'isActive': true,
          }
        }
      };

      final authResult = AuthResultModel.fromJson(apiEnvelope);

      expect(authResult.token, 'jwt_secure_token_sample');
      expect(authResult.user.userId, 1);
      expect(authResult.user.username, 'admin');
      expect(authResult.user.role, 'ADMIN');
    });

    test('deserializes AuthResultModel direct structure', () {
      final directJson = {
        'token': 'direct_token_abc',
        'user': {
          'userId': 2,
          'username': 'staff01',
          'fullName': 'Nhân Viên',
          'role': 'STAFF',
        }
      };

      final authResult = AuthResultModel.fromJson(directJson);

      expect(authResult.token, 'direct_token_abc');
      expect(authResult.user.userId, 2);
      expect(authResult.user.username, 'staff01');
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // GROUP 2: LOCAL DATA SOURCE INTEGRITY
  // ═══════════════════════════════════════════════════════════════════════════
  group('AuthLocalDataSource contract', () {
    late FakeAuthLocalDataSource localDataSource;

    setUp(() {
      localDataSource = FakeAuthLocalDataSource();
    });

    test('saveAuthData stores all session credentials correctly', () async {
      const model = UserModel(
        userId: 1,
        username: 'admin',
        fullName: 'Quản Trị Viên',
        role: 'ADMIN',
      );

      await localDataSource.saveAuthData(
        token: 'token_123',
        user: model,
      );

      expect(await localDataSource.getToken(), 'token_123');
      expect(await localDataSource.getUserId(), '1');
      expect(await localDataSource.getUserName(), 'Quản Trị Viên');
      expect(await localDataSource.getUserRole(), 'ADMIN');
      expect(await localDataSource.hasToken(), isTrue);
    });

    test('clearAuthData wipes all stored credentials', () async {
      const model = UserModel(
        userId: 1,
        username: 'admin',
        fullName: 'Quản Trị Viên',
        role: 'ADMIN',
      );

      await localDataSource.saveAuthData(
        token: 'token_123',
        user: model,
      );

      expect(await localDataSource.hasToken(), isTrue);

      await localDataSource.clearAuthData();

      expect(await localDataSource.getToken(), isNull);
      expect(await localDataSource.getUserId(), isNull);
      expect(await localDataSource.getUserName(), isNull);
      expect(await localDataSource.getUserRole(), isNull);
      expect(await localDataSource.hasToken(), isFalse);
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // GROUP 3: AUTH USECASES
  // ═══════════════════════════════════════════════════════════════════════════
  group('Auth UseCases delegation', () {
    late FakeAuthRepository repository;

    setUp(() {
      repository = FakeAuthRepository();
    });

    test('LoginUseCase invokes repository with trimmed credentials', () async {
      repository.loginResult = const Right(tAuthResult);
      final useCase = LoginUseCase(repository);

      final result = await useCase(username: 'admin', password: 'password123');

      expect(result.isRight(), isTrue);
      expect(repository.lastLoginUser, 'admin');
      expect(repository.lastLoginPass, 'password123');
    });

    test('LogoutUseCase invokes repository logout', () async {
      repository.logoutResult = const Right(null);
      final useCase = LogoutUseCase(repository);

      final result = await useCase();

      expect(result.isRight(), isTrue);
    });

    test('GetCurrentUserUseCase returns UserEntity on success', () async {
      repository.getCurrentUserResult = const Right(tUser);
      final useCase = GetCurrentUserUseCase(repository);

      final result = await useCase();

      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('Expected Right'),
        (user) => expect(user.username, 'admin'),
      );
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // GROUP 4: AUTH BLOC STATE TRANSITIONS & DEVIL'S ADVOCATE EDGE-CASES
  // ═══════════════════════════════════════════════════════════════════════════
  group('AuthBloc State Transitions', () {
    late FakeAuthRepository repository;
    late FakeAuthLocalDataSource localDataSource;
    late LoginUseCase loginUseCase;
    late LogoutUseCase logoutUseCase;
    late GetCurrentUserUseCase getCurrentUserUseCase;
    late AuthBloc authBloc;

    setUp(() {
      repository = FakeAuthRepository();
      localDataSource = FakeAuthLocalDataSource();
      loginUseCase = LoginUseCase(repository);
      logoutUseCase = LogoutUseCase(repository);
      getCurrentUserUseCase = GetCurrentUserUseCase(repository);

      authBloc = AuthBloc(
        loginUseCase: loginUseCase,
        logoutUseCase: logoutUseCase,
        getCurrentUserUseCase: getCurrentUserUseCase,
        localDataSource: localDataSource,
      );
    });

    tearDown(() {
      authBloc.close();
    });

    test('initial state must be AuthInitial', () {
      expect(authBloc.state, equals(const AuthInitial()));
    });

    group('CheckAuthStatusEvent', () {
      test('emits [AuthLoading, Authenticated] when valid token and user profile exist', () async {
        await localDataSource.saveAuthData(
          token: 'valid_jwt_token',
          user: UserModel.fromEntity(tUser),
        );
        repository.getCurrentUserResult = const Right(tUser);

        final expected = [
          const AuthLoading(),
          const Authenticated(user: tUser, token: 'valid_jwt_token'),
        ];

        expectLater(authBloc.stream, emitsInOrder(expected));
        authBloc.add(const CheckAuthStatusEvent());
      });

      test(
        'emits [AuthLoading, Unauthenticated] and purges local storage when token exists but profile fails (401/expired)',
        () async {
          await localDataSource.saveAuthData(
          token: 'expired_jwt_token',
          user: UserModel.fromEntity(tUser),
        );
        repository.getCurrentUserResult = const Left(ServerFailure(message: 'Unauthorized'));

        final expected = [
          const AuthLoading(),
          const Unauthenticated(),
        ];

        expectLater(authBloc.stream, emitsInOrder(expected));
        authBloc.add(const CheckAuthStatusEvent());

        // Yield to allow async completion
        await Future.delayed(const Duration(milliseconds: 50));
        expect(await localDataSource.getToken(), isNull);
      }, timeout: const Timeout(Duration(seconds: 3)));

      test('emits [AuthLoading, Unauthenticated] immediately when no token in local storage', () async {
        final expected = [
          const AuthLoading(),
          const Unauthenticated(),
        ];

        expectLater(authBloc.stream, emitsInOrder(expected));
        authBloc.add(const CheckAuthStatusEvent());
      });
    });

    group('LoginSubmittedEvent', () {
      test('emits [AuthLoading, Authenticated] when credentials are valid', () async {
        repository.loginResult = const Right(tAuthResult);

        final expected = [
          const AuthLoading(),
          const Authenticated(user: tUser, token: 'jwt_mock_token_secret_123'),
        ];

        expectLater(authBloc.stream, emitsInOrder(expected));
        authBloc.add(const LoginSubmittedEvent(
          username: 'admin',
          password: 'AdminPassword@123',
        ));
      });

      test('emits [AuthLoading, AuthFailureState] when login fails with wrong credentials', () async {
        repository.loginResult = const Left(
          ServerFailure(message: 'Tên đăng nhập hoặc mật khẩu không chính xác'),
        );

        final expected = [
          const AuthLoading(),
          const AuthFailureState('Tên đăng nhập hoặc mật khẩu không chính xác'),
        ];

        expectLater(authBloc.stream, emitsInOrder(expected));
        authBloc.add(const LoginSubmittedEvent(
          username: 'admin',
          password: 'wrong_password',
        ));
      });

      test('emits [AuthLoading, AuthFailureState] when account is inactive/locked', () async {
        repository.loginResult = const Left(
          ServerFailure(message: 'Tài khoản của bạn đã bị vô hiệu hóa. Vui lòng liên hệ Quản lý.'),
        );

        final expected = [
          const AuthLoading(),
          const AuthFailureState('Tài khoản của bạn đã bị vô hiệu hóa. Vui lòng liên hệ Quản lý.'),
        ];

        expectLater(authBloc.stream, emitsInOrder(expected));
        authBloc.add(const LoginSubmittedEvent(
          username: 'locked_user',
          password: 'password123',
        ));
      });
    });

    group('LogoutRequestedEvent', () {
      test('emits [AuthLoading, Unauthenticated] on logout', () async {
        repository.logoutResult = const Right(null);

        final expected = [
          const AuthLoading(),
          const Unauthenticated(),
        ];

        expectLater(authBloc.stream, emitsInOrder(expected));
        authBloc.add(const LogoutRequestedEvent());
      });
    });

    group('ResetAuthStatusEvent', () {
      test('clears failure state and emits Unauthenticated', () async {
        repository.loginResult = const Left(ServerFailure(message: 'Lỗi đăng nhập'));

        // First trigger failure
        authBloc.add(const LoginSubmittedEvent(username: 'u', password: 'p'));
        await expectLater(
          authBloc.stream,
          emitsThrough(const AuthFailureState('Lỗi đăng nhập')),
        );

        // Then reset
        expectLater(
          authBloc.stream,
          emits(const Unauthenticated()),
        );
        authBloc.add(const ResetAuthStatusEvent());
      });
    });
  });
}
