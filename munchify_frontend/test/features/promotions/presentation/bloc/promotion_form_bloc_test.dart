import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:munchify_frontend/core/errors/Failures.dart';
import 'package:munchify_frontend/core/utils/PagedResult.dart';
import 'package:munchify_frontend/features/products/data/models/product_request_model.dart';
import 'package:munchify_frontend/features/products/domain/entities/product_entity.dart';
import 'package:munchify_frontend/features/products/domain/repositories/product_repository.dart';
import 'package:munchify_frontend/features/products/domain/usecases/get_products_usecase.dart';
import 'package:munchify_frontend/features/promotions/domain/entities/promotion_entity.dart';
import 'package:munchify_frontend/features/promotions/domain/repositories/promotion_repository.dart';
import 'package:munchify_frontend/features/promotions/domain/usecases/create_promotion_usecase.dart';
import 'package:munchify_frontend/features/promotions/domain/usecases/update_promotion_usecase.dart';
import 'package:munchify_frontend/features/promotions/presentation/bloc/promotion_form_bloc.dart';
import 'package:munchify_frontend/features/promotions/presentation/bloc/promotion_form_event.dart';
import 'package:munchify_frontend/features/promotions/presentation/bloc/promotion_form_state.dart';

class MockProductRepository implements ProductRepository {
  Either<Failure, List<ProductEntity>> result = const Right([]);

  @override
  Future<Either<Failure, List<ProductEntity>>> getProducts({
    String? search,
    String? categoryId,
    bool? isActive,
    bool? lowStockWarning,
  }) async {
    return result;
  }

  @override
  Future<Either<Failure, ProductEntity>> addProduct(ProductRequestModel request) async {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, ProductEntity>> updateProduct(String id, ProductRequestModel request) async {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, void>> toggleProductStatus(String id, bool isActive) async {
    throw UnimplementedError();
  }
}

class MockPromotionRepository implements PromotionRepository {
  @override
  Future<Either<Failure, PagedResult<PromotionEntity>>> getPromotions(
      int pageIndex, int pageSize, String? searchKeyword) async {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, PromotionDetailEntity>> getPromotionById(String id) async {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, PromotionDetailEntity>> createPromotion(Map<String, dynamic> data) async {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, PromotionDetailEntity>> updatePromotion(String id, Map<String, dynamic> data) async {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, bool>> togglePromotionStatus(String id) async {
    throw UnimplementedError();
  }
}

void main() {
  late PromotionFormBloc bloc;
  late MockProductRepository mockProductRepo;
  late MockPromotionRepository mockPromotionRepo;
  late GetProductsUseCase getProductsUseCase;
  late CreatePromotionUseCase createPromotionUseCase;
  late UpdatePromotionUseCase updatePromotionUseCase;

  setUp(() {
    mockProductRepo = MockProductRepository();
    mockPromotionRepo = MockPromotionRepository();
    getProductsUseCase = GetProductsUseCase(mockProductRepo);
    createPromotionUseCase = CreatePromotionUseCase(mockPromotionRepo);
    updatePromotionUseCase = UpdatePromotionUseCase(mockPromotionRepo);

    bloc = PromotionFormBloc(
      createPromotionUseCase: createPromotionUseCase,
      updatePromotionUseCase: updatePromotionUseCase,
      getProductsUseCase: getProductsUseCase,
    );
  });

  tearDown(() {
    bloc.close();
  });

  const tProduct = ProductEntity(
    id: '1',
    sku: 'SKU01',
    name: 'Bánh tráng phơi sương',
    categoryId: '1',
    unitId: '1',
    price: 35000,
    stockQuantity: 100,
    minStockLevel: 10,
    isActive: true,
    showOnPos: true,
    autoPrintKitchen: false,
  );

  test('initial state should be PromotionFormInitial', () {
    expect(bloc.state, equals(PromotionFormInitial()));
  });

  group('LoadPromotionProducts', () {
    test('emits [PromotionFormProductsLoading, PromotionFormProductsLoaded] when getProductsUseCase succeeds', () async {
      mockProductRepo.result = const Right([tProduct]);

      final expected = [
        PromotionFormProductsLoading(),
        const PromotionFormProductsLoaded([tProduct]),
      ];

      expectLater(bloc.stream, emitsInOrder(expected));
      bloc.add(const LoadPromotionProducts());
    });

    test('emits [PromotionFormProductsLoading, PromotionFormError] when getProductsUseCase fails', () async {
      mockProductRepo.result = const Left(ServerFailure(message: 'Lỗi kết nối cơ sở dữ liệu'));

      final expected = [
        PromotionFormProductsLoading(),
        const PromotionFormError('Lỗi kết nối cơ sở dữ liệu'),
      ];

      expectLater(bloc.stream, emitsInOrder(expected));
      bloc.add(const LoadPromotionProducts());
    });
  });
}
