import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/Failures.dart';
import '../entities/category_entity.dart';

abstract class CategoryRepository {
  Future<Either<Failure, List<CategoryEntity>>> getCategories({
    String searchTerm = '',
    bool? isActive,
    int page = 1,
    int pageSize = 10,
  });

  Future<Either<Failure, CategoryEntity>> getCategoryById(int id);

  Future<Either<Failure, CategoryEntity>> createCategory({
    required String categoryName,
    String? description,
    required bool isActive,
  });

  Future<Either<Failure, CategoryEntity>> updateCategory({
    required int id,
    required String categoryName,
    String? description,
    required bool isActive,
  });

  Future<Either<Failure, bool>> deleteCategory(int id);
}
