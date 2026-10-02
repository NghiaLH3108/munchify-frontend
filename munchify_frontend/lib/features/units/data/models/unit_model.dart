import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/unit_entity.dart';

part 'unit_model.g.dart';

@JsonSerializable()
class UnitModel extends UnitEntity {
  @override
  @JsonKey(name: 'unitId')
  final int id;
  @override
  @JsonKey(name: 'unitName')
  final String unitName;
  @override
  @JsonKey(name: 'description')
  final String? description;
  @override
  @JsonKey(name: 'isActive')
  final bool isActive;

  const UnitModel({
    required this.id,
    required this.unitName,
    this.description,
    required this.isActive,
  }) : super(
          id: id,
          unitName: unitName,
          description: description,
          isActive: isActive,
        );

  factory UnitModel.fromJson(Map<String, dynamic> json) =>
      _$UnitModelFromJson(json);

  Map<String, dynamic> toJson() => _$UnitModelToJson(this);
}
