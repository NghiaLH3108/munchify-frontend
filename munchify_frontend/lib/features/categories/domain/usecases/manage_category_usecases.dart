import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/Failures.dart';
import '../entities/category_entity.dart';
import '../repositories/category_repository.dart';

class GetCategoriesUseCase {
  final CategoryRepository repository;

  GetCategoriesUseCase(this.repository);

  Future<Either<Failure, List<CategoryEntity>>> call({
    String searchTerm = '',
    bool? isActive,
    int page = 1,
    int pageSize = 10,
  }) async {
    return await repository.getCategories(
      searchTerm: searchTerm,
      isActive: isActive,
      page: page,
      pageSize: pageSize,
    );
  }
}

class CreateCategoryUseCase {
  final CategoryRepository repository;

  CreateCategoryUseCase(this.repository);

  Future<Either<Failure, CategoryEntity>> call({
    required String categoryName,
    String? description,
    required bool isActive,
  }) async {
    return await repository.createCategory(
      categoryName: categoryName,
      description: description,
      isActive: isActive,
    );
  }
}

class UpdateCategoryUseCase {
  final CategoryRepository repository;

  UpdateCategoryUseCase(this.repository);

  Future<Either<Failure, CategoryEntity>> call({
    required int id,
    required String categoryName,
    String? description,
    required bool isActive,
  }) async {
    return await repository.updateCategory(
      id: id,
      categoryName: categoryName,
      description: description,
      isActive: isActive,
    );
  }
}

class DeleteCategoryUseCase {
  final CategoryRepository repository;

  DeleteCategoryUseCase(this.repository);

  Future<Either<Failure, bool>> call(int id) async {
    return await repository.deleteCategory(id);
  }
}
