import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/category_entity.dart';

part 'category_model.g.dart';

@JsonSerializable()
class CategoryModel extends CategoryEntity {
  @override
  @JsonKey(name: 'categoryId')
  final int id;
  @override
  @JsonKey(name: 'categoryName')
  final String categoryName;
  @override
  @JsonKey(name: 'description')
  final String? description;
  @override
  @JsonKey(name: 'isActive')
  final bool isActive;
  @override
  @JsonKey(name: 'productCount', defaultValue: 0)
  final int productCount;
  @override
  @JsonKey(name: 'createdAt')
  final DateTime? createdAt;

  const CategoryModel({
    required this.id,
    required this.categoryName,
    this.description,
    required this.isActive,
    this.productCount = 0,
    this.createdAt,
  }) : super(
          id: id,
          categoryName: categoryName,
          description: description,
          isActive: isActive,
          productCount: productCount,
          createdAt: createdAt,
        );

  factory CategoryModel.fromJson(Map<String, dynamic> json) =>
      _$CategoryModelFromJson(json);

  Map<String, dynamic> toJson() => _$CategoryModelToJson(this);
}
