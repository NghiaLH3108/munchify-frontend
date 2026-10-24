import '../../domain/entities/auth_result.dart';
import 'user_model.dart';

/// Data model representing login/auth response containing JWT token & User details.
class AuthResultModel extends AuthResult {
  const AuthResultModel({
    required super.token,
    required super.user,
  });

  factory AuthResultModel.fromJson(Map<String, dynamic> json) {
    // Backend might return ApiResponse envelope: { success: true, data: { token: '...', user: {...} } }
    // or directly: { token: '...', user: {...} }
    final Map<String, dynamic> dataMap = (json['data'] is Map<String, dynamic>)
        ? json['data'] as Map<String, dynamic>
        : (json['Data'] is Map<String, dynamic>)
            ? json['Data'] as Map<String, dynamic>
            : json;

    final token = (dataMap['token'] ??
            dataMap['Token'] ??
            dataMap['accessToken'] ??
            dataMap['AccessToken'] ??
            '')
        .toString();

    final userJson = (dataMap['user'] is Map<String, dynamic>)
        ? dataMap['user'] as Map<String, dynamic>
        : (dataMap['User'] is Map<String, dynamic>)
            ? dataMap['User'] as Map<String, dynamic>
            : dataMap;

    final user = UserModel.fromJson(userJson);

    return AuthResultModel(
      token: token,
      user: user,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'user': (user is UserModel)
          ? (user as UserModel).toJson()
          : UserModel.fromEntity(user).toJson(),
    };
  }
}
