import 'package:equatable/equatable.dart';

abstract class PromotionAdminEvent extends Equatable {
  const PromotionAdminEvent();

  @override
  List<Object?> get props => [];
}

class LoadPromotions extends PromotionAdminEvent {
  final int pageIndex;
  final int pageSize;
  final String? searchKeyword;
  final String? successMessage;

  const LoadPromotions({
    required this.pageIndex,
    required this.pageSize,
    this.searchKeyword,
    this.successMessage,
  });

  @override
  List<Object?> get props => [pageIndex, pageSize, searchKeyword, successMessage];
}

class TogglePromotionStatus extends PromotionAdminEvent {
  final String id;
  final int pageIndex;
  final int pageSize;
  final String? searchKeyword;

  const TogglePromotionStatus({
    required this.id,
    required this.pageIndex,
    required this.pageSize,
    this.searchKeyword,
  });

  @override
  List<Object?> get props => [id, pageIndex, pageSize, searchKeyword];
}
