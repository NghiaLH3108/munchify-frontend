import 'package:equatable/equatable.dart';
import '../../domain/entities/category_entity.dart';

abstract class CategoryState extends Equatable {
  const CategoryState();

  @override
  List<Object?> get props => [];
}

class CategoryInitial extends CategoryState {}

class CategoryLoading extends CategoryState {}

class CategoryLoaded extends CategoryState {
  final List<CategoryEntity> categories;
  final List<CategoryEntity>? allCategories;
  final bool isListEnd;
  final bool isRefreshing;
  final String? successMessage;

  const CategoryLoaded({
    required this.categories,
    this.allCategories,
    this.isListEnd = false,
    this.isRefreshing = false,
    this.successMessage,
  });

  List<CategoryEntity> get kpiCategories => allCategories ?? categories;

  @override
  List<Object?> get props => [
        categories,
        allCategories,
        isListEnd,
        isRefreshing,
        successMessage,
      ];
}

class CategoryError extends CategoryState {
  final String message;

  const CategoryError(this.message);

  @override
  List<Object?> get props => [message];
}
