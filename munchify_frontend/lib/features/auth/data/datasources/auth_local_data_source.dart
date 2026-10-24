import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/constants/StorageKeys.dart';
import '../models/user_model.dart';

abstract class AuthLocalDataSource {
  Future<void> saveAuthData({
    required String token,
    required UserModel user,
  });

  Future<String?> getToken();

  Future<String?> getUserRole();

  Future<String?> getUserId();

  Future<String?> getUserName();

  Future<bool> hasToken();

  Future<void> clearAuthData();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final FlutterSecureStorage secureStorage;

  static String? cachedAccessToken;

  AuthLocalDataSourceImpl({required this.secureStorage});

  @override
  Future<void> saveAuthData({
    required String token,
    required UserModel user,
  }) async {
    cachedAccessToken = token;
    try {
      await secureStorage.write(key: StorageKeys.accessToken, value: token);
      await secureStorage.write(key: StorageKeys.userId, value: user.userId.toString());
      await secureStorage.write(key: StorageKeys.userName, value: user.fullName.isNotEmpty ? user.fullName : user.username);
      await secureStorage.write(key: StorageKeys.userRole, value: user.role);
    } catch (_) {
      try {
        await secureStorage.deleteAll();
        await secureStorage.write(key: StorageKeys.accessToken, value: token);
        await secureStorage.write(key: StorageKeys.userId, value: user.userId.toString());
        await secureStorage.write(key: StorageKeys.userName, value: user.fullName.isNotEmpty ? user.fullName : user.username);
        await secureStorage.write(key: StorageKeys.userRole, value: user.role);
      } catch (_) {}
    }
  }

  @override
  Future<String?> getToken() async {
    try {
      final token = await secureStorage.read(key: StorageKeys.accessToken);
      if (token != null && token.isNotEmpty) {
        cachedAccessToken = token;
        return token;
      }
      return cachedAccessToken;
    } catch (_) {
      try {
        await secureStorage.deleteAll();
      } catch (_) {}
      return cachedAccessToken;
    }
  }

  @override
  Future<String?> getUserRole() async {
    try {
      return await secureStorage.read(key: StorageKeys.userRole);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<String?> getUserId() async {
    try {
      return await secureStorage.read(key: StorageKeys.userId);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<String?> getUserName() async {
    try {
      return await secureStorage.read(key: StorageKeys.userName);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  @override
  Future<void> clearAuthData() async {
    cachedAccessToken = null;
    try {
      await secureStorage.delete(key: StorageKeys.accessToken);
    } catch (_) {}
    try {
      await secureStorage.delete(key: StorageKeys.refreshToken);
    } catch (_) {}
    try {
      await secureStorage.delete(key: StorageKeys.userRole);
    } catch (_) {}
    try {
      await secureStorage.delete(key: StorageKeys.userId);
    } catch (_) {}
    try {
      await secureStorage.delete(key: StorageKeys.userName);
    } catch (_) {}
  }
}
