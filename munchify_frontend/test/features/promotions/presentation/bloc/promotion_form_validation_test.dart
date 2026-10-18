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

class MockPromotionRepositoryForValidation implements PromotionRepository {
  Either<Failure, PromotionDetailEntity>? result;

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
    return result ?? const Left(ServerFailure(message: 'Error'));
  }

  @override
  Future<Either<Failure, PromotionDetailEntity>> updatePromotion(String id, Map<String, dynamic> data) async {
    return result ?? const Left(ServerFailure(message: 'Error'));
  }

  @override
  Future<Either<Failure, bool>> togglePromotionStatus(String id) async {
    throw UnimplementedError();
  }
}

class MockProductRepoDummy implements ProductRepository {
  @override
  Future<Either<Failure, List<ProductEntity>>> getProducts({
    String? search,
    String? categoryId,
    bool? isActive,
    bool? lowStockWarning,
  }) async {
    return const Right([]);
  }

  @override
  Future<Either<Failure, ProductEntity>> addProduct(ProductRequestModel request) async => throw UnimplementedError();

  @override
  Future<Either<Failure, ProductEntity>> updateProduct(String id, ProductRequestModel request) async => throw UnimplementedError();

  @override
  Future<Either<Failure, void>> toggleProductStatus(String id, bool isActive) async => throw UnimplementedError();
}

void main() {
  late PromotionFormBloc bloc;
  late MockPromotionRepositoryForValidation mockPromoRepo;
  late MockProductRepoDummy mockProductRepo;
  late GetProductsUseCase getProductsUseCase;
  late CreatePromotionUseCase createPromotionUseCase;
  late UpdatePromotionUseCase updatePromotionUseCase;

  setUp(() {
    mockPromoRepo = MockPromotionRepositoryForValidation();
    mockProductRepo = MockProductRepoDummy();
    getProductsUseCase = GetProductsUseCase(mockProductRepo);
    createPromotionUseCase = CreatePromotionUseCase(mockPromoRepo);
    updatePromotionUseCase = UpdatePromotionUseCase(mockPromoRepo);

    bloc = PromotionFormBloc(
      createPromotionUseCase: createPromotionUseCase,
      updatePromotionUseCase: updatePromotionUseCase,
      getProductsUseCase: getProductsUseCase,
    );
  });

  tearDown(() {
    bloc.close();
  });

  final dummyDetail = PromotionDetailEntity(
    promotionId: 1,
    promotionCode: 'SALE10',
    promotionName: 'Giảm 10%',
    description: '',
    discountType: 'PERCENTAGE',
    discountValue: 10.0,
    minimumOrderAmount: 0.0,
    startDate: DateTime(2026, 12, 1),
    endDate: DateTime(2026, 12, 31),
    isActive: true,
    products: const [],
  );

  group('ValidatePromotionForm Events', () {
    test('emits PromotionFormValidationFailed when startDate is in the past', () async {
      final pastDate = DateTime.now().subtract(const Duration(days: 2));

      final expected = [
        const PromotionFormValidationFailed('Ngày bắt đầu không được trong quá khứ.'),
      ];

      expectLater(bloc.stream, emitsInOrder(expected));
      bloc.add(ValidatePromotionForm(startDate: pastDate));
    });

    test('emits PromotionFormValidationFailed when endDate is before or equal to startDate', () async {
      final now = DateTime.now();
      final startDate = DateTime(now.year + 1, 1, 10);
      final endDate = DateTime(now.year + 1, 1, 5);

      final expected = [
        const PromotionFormValidationFailed('Ngày kết thúc phải sau ngày bắt đầu.'),
      ];

      expectLater(bloc.stream, emitsInOrder(expected));
      bloc.add(ValidatePromotionForm(startDate: startDate, endDate: endDate));
    });

    test('emits PromotionFormInitial when date range is valid', () async {
      final now = DateTime.now();
      final startDate = DateTime(now.year + 1, 1, 1);
      final endDate = DateTime(now.year + 1, 1, 31);

      final expected = [
        PromotionFormInitial(),
      ];

      expectLater(bloc.stream, emitsInOrder(expected));
      bloc.add(ValidatePromotionForm(startDate: startDate, endDate: endDate));
    });
  });

  group('SubmitPromotionForm Events', () {
    test('emits [PromotionFormLoading, PromotionFormSuccess] on successful create', () async {
      mockPromoRepo.result = Right(dummyDetail);

      final futureYear = DateTime.now().year + 1;
      final payload = {
        'promotionCode': 'SALE20',
        'promotionName': 'Giảm 20%',
        'startDate': DateTime(futureYear, 5, 1).toIso8601String(),
        'endDate': DateTime(futureYear, 5, 30).toIso8601String(),
      };

      final expected = [
        PromotionFormLoading(),
        PromotionFormSuccess(),
      ];

      expectLater(bloc.stream, emitsInOrder(expected));
      bloc.add(SubmitPromotionForm(data: payload));
    });

    test('emits [PromotionFormLoading, PromotionFormError] when create promotion fails from repository', () async {
      mockPromoRepo.result = const Left(ServerFailure(message: 'Mã khuyến mãi đã tồn tại'));

      final futureYear = DateTime.now().year + 1;
      final payload = {
        'promotionCode': 'DUPLICATE',
        'promotionName': 'Khuyến mãi trùng',
        'startDate': DateTime(futureYear, 5, 1).toIso8601String(),
        'endDate': DateTime(futureYear, 5, 30).toIso8601String(),
      };

      final expected = [
        PromotionFormLoading(),
        const PromotionFormError('Mã khuyến mãi đã tồn tại'),
      ];

      expectLater(bloc.stream, emitsInOrder(expected));
      bloc.add(SubmitPromotionForm(data: payload));
    });

    test('emits [PromotionFormLoading, PromotionFormSuccess] on successful update', () async {
      mockPromoRepo.result = Right(dummyDetail);

      final futureYear = DateTime.now().year + 1;
      final payload = {
        'promotionCode': 'SALE20',
        'promotionName': 'Cập nhật',
        'startDate': DateTime(futureYear, 5, 1).toIso8601String(),
        'endDate': DateTime(futureYear, 5, 30).toIso8601String(),
      };

      final expected = [
        PromotionFormLoading(),
        PromotionFormSuccess(),
      ];

      expectLater(bloc.stream, emitsInOrder(expected));
      bloc.add(SubmitPromotionForm(id: '1', data: payload));
    });

    test('emits [PromotionFormLoading, PromotionFormError] when update promotion dates are invalid', () async {
      final now = DateTime.now();
      final payload = {
        'promotionCode': 'BAD_DATE',
        'promotionName': 'Lỗi ngày',
        'startDate': DateTime(now.year + 1, 5, 30).toIso8601String(),
        'endDate': DateTime(now.year + 1, 5, 1).toIso8601String(),
      };

      final expected = [
        PromotionFormLoading(),
        const PromotionFormError('Ngày kết thúc phải sau ngày bắt đầu.'),
      ];

      expectLater(bloc.stream, emitsInOrder(expected));
      bloc.add(SubmitPromotionForm(id: '1', data: payload));
    });
  });
}
