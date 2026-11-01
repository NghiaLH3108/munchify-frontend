import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:munchify_frontend/core/errors/Failures.dart';
import 'package:munchify_frontend/features/products/data/models/product_request_model.dart';
import 'package:munchify_frontend/features/products/domain/entities/product_entity.dart';
import 'package:munchify_frontend/features/products/domain/repositories/product_repository.dart';
import 'package:munchify_frontend/features/products/domain/usecases/get_products_usecase.dart';
import 'package:munchify_frontend/features/products/domain/usecases/toggle_product_status_usecase.dart';
import 'package:munchify_frontend/features/products/presentation/bloc/product_admin_bloc.dart';
import 'package:munchify_frontend/features/products/presentation/bloc/product_admin_event.dart';
import 'package:munchify_frontend/features/products/presentation/bloc/product_admin_state.dart';

class MockProductRepository implements ProductRepository {
  Either<Failure, List<ProductEntity>>? getProductsResult;
  Either<Failure, void>? toggleProductStatusResult;

  @override
  Future<Either<Failure, List<ProductEntity>>> getProducts({
    String? search,
    String? categoryId,
    bool? isActive,
    bool? lowStockWarning,
  }) async {
    return getProductsResult!;
  }

  @override
  Future<Either<Failure, void>> toggleProductStatus(String id, bool isActive) async {
    return toggleProductStatusResult!;
  }

  @override
  Future<Either<Failure, ProductEntity>> addProduct(ProductRequestModel request) {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, ProductEntity>> updateProduct(String id, ProductRequestModel request) {
    throw UnimplementedError();
  }
}

void main() {
  late ProductAdminBloc bloc;
  late MockProductRepository mockRepo;
  late GetProductsUseCase getProductsUseCase;
  late ToggleProductStatusUseCase toggleProductStatusUseCase;

  setUp(() {
    mockRepo = MockProductRepository();
    getProductsUseCase = GetProductsUseCase(mockRepo);
    toggleProductStatusUseCase = ToggleProductStatusUseCase(mockRepo);
    bloc = ProductAdminBloc(
      getProductsUseCase: getProductsUseCase,
      toggleProductStatusUseCase: toggleProductStatusUseCase,
    );
  });

  tearDown(() {
    bloc.close();
  });

  const tProduct1 = ProductEntity(
    id: 'prod-001',
    sku: 'SKU-001',
    name: 'Cà phê đá',
    imageUrl: 'https://example.com/cf.jpg',
    categoryId: 'cat-01',
    categoryName: 'Đồ uống',
    unitId: 'unit-01',
    unitName: 'Ly',
    price: 25000,
    stockQuantity: 50,
    minStockLevel: 10,
    isActive: true,
    description: 'Cà phê nguyên chất',
    showOnPos: true,
    autoPrintKitchen: true,
  );

  const tProduct2 = ProductEntity(
    id: 'prod-002',
    sku: 'SKU-002',
    name: 'Trà đào cam sả',
    imageUrl: 'https://example.com/tra.jpg',
    categoryId: 'cat-01',
    categoryName: 'Đồ uống',
    unitId: 'unit-01',
    unitName: 'Ly',
    price: 35000,
    stockQuantity: 20,
    minStockLevel: 5,
    isActive: false,
    description: 'Trà đào thanh mát',
    showOnPos: true,
    autoPrintKitchen: true,
  );

  final tInitialLoadedState = ProductAdminLoaded(
    products: const [tProduct1, tProduct2],
    totalSkus: 2,
    activeCount: 1,
    lowStockCount: 0,
  );

  group('ProductAdminBloc - ToggleProductStatusEvent', () {
    test(
        'emits optimistic loaded state then loaded state with successMessage when API succeeds (deactivating product)',
        () async {
      // Arrange
      mockRepo.toggleProductStatusResult = const Right(null);
      // Pre-seed state
      bloc.emit(tInitialLoadedState);

      // Assert expectations
      final expectedStates = [
        // 1. Optimistic update: isActive = false, activeCount decremented to 0
        isA<ProductAdminLoaded>()
            .having((s) => s.products.first.isActive, 'product1.isActive', false)
            .having((s) => s.activeCount, 'activeCount', 0)
            .having((s) => s.successMessage, 'successMessage', isNull)
            .having((s) => s.errorMessage, 'errorMessage', isNull),
        // 2. Success state after API response: successMessage is not null
        isA<ProductAdminLoaded>()
            .having((s) => s.products.first.isActive, 'product1.isActive', false)
            .having((s) => s.successMessage, 'successMessage', isNotNull)
            .having((s) => s.successMessage, 'successMessage content',
                contains('Ngừng bán'))
            .having((s) => s.errorMessage, 'errorMessage', isNull),
      ];

      expectLater(bloc.stream, emitsInOrder(expectedStates));

      // Act
      bloc.add(const ToggleProductStatusEvent('prod-001', false));
    });

    test(
        'emits optimistic loaded state then loaded state with successMessage when API succeeds (activating product)',
        () async {
      // Arrange
      mockRepo.toggleProductStatusResult = const Right(null);
      bloc.emit(tInitialLoadedState);

      final expectedStates = [
        // Optimistic update
        isA<ProductAdminLoaded>()
            .having((s) => s.products[1].isActive, 'product2.isActive', true)
            .having((s) => s.activeCount, 'activeCount', 2)
            .having((s) => s.successMessage, 'successMessage', isNull),
        // Success state
        isA<ProductAdminLoaded>()
            .having((s) => s.products[1].isActive, 'product2.isActive', true)
            .having((s) => s.successMessage, 'successMessage', isNotNull)
            .having((s) => s.successMessage, 'successMessage content',
                contains('Đang bán'))
            .having((s) => s.errorMessage, 'errorMessage', isNull),
      ];

      expectLater(bloc.stream, emitsInOrder(expectedStates));

      // Act
      bloc.add(const ToggleProductStatusEvent('prod-002', true));
    });

    test(
        'emits optimistic loaded state then reverts to original loaded state with errorMessage on API failure',
        () async {
      // Arrange
      const tFailureMessage = 'Không thể cập nhật trạng thái sản phẩm do lỗi máy chủ';
      mockRepo.toggleProductStatusResult =
          const Left(ServerFailure(message: tFailureMessage));
      bloc.emit(tInitialLoadedState);

      final expectedStates = [
        // 1. Optimistic update: product1 becomes false temporarily
        isA<ProductAdminLoaded>()
            .having((s) => s.products.first.isActive, 'product1.isActive', false)
            .having((s) => s.activeCount, 'activeCount', 0),
        // 2. Revert update on failure: product1 restored to true, products preserved, errorMessage not null
        isA<ProductAdminLoaded>()
            .having((s) => s.products.length, 'products.length preserved', 2)
            .having((s) => s.products.first.isActive, 'product1.isActive reverted', true)
            .having((s) => s.activeCount, 'activeCount reverted', 1)
            .having((s) => s.errorMessage, 'errorMessage', tFailureMessage)
            .having((s) => s.successMessage, 'successMessage', isNull),
      ];

      expectLater(bloc.stream, emitsInOrder(expectedStates));

      // Act
      bloc.add(const ToggleProductStatusEvent('prod-001', false));
    });

    test('does nothing when state is not ProductAdminLoaded', () async {
      // Initial state is ProductAdminInitial
      expect(bloc.state, isA<ProductAdminInitial>());

      // Expect no states emitted
      expectLater(bloc.stream, emitsDone);

      // Act
      bloc.add(const ToggleProductStatusEvent('prod-001', false));
      await bloc.close();
    });
  });
}
