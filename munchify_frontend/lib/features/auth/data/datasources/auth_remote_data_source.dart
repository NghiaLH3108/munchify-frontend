import 'package:dio/dio.dart';
import '../../../../core/constants/ApiEndpoints.dart';
import '../../../../core/network/DioClient.dart';
import '../models/auth_result_model.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<AuthResultModel> login({
    required String username,
    required String password,
  });

  Future<UserModel> getCurrentUser();

  Future<String> forgotPassword(String email);

  Future<String> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  });
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final DioClient dioClient;

  AuthRemoteDataSourceImpl({required this.dioClient});

  @override
  Future<AuthResultModel> login({
    required String username,
    required String password,
  }) async {
    final response = await dioClient.dio.post(
      ApiEndpoints.login,
      data: {
        'username': username,
        'password': password,
      },
    );

    if (response.data != null) {
      if (response.data is Map<String, dynamic>) {
        final map = response.data as Map<String, dynamic>;
        if (map['success'] == false) {
          throw DioException(
            requestOptions: response.requestOptions,
            response: response,
            error: map['message'] ?? 'Đăng nhập không thành công',
          );
        }
        return AuthResultModel.fromJson(map);
      }
    }
    throw DioException(
      requestOptions: response.requestOptions,
      response: response,
      error: 'Phản hồi từ máy chủ không hợp lệ',
    );
  }

  @override
  Future<UserModel> getCurrentUser() async {
    final response = await dioClient.dio.get(ApiEndpoints.me);

    if (response.data != null) {
      if (response.data is Map<String, dynamic>) {
        final map = response.data as Map<String, dynamic>;
        if (map['success'] == false) {
          throw DioException(
            requestOptions: response.requestOptions,
            response: response,
            error: map['message'] ?? 'Không thể lấy thông tin người dùng',
          );
        }
        final userData = map['data'] ?? map;
        if (userData is Map<String, dynamic>) {
          return UserModel.fromJson(userData);
        }
      }
    }
    throw DioException(
      requestOptions: response.requestOptions,
      response: response,
      error: 'Phản hồi từ máy chủ không hợp lệ',
    );
  }

  @override
  Future<String> forgotPassword(String email) async {
    final response = await dioClient.dio.post(
      ApiEndpoints.forgotPassword,
      data: {
        'email': email,
      },
    );

    if (response.data != null && response.data is Map<String, dynamic>) {
      final map = response.data as Map<String, dynamic>;
      if (map['success'] == false) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          error: map['message'] ?? 'Yêu cầu đặt lại mật khẩu thất bại',
        );
      }
      return (map['message'] ?? 'Mã xác nhận OTP đã được gửi đến email của bạn.').toString();
    }
    return 'Mã xác nhận OTP đã được gửi đến email của bạn.';
  }

  @override
  Future<String> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    final response = await dioClient.dio.post(
      ApiEndpoints.resetPassword,
      data: {
        'email': email,
        'otp': otp,
        'newPassword': newPassword,
      },
    );

    if (response.data != null && response.data is Map<String, dynamic>) {
      final map = response.data as Map<String, dynamic>;
      if (map['success'] == false) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          error: map['message'] ?? 'Đặt lại mật khẩu thất bại',
        );
      }
      return (map['message'] ?? 'Mật khẩu đã được đặt lại thành công.').toString();
    }
    return 'Mật khẩu đã được đặt lại thành công.';
  }
}
