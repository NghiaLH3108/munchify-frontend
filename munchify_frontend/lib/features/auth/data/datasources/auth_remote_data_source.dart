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

}

