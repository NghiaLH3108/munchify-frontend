// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'unit_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UnitModel _$UnitModelFromJson(Map<String, dynamic> json) => UnitModel(
  id: (json['unitId'] as num).toInt(),
  unitName: json['unitName'] as String,
  description: json['description'] as String?,
  isActive: json['isActive'] as bool,
);

Map<String, dynamic> _$UnitModelToJson(UnitModel instance) => <String, dynamic>{
  'unitId': instance.id,
  'unitName': instance.unitName,
  'description': instance.description,
  'isActive': instance.isActive,
};
