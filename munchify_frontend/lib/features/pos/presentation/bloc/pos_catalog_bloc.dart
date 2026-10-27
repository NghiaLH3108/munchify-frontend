import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/pos_repository.dart';
import '../../domain/usecases/get_products_usecase.dart';
import '../../domain/usecases/get_combos_usecase.dart';
import 'pos_catalog_event.dart';
import 'pos_catalog_state.dart';

class PosCatalogBloc extends Bloc<PosCatalogEvent, PosCatalogState> {
  final GetProductsUseCase getProductsUseCase;
  final GetCombosUseCase getCombosUseCase;
  final PosRepository repository;

  PosCatalogBloc({
    required this.getProductsUseCase,
    required this.getCombosUseCase,
    required this.repository,
  }) : super(PosCatalogInitial()) {
    on<LoadCatalogEvent>(_onLoadCatalog);
    on<SearchProductEvent>(_onSearchProduct);
    on<FilterByCategoryEvent>(_onFilterByCategory);
    on<FilterByUnitEvent>(_onFilterByUnit);
    on<ToggleLowStockFilterEvent>(_onToggleLowStockFilter);
  }

  Future<void> _onLoadCatalog(
    LoadCatalogEvent event,
    Emitter<PosCatalogState> emit,
  ) async {
    emit(PosCatalogLoading());

    // Khởi chạy song song categories, products đơn và combos (giữ nguyên kiểu từng Either)
    final categoriesFuture = repository.getCategories();
    final productsFuture = getProductsUseCase.execute();
    final combosFuture = getCombosUseCase.execute();

    final categoriesResult = await categoriesFuture;
    final productsResult = await productsFuture;
    final combosResult = await combosFuture;

    categoriesResult.fold(
      (failure) => emit(PosCatalogError(message: failure.message)),
      (categories) {
        productsResult.fold(
          (failure) => emit(PosCatalogError(message: failure.message)),
          (products) {
            emit(PosCatalogLoaded(
              categories: categories,
              products: products,
              // Combo lỗi không làm crash POS — chỉ hiển thị rỗng
              combos: combosResult.getOrElse(() => []),
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
            clearUnitFilter: true,
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

  void _onToggleLowStockFilter(
    ToggleLowStockFilterEvent event,
    Emitter<PosCatalogState> emit,
  ) {
    if (state is PosCatalogLoaded) {
      final currentState = state as PosCatalogLoaded;
      emit(currentState.copyWith(
        isLowStockFilter: !currentState.isLowStockFilter,
      ));
    }
  }
}
