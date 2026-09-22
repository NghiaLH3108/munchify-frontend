// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CategoryModel _$CategoryModelFromJson(Map<String, dynamic> json) =>
    CategoryModel(
      id: (json['categoryId'] as num).toInt(),
      categoryName: json['categoryName'] as String,
      description: json['description'] as String?,
      isActive: json['isActive'] as bool,
      productCount: (json['productCount'] as num).toInt(),
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$CategoryModelToJson(CategoryModel instance) =>
    <String, dynamic>{
      'categoryId': instance.id,
      'categoryName': instance.categoryName,
      'description': instance.description,
      'isActive': instance.isActive,
      'productCount': instance.productCount,
      'createdAt': instance.createdAt?.toIso8601String(),
    };
