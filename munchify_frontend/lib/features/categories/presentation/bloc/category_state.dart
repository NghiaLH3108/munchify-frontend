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
  final bool isListEnd;
  final String? successMessage;

  const CategoryLoaded({
    required this.categories,
    this.isListEnd = false,
    this.successMessage,
  });

  @override
  List<Object?> get props => [categories, isListEnd, successMessage];
}

class CategoryError extends CategoryState {
  final String message;

  const CategoryError(this.message);

  @override
  List<Object?> get props => [message];
}
