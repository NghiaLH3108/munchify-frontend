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

  @override
  Future<Either<Failure, PagedResult<PromotionEntity>>> getPromotions(
      int pageIndex, int pageSize, String? searchKeyword) async {
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
  Future<Either<Failure, PromotionDetailEntity>> createPromotion(Map<String, dynamic> data) {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, PromotionDetailEntity>> updatePromotion(String id, Map<String, dynamic> data) {
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
    promotionId: 1,
    promotionCode: 'TEST2026',
    promotionName: 'Giảm 20k',
    discountType: 'FIXED_AMOUNT',
    discountValue: 20000,
    startDate: DateTime(2026, 10, 1),
    endDate: DateTime(2026, 10, 31),
    isActive: true,
  );

  final tPagedResult = PagedResult<PromotionEntity>(
    items: [tPromotion],
    totalCount: 1,
    pageNumber: 1,
    pageSize: 10,
  );

  test('initial state should be PromotionAdminInitial', () {
    expect(bloc.state, isA<PromotionAdminInitial>());
  });

  group('LoadPromotions', () {
    test('emits [PromotionAdminLoading, PromotionsLoaded] on success', () async {
      mockRepo.getPromotionsResult = Right(tPagedResult);

      final expected = [
        isA<PromotionAdminLoading>(),
        isA<PromotionsLoaded>()
            .having((s) => s.promotionsData.items.length, 'items.length', 1)
            .having((s) => s.pageIndex, 'pageIndex', 1),
      ];

      expectLater(bloc.stream, emitsInOrder(expected));
      bloc.add(const LoadPromotions(pageIndex: 1, pageSize: 10));
    });

    test('emits [PromotionAdminLoading, PromotionAdminError] on failure', () async {
      mockRepo.getPromotionsResult = const Left(ServerFailure(message: 'Lỗi server khi lấy khuyến mãi'));

      final expected = [
        isA<PromotionAdminLoading>(),
        isA<PromotionAdminError>().having((s) => s.message, 'message', 'Lỗi server khi lấy khuyến mãi'),
      ];

      expectLater(bloc.stream, emitsInOrder(expected));
      bloc.add(const LoadPromotions(pageIndex: 1, pageSize: 10));
    });
  });

  group('TogglePromotionStatus', () {
    test('emits [PromotionAdminLoading, PromotionsLoaded] on success reload', () async {
      mockRepo.getPromotionsResult = Right(tPagedResult);
      mockRepo.toggleStatusResult = const Right(true);

      // Pre-populate loaded state
      bloc.emit(PromotionsLoaded(
        promotionsData: tPagedResult,
        pageIndex: 1,
      ));

      final expected = [
        isA<PromotionAdminLoading>(),
        isA<PromotionsLoaded>(),
      ];

      expectLater(bloc.stream, emitsInOrder(expected));
      bloc.add(const TogglePromotionStatus(
        id: '1',
        pageIndex: 1,
        pageSize: 10,
      ));
    });

    test('emits PromotionAdminError when toggle fails', () async {
      mockRepo.toggleStatusResult = const Left(ServerFailure(message: 'Không thể đổi trạng thái'));

      final expected = [
        isA<PromotionAdminError>().having((s) => s.message, 'message', 'Không thể đổi trạng thái'),
      ];

      expectLater(bloc.stream, emitsInOrder(expected));
      bloc.add(const TogglePromotionStatus(
        id: '1',
        pageIndex: 1,
        pageSize: 10,
      ));
    });
  });
}
