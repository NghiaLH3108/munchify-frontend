import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:munchify_frontend/core/errors/Failures.dart';
import 'package:munchify_frontend/core/utils/PagedResult.dart';
import 'package:munchify_frontend/features/promotions/domain/entities/promotion_entity.dart';
import 'package:munchify_frontend/features/promotions/domain/repositories/promotion_repository.dart';
import 'package:munchify_frontend/features/promotions/domain/usecases/get_promotions_usecase.dart';
import 'package:munchify_frontend/features/promotions/domain/usecases/toggle_promotion_status_usecase.dart';
import 'package:munchify_frontend/features/promotions/presentation/bloc/promotion_admin_bloc.dart';
import 'package:munchify_frontend/features/promotions/presentation/bloc/promotion_admin_event.dart';
import 'package:munchify_frontend/features/promotions/presentation/bloc/promotion_admin_state.dart';

class MockPromotionRepository implements PromotionRepository {
  Either<Failure, PagedResult<PromotionEntity>>? getPromotionsResult;
  Either<Failure, bool>? toggleStatusResult;
  int getPromotionsCallCount = 0;
  String? lastSearchKeywordPassed;

  @override
  Future<Either<Failure, PagedResult<PromotionEntity>>> getPromotions(
      int pageIndex, int pageSize, String? searchKeyword) async {
    getPromotionsCallCount++;
    lastSearchKeywordPassed = searchKeyword;
    return getPromotionsResult!;
  }

  @override
  Future<Either<Failure, bool>> togglePromotionStatus(String id) async {
    return toggleStatusResult!;
  }

  @override
  Future<Either<Failure, PromotionDetailEntity>> getPromotionById(String id) {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, PromotionDetailEntity>> createPromotion(
      Map<String, dynamic> data) {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, PromotionDetailEntity>> updatePromotion(
      String id, Map<String, dynamic> data) {
    throw UnimplementedError();
  }
}

void main() {
  late PromotionAdminBloc bloc;
  late MockPromotionRepository mockRepo;
  late GetPromotionsUseCase getPromotionsUseCase;
  late TogglePromotionStatusUseCase togglePromotionStatusUseCase;

  setUp(() {
    mockRepo = MockPromotionRepository();
    getPromotionsUseCase = GetPromotionsUseCase(mockRepo);
    togglePromotionStatusUseCase = TogglePromotionStatusUseCase(mockRepo);
    bloc = PromotionAdminBloc(
      getPromotionsUseCase: getPromotionsUseCase,
      togglePromotionStatusUseCase: togglePromotionStatusUseCase,
    );
  });

  tearDown(() {
    bloc.close();
  });

  final tPromotion = PromotionEntity(
    promotionId: 101,
    promotionCode: 'SUMMER2026',
    promotionName: 'Khuyến mãi hè rực rỡ',
    discountType: 'PERCENTAGE',
    discountValue: 15,
    startDate: DateTime(2026, 6, 1),
    endDate: DateTime(2026, 8, 31),
    isActive: true,
  );

  final tPagedResult = PagedResult<PromotionEntity>(
    items: [tPromotion],
    totalCount: 1,
    pageNumber: 1,
    pageSize: 10,
  );

  group('PromotionAdminBloc - TogglePromotionStatus', () {
    test(
        'emits [PromotionAdminLoading, PromotionsLoaded] with non-null successMessage when toggling status succeeds from initial state',
        () async {
      // Arrange
      mockRepo.toggleStatusResult = const Right(true);
      mockRepo.getPromotionsResult = Right(tPagedResult);

      final expectedStates = [
        isA<PromotionAdminLoading>(),
        isA<PromotionsLoaded>()
            .having((s) => s.successMessage, 'successMessage', isNotNull)
            .having((s) => s.successMessage, 'successMessage content',
                'Đã cập nhật trạng thái chương trình khuyến mãi.')
            .having((s) => s.promotionsData.items.length, 'items.length', 1),
      ];

      expectLater(bloc.stream, emitsInOrder(expectedStates));

      // Act
      bloc.add(const TogglePromotionStatus(
        id: '101',
        pageIndex: 1,
        pageSize: 10,
      ));
    });

    test(
        'emits isRefreshing state then PromotionsLoaded with non-null successMessage when list was previously loaded',
        () async {
      // Arrange
      mockRepo.getPromotionsResult = Right(tPagedResult);
      mockRepo.toggleStatusResult = const Right(true);

      // Pre-load data to populate _lastLoadedState in bloc
      bloc.add(const LoadPromotions(pageIndex: 1, pageSize: 10));
      await expectLater(
        bloc.stream,
        emitsInOrder([
          isA<PromotionAdminLoading>(),
          isA<PromotionsLoaded>(),
        ]),
      );

      // Prepare expectations for toggle action
      final expectedStates = [
        isA<PromotionsLoaded>().having((s) => s.isRefreshing, 'isRefreshing', true),
        isA<PromotionsLoaded>()
            .having((s) => s.isRefreshing, 'isRefreshing', false)
            .having((s) => s.successMessage, 'successMessage', isNotNull)
            .having((s) => s.successMessage, 'successMessage content',
                'Đã cập nhật trạng thái chương trình khuyến mãi.'),
      ];

      expectLater(bloc.stream, emitsInOrder(expectedStates));

      // Act
      bloc.add(const TogglePromotionStatus(
        id: '101',
        pageIndex: 1,
        pageSize: 10,
      ));
    });

    test(
        'preserves searchKeyword and pageIndex when reloading after status toggle',
        () async {
      // Arrange
      const tSearch = 'SUMMER';
      const tPage = 2;
      mockRepo.getPromotionsResult = Right(tPagedResult);
      mockRepo.toggleStatusResult = const Right(true);

      final expectedStates = [
        isA<PromotionAdminLoading>(),
        isA<PromotionsLoaded>()
            .having((s) => s.searchKeyword, 'searchKeyword', tSearch)
            .having((s) => s.pageIndex, 'pageIndex', tPage)
            .having((s) => s.successMessage, 'successMessage', isNotNull),
      ];

      expectLater(bloc.stream, emitsInOrder(expectedStates));

      // Act
      bloc.add(const TogglePromotionStatus(
        id: '101',
        pageIndex: tPage,
        pageSize: 10,
        searchKeyword: tSearch,
      ));
    });

    test(
        'emits PromotionAdminError when togglePromotionStatus fails on API level',
        () async {
      // Arrange
      const tErrorMessage = 'Lỗi hệ thống: Không thể cập nhật trạng thái khuyến mãi';
      mockRepo.toggleStatusResult =
          const Left(ServerFailure(message: tErrorMessage));

      final expectedStates = [
        isA<PromotionAdminError>()
            .having((s) => s.message, 'message', tErrorMessage),
      ];

      expectLater(bloc.stream, emitsInOrder(expectedStates));

      // Act
      bloc.add(const TogglePromotionStatus(
        id: '101',
        pageIndex: 1,
        pageSize: 10,
      ));
    });
  });
}
