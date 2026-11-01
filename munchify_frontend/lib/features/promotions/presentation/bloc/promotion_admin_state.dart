import 'package:equatable/equatable.dart';
import '../../../../core/utils/PagedResult.dart';
import '../../domain/entities/promotion_entity.dart';

abstract class PromotionAdminState extends Equatable {
  const PromotionAdminState();

  @override
  List<Object?> get props => [];
}

class PromotionAdminInitial extends PromotionAdminState {}

class PromotionAdminLoading extends PromotionAdminState {}

class PromotionsLoaded extends PromotionAdminState {
  final PagedResult<PromotionEntity> promotionsData;
  final List<PromotionEntity>? kpiPromotions;
  final int? kpiTotalCount;
  final String? searchKeyword;
  final int pageIndex;
  final bool isRefreshing;
  final String? successMessage;
  final int? stamp;

  const PromotionsLoaded({
    required this.promotionsData,
    this.kpiPromotions,
    this.kpiTotalCount,
    this.searchKeyword,
    required this.pageIndex,
    this.isRefreshing = false,
    this.successMessage,
    this.stamp,
  });

  PromotionsLoaded copyWith({
    PagedResult<PromotionEntity>? promotionsData,
    List<PromotionEntity>? kpiPromotions,
    int? kpiTotalCount,
    String? searchKeyword,
    int? pageIndex,
    bool? isRefreshing,
    String? successMessage,
    int? stamp,
  }) {
    return PromotionsLoaded(
      promotionsData: promotionsData ?? this.promotionsData,
      kpiPromotions: kpiPromotions ?? this.kpiPromotions,
      kpiTotalCount: kpiTotalCount ?? this.kpiTotalCount,
      searchKeyword: searchKeyword ?? this.searchKeyword,
      pageIndex: pageIndex ?? this.pageIndex,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      successMessage: successMessage,
      stamp: stamp ?? this.stamp,
    );
  }

  @override
  List<Object?> get props => [
        promotionsData,
        kpiPromotions,
        kpiTotalCount,
        searchKeyword,
        pageIndex,
        isRefreshing,
        successMessage,
        stamp,
      ];
}

class PromotionAdminError extends PromotionAdminState {
  final String message;

  const PromotionAdminError(this.message);

  @override
  List<Object?> get props => [message];
}
