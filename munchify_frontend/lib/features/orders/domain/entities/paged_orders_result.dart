import 'package:equatable/equatable.dart';
import 'admin_order_summary_entity.dart';

class PagedOrdersResult extends Equatable {
  final List<AdminOrderSummaryEntity> items;
  final int totalCount;
  final int pageNumber;
  final int pageSize;
  final int totalPages;

  const PagedOrdersResult({
    required this.items,
    required this.totalCount,
    required this.pageNumber,
    required this.pageSize,
    required this.totalPages,
  });

  @override
  List<Object?> get props => [
        items,
        totalCount,
        pageNumber,
        pageSize,
        totalPages,
      ];
}
