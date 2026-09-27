import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/pos_repository.dart';
import '../../domain/usecases/get_products_usecase.dart';
import 'pos_catalog_event.dart';
import 'pos_catalog_state.dart';

class PosCatalogBloc extends Bloc<PosCatalogEvent, PosCatalogState> {
  final GetProductsUseCase getProductsUseCase;
  final PosRepository repository; // Needed for getCategories, or create GetCategoriesUseCase

  PosCatalogBloc({
    required this.getProductsUseCase,
    required this.repository,
  }) : super(PosCatalogInitial()) {
    on<LoadCatalogEvent>(_onLoadCatalog);
    on<SearchProductEvent>(_onSearchProduct);
    on<FilterByCategoryEvent>(_onFilterByCategory);
    on<FilterByUnitEvent>(_onFilterByUnit);
  }

  Future<void> _onLoadCatalog(
    LoadCatalogEvent event,
    Emitter<PosCatalogState> emit,
  ) async {
    emit(PosCatalogLoading());

    // Fetch Categories
    final categoriesResult = await repository.getCategories();
    
    // Fetch Initial Products
    final productsResult = await getProductsUseCase.execute();

    categoriesResult.fold(
      (failure) => emit(PosCatalogError(message: failure.message)),
      (categories) {
        productsResult.fold(
          (failure) => emit(PosCatalogError(message: failure.message)),
          (products) {
            emit(PosCatalogLoaded(
              categories: categories,
              products: products,
            ));
          },
        );
      },
    );
  }

  Future<void> _onSearchProduct(
    SearchProductEvent event,
    Emitter<PosCatalogState> emit,
  ) async {
    if (state is PosCatalogLoaded) {
      final currentState = state as PosCatalogLoaded;
      // Removed emit(PosCatalogLoading()) so the search bar doesn't lose focus

      final productsResult = await getProductsUseCase.execute(
        searchTerm: event.query,
        categoryId: currentState.selectedCategoryId,
      );

      productsResult.fold(
        (failure) => emit(PosCatalogError(message: failure.message)),
        (products) {
          emit(currentState.copyWith(
            products: products,
            searchQuery: event.query,
          ));
        },
      );
    }
  }

  Future<void> _onFilterByCategory(
    FilterByCategoryEvent event,
    Emitter<PosCatalogState> emit,
  ) async {
    if (state is PosCatalogLoaded) {
      final currentState = state as PosCatalogLoaded;
      // Removed emit(PosCatalogLoading()) to avoid screen flashing

      final productsResult = await getProductsUseCase.execute(
        searchTerm: currentState.searchQuery,
        categoryId: event.categoryId,
      );

      productsResult.fold(
        (failure) => emit(PosCatalogError(message: failure.message)),
        (products) {
          emit(currentState.copyWith(
            products: products,
            selectedCategoryId: event.categoryId,
            clearCategoryFilter: event.categoryId == null,
            clearUnitFilter: true, // Reset unit filter when category changes
          ));
        },
      );
    }
  }

  void _onFilterByUnit(
    FilterByUnitEvent event,
    Emitter<PosCatalogState> emit,
  ) {
    if (state is PosCatalogLoaded) {
      final currentState = state as PosCatalogLoaded;
      if (event.unitName == null) {
        emit(currentState.copyWith(clearUnitFilter: true));
      } else {
        emit(currentState.copyWith(selectedUnitName: event.unitName));
      }
    }
  }
}
