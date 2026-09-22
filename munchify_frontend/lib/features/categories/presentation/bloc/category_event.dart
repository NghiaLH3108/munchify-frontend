import 'package:equatable/equatable.dart';

abstract class CategoryEvent extends Equatable {
  const CategoryEvent();

  @override
  List<Object?> get props => [];
}

class LoadCategoriesEvent extends CategoryEvent {
  final String searchTerm;
  final bool? isActive;
  final int page;
  final int pageSize;

  const LoadCategoriesEvent({
    this.searchTerm = '',
    this.isActive,
    this.page = 1,
    this.pageSize = 10,
  });

  @override
  List<Object?> get props => [searchTerm, isActive, page, pageSize];
}

class CreateCategoryEvent extends CategoryEvent {
  final String categoryName;
  final String? description;
  final bool isActive;

  const CreateCategoryEvent({
    required this.categoryName,
    this.description,
    required this.isActive,
  });

  @override
  List<Object?> get props => [categoryName, description, isActive];
}

class UpdateCategoryEvent extends CategoryEvent {
  final int id;
  final String categoryName;
  final String? description;
  final bool isActive;

  const UpdateCategoryEvent({
    required this.id,
    required this.categoryName,
    this.description,
    required this.isActive,
  });

  @override
  List<Object?> get props => [id, categoryName, description, isActive];
}

class DeleteCategoryEvent extends CategoryEvent {
  final int id;

  const DeleteCategoryEvent(this.id);

  @override
  List<Object?> get props => [id];
}
