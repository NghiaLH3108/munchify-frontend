import 'package:equatable/equatable.dart';

class CategoryEntity extends Equatable {
  final int id;
  final String categoryName;
  final String? description;
  final bool isActive;
  final int productCount;
  final DateTime? createdAt;

  const CategoryEntity({
    required this.id,
    required this.categoryName,
    this.description,
    required this.isActive,
    required this.productCount,
    this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        categoryName,
        description,
        isActive,
        productCount,
        createdAt,
      ];
}
