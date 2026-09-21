import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/staff_entity.dart';

part 'staff_model.g.dart';

@JsonSerializable()
class StaffModel extends StaffEntity {
  const StaffModel({
    required super.userId,
    required super.username,
    required super.fullName,
    super.phone,
    super.email,
    required super.role,
    required super.isActive,
    required super.createdAt,
    required super.updatedAt,
  });

  factory StaffModel.fromJson(Map<String, dynamic> json) => _$StaffModelFromJson(json);

  Map<String, dynamic> toJson() => _$StaffModelToJson(this);
}
