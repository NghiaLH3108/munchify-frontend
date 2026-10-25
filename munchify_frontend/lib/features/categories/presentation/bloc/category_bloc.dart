import 'package:flutter_bloc/flutter_bloc.dart';
import 'category_event.dart';
import 'category_state.dart';
import '../../domain/usecases/manage_category_usecases.dart';

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final GetCategoriesUseCase getCategories;
  final CreateCategoryUseCase createCategory;
  final UpdateCategoryUseCase updateCategory;
  final DeleteCategoryUseCase deleteCategory;

  CategoryBloc({
    required this.getCategories,
    required this.createCategory,
    required this.updateCategory,
    required this.deleteCategory,
  }) : super(CategoryInitial()) {
    on<LoadCategoriesEvent>(_onLoadCategories);
    on<CreateCategoryEvent>(_onCreateCategory);
    on<UpdateCategoryEvent>(_onUpdateCategory);
    on<DeleteCategoryEvent>(_onDeleteCategory);
  }

  Future<void> _onLoadCategories(
    LoadCategoriesEvent event,
    Emitter<CategoryState> emit,
  ) async {
    final currentState = state;
    if (currentState is CategoryLoaded) {
      emit(CategoryLoaded(
        categories: currentState.categories,
        allCategories: currentState.allCategories,
        isListEnd: currentState.isListEnd,
        isRefreshing: true,
      ));
    } else {
      emit(CategoryLoading());
    }

    final result = await getCategories(
      searchTerm: event.searchTerm,
      isActive: event.isActive,
      page: event.page,
      pageSize: event.pageSize,
    );

    result.fold(
      (failure) => emit(CategoryError(failure.message)),
      (categories) {
        final isUnfiltered = event.isActive == null &&
            event.searchTerm.trim().isEmpty &&
            event.page == 1;
        final prevAll =
            currentState is CategoryLoaded ? currentState.allCategories : null;
        emit(CategoryLoaded(
          categories: categories,
          allCategories: isUnfiltered ? categories : (prevAll ?? categories),
          isListEnd: categories.length < event.pageSize,
          isRefreshing: false,
        ));
      },
    );
  }

  Future<void> _onCreateCategory(
    CreateCategoryEvent event,
    Emitter<CategoryState> emit,
  ) async {
    final currentState = state;

    final result = await createCategory(
      categoryName: event.categoryName,
      description: event.description,
      isActive: event.isActive,
    );

    result.fold(
      (failure) => emit(CategoryError(failure.message)),
      (newCategory) {
        if (currentState is CategoryLoaded) {
          final updatedAll = [
            newCategory,
            ...(currentState.allCategories ?? currentState.categories),
          ];
          emit(CategoryLoaded(
            categories: [newCategory, ...currentState.categories],
            allCategories: updatedAll,
            isListEnd: currentState.isListEnd,
            isRefreshing: false,
            successMessage: 'Đã thêm danh mục thành công.',
          ));
        } else {
          emit(CategoryLoaded(
            categories: [newCategory],
            allCategories: [newCategory],
            successMessage: 'Đã thêm danh mục thành công.',
          ));
        }
      },
    );
  }

  Future<void> _onUpdateCategory(
    UpdateCategoryEvent event,
    Emitter<CategoryState> emit,
  ) async {
    final currentState = state;

    final result = await updateCategory(
      id: event.id,
      categoryName: event.categoryName,
      description: event.description,
      isActive: event.isActive,
    );

    result.fold(
      (failure) => emit(CategoryError(failure.message)),
      (updatedCategory) {
        if (currentState is CategoryLoaded) {
          final updatedCategories = currentState.categories.map((c) {
            return c.id == updatedCategory.id ? updatedCategory : c;
          }).toList();
          final updatedAll =
              (currentState.allCategories ?? currentState.categories).map((c) {
            return c.id == updatedCategory.id ? updatedCategory : c;
          }).toList();

          emit(CategoryLoaded(
            categories: updatedCategories,
            allCategories: updatedAll,
            isListEnd: currentState.isListEnd,
            isRefreshing: false,
            successMessage: 'Đã cập nhật danh mục thành công.',
          ));
        } else {
          emit(CategoryLoaded(
            categories: [updatedCategory],
            allCategories: [updatedCategory],
            successMessage: 'Đã cập nhật danh mục thành công.',
          ));
        }
      },
    );
  }

  Future<void> _onDeleteCategory(
    DeleteCategoryEvent event,
    Emitter<CategoryState> emit,
  ) async {
    final currentState = state;

    final result = await deleteCategory(event.id);

    result.fold(
      (failure) => emit(CategoryError(failure.message)),
      (success) {
        if (currentState is CategoryLoaded) {
          final updatedCategories =
              currentState.categories.where((c) => c.id != event.id).toList();
          final updatedAll =
              (currentState.allCategories ?? currentState.categories)
                  .where((c) => c.id != event.id)
                  .toList();

          emit(CategoryLoaded(
            categories: updatedCategories,
            allCategories: updatedAll,
            isListEnd: currentState.isListEnd,
            isRefreshing: false,
            successMessage: 'Đã xóa danh mục.',
          ));
        } else {
          emit(const CategoryLoaded(
            categories: [],
            allCategories: [],
            successMessage: 'Đã xóa danh mục.',
          ));
        }
      },
    );
  }
}
