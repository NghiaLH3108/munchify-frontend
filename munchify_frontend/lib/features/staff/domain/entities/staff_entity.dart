import 'package:equatable/equatable.dart';

class StaffEntity extends Equatable {
  final int userId;
  final String username;
  final String fullName;
  final String? phone;
  final String? email;
  final String role;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const StaffEntity({
    required this.userId,
    required this.username,
    required this.fullName,
    this.phone,
    this.email,
    required this.role,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        userId,
        username,
        fullName,
        phone,
        email,
        role,
        isActive,
        createdAt,
        updatedAt,
      ];
}
