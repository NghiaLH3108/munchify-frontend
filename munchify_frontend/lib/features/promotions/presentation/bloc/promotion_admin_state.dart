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
  final String? searchKeyword;
  final int pageIndex;

  const PromotionsLoaded({
    required this.promotionsData,
    this.searchKeyword,
    required this.pageIndex,
  });

  @override
  List<Object?> get props => [promotionsData, searchKeyword, pageIndex];
}

class PromotionAdminError extends PromotionAdminState {
  final String message;

  const PromotionAdminError(this.message);

  @override
  List<Object?> get props => [message];
}
