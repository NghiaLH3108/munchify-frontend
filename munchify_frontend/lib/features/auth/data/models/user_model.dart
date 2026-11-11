import '../../domain/entities/user_entity.dart';

/// Data model representing a user from API/storage.
class UserModel extends UserEntity {
  const UserModel({
    required super.userId,
    required super.username,
    required super.fullName,
    super.email,
    super.phone,
    required super.role,
    super.isActive = true,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['userId'] is int
          ? json['userId'] as int
          : int.tryParse(json['userId']?.toString() ?? '') ??
              (json['UserId'] is int
                  ? json['UserId'] as int
                  : int.tryParse(json['UserId']?.toString() ?? '') ?? 0),
      username: (json['username'] ?? json['Username'] ?? '').toString(),
      fullName: (json['fullName'] ?? json['FullName'] ?? '').toString(),
      email: json['email']?.toString() ?? json['Email']?.toString(),
      phone: json['phone']?.toString() ?? json['Phone']?.toString(),
      role: (json['role'] ?? json['Role'] ?? 'STAFF').toString(),
      isActive: (json['isActive'] ?? json['IsActive'] ?? true) as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'username': username,
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'role': role,
      'isActive': isActive,
    };
  }

  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      userId: entity.userId,
      username: entity.username,
      fullName: entity.fullName,
      email: entity.email,
      phone: entity.phone,
      role: entity.role,
      isActive: entity.isActive,
    );
  }
}
