import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/usecases/get_products_usecase.dart';
import '../../domain/usecases/toggle_product_status_usecase.dart';
import 'product_admin_event.dart';
import 'product_admin_state.dart';

class ProductAdminBloc extends Bloc<ProductAdminEvent, ProductAdminState> {
  final GetProductsUseCase getProductsUseCase;
  final ToggleProductStatusUseCase toggleProductStatusUseCase;

  int? _baselineTotalSkus;
  int? _baselineActiveCount;
  int? _baselineLowStockCount;

  ProductAdminBloc({
    required this.getProductsUseCase,
    required this.toggleProductStatusUseCase,
  }) : super(ProductAdminInitial()) {
    on<LoadProductsEvent>(_onLoadProducts);
    on<ToggleProductStatusEvent>(_onToggleProductStatus);
  }

  Future<void> _onLoadProducts(
    LoadProductsEvent event,
    Emitter<ProductAdminState> emit,
  ) async {
    if (state is! ProductAdminLoaded) {
      emit(ProductAdminLoading());
    }
    final result = await getProductsUseCase(
      search: event.search,
      categoryId: event.categoryId,
      isActive: event.isActive,
      lowStockWarning: event.lowStockWarning,
    );

    result.fold(
      (failure) => emit(ProductAdminError(failure.message)),
      (products) {
        final isUnfiltered = (event.search == null || event.search!.trim().isEmpty) &&
            (event.categoryId == null || event.categoryId!.isEmpty) &&
            event.isActive == null &&
            (event.lowStockWarning == null || !event.lowStockWarning!);

        if (isUnfiltered || _baselineTotalSkus == null) {
          _baselineTotalSkus = products.length;
          _baselineActiveCount = products.where((p) => p.isActive).length;
          _baselineLowStockCount =
              products.where((p) => p.stockQuantity <= p.minStockLevel).length;
        }

        emit(ProductAdminLoaded(
          products: products,
          totalSkus: _baselineTotalSkus ?? products.length,
          activeCount:
              _baselineActiveCount ?? products.where((p) => p.isActive).length,
          lowStockCount: _baselineLowStockCount ??
              products.where((p) => p.stockQuantity <= p.minStockLevel).length,
        ));
      },
    );
  }

  Future<void> _onToggleProductStatus(
    ToggleProductStatusEvent event,
    Emitter<ProductAdminState> emit,
  ) async {
    if (state is ProductAdminLoaded) {
      final currentState = state as ProductAdminLoaded;

      // Optimistic update
      final updatedProducts = currentState.products.map((p) {
        if (p.id == event.productId) {
          return ProductEntity(
            id: p.id,
            sku: p.sku,
            name: p.name,
            imageUrl: p.imageUrl,
            categoryId: p.categoryId,
            categoryName: p.categoryName,
            unitId: p.unitId,
            unitName: p.unitName,
            price: p.price,
            stockQuantity: p.stockQuantity,
            minStockLevel: p.minStockLevel,
            isActive: event.isActive,
            description: p.description,
            showOnPos: p.showOnPos,
            autoPrintKitchen: p.autoPrintKitchen,
          );
        }
        return p;
      }).toList();

      final delta = event.isActive ? 1 : -1;
      final nextActiveCount =
          ((_baselineActiveCount ?? currentState.activeCount) + delta)
              .clamp(0, currentState.totalSkus);
      _baselineActiveCount = nextActiveCount;

      emit(ProductAdminLoaded(
        products: updatedProducts,
        totalSkus: currentState.totalSkus,
        activeCount: nextActiveCount,
        lowStockCount: currentState.lowStockCount,
      ));

      // Call API
      final result =
          await toggleProductStatusUseCase(event.productId, event.isActive);
      result.fold(
        (failure) {
          // Revert on failure
          _baselineActiveCount = currentState.activeCount;
          emit(currentState);
          emit(ProductAdminError(failure.message));
        },
        (_) {},
      );
    }
  }
}
