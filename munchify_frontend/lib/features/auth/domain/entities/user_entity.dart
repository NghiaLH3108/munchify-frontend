import 'package:equatable/equatable.dart';

/// Pure domain entity representing an authenticated user.
///
/// Follows Clean Architecture: pure Dart, no framework imports.
class UserEntity extends Equatable {
  final int userId;
  final String username;
  final String fullName;
  final String? email;
  final String? phone;
  final String role;
  final bool isActive;

  const UserEntity({
    required this.userId,
    required this.username,
    required this.fullName,
    this.email,
    this.phone,
    required this.role,
    this.isActive = true,
  });

  bool get isAdmin => role.toUpperCase() == 'ADMIN';
  bool get isStaff => role.toUpperCase() == 'STAFF';

  @override
  List<Object?> get props => [
        userId,
        username,
        fullName,
        email,
        phone,
        role,
        isActive,
      ];
}
