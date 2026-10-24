import 'dart:io';
import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/Failures.dart';
import '../../domain/entities/auth_result.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_data_source.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, AuthResult>> login({
    required String username,
    required String password,
  }) async {
    try {
      final result = await remoteDataSource.login(
        username: username,
        password: password,
      );

      // Save token and user details to secure storage
      final userModel = result.user is UserModel
          ? result.user as UserModel
          : UserModel.fromEntity(result.user);

      await localDataSource.saveAuthData(
        token: result.token,
        user: userModel,
      );

      return Right(result);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> getCurrentUser() async {
    try {
      final user = await remoteDataSource.getCurrentUser();
      return Right(user);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await localDataSource.clearAuthData();
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(message: 'Không thể xóa thông tin đăng nhập: ${e.toString()}'));
    }
  }

  Failure _handleDioError(DioException e) {
    if (e.error is SocketException ||
        e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout) {
      return const NetworkFailure();
    }

    final statusCode = e.response?.statusCode;
    String? message;
    if (e.response?.data is Map<String, dynamic>) {
      final data = e.response!.data as Map<String, dynamic>;
      message = data['message']?.toString() ?? data['error']?.toString();
    }
    message ??= e.message ?? 'Đã xảy ra lỗi kết nối với máy chủ';

    switch (statusCode) {
      case 401:
        return AuthFailure(message: message, statusCode: statusCode);
      case 403:
        return PermissionFailure(message: message, statusCode: statusCode);
      case 400:
      case 422:
        return ValidationFailure(message: message, statusCode: statusCode);
      case 404:
        return NotFoundFailure(message: message, statusCode: statusCode);
      default:
        return ServerFailure(message: message, statusCode: statusCode);
    }
  }
}
