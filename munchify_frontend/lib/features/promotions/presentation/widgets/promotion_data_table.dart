import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/ColorPalette.dart';
import '../../../../core/widgets/app_pagination_bar.dart';
import '../../domain/entities/promotion_entity.dart';

class PromotionDataTable extends StatelessWidget {
  final List<PromotionEntity> promotions;
  final Function(PromotionEntity) onEdit;
  final Function(String) onToggleStatus;
  final int totalPages;
  final int currentPage;
  final int totalCount;
  final Function(int) onPageChanged;

  const PromotionDataTable({
    super.key,
    required this.promotions,
    required this.onEdit,
    required this.onToggleStatus,
    required this.totalPages,
    required this.currentPage,
    required this.totalCount,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (promotions.isEmpty) {
      return _buildEmptyState();
    }

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final tableWidth = constraints.maxWidth > 800
                  ? constraints.maxWidth
                  : 800.0;
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: tableWidth,
                  child: DataTable(
                    headingRowColor: WidgetStateProperty.all(
                      ColorPalette.webBgAdmin,
                    ),
                    dataRowMinHeight: 60,
                    dataRowMaxHeight: 60,
                    columns: const [
                      DataColumn(
                        label: Text(
                          'MÃ KM',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'TÊN CHƯƠNG TRÌNH',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'MỨC GIẢM',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'THỜI GIAN',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'TRẠNG THÁI',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'THAO TÁC',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                    rows: promotions
                        .map((promo) => _buildDataRow(promo))
                        .toList(),
                  ),
                ),
              );
            },
          ),
          _buildPagination(),
        ],
      ),
    );
  }

  DataRow _buildDataRow(PromotionEntity promo) {
    final discountStr = promo.discountType == 'PERCENTAGE'
        ? '${promo.discountValue}%'
        : NumberFormat.currency(
            locale: 'vi_VN',
            symbol: 'đ',
          ).format(promo.discountValue);

    final dateFormat = DateFormat('dd/MM/yyyy');
    final timeStr =
        '${dateFormat.format(promo.startDate)} - ${dateFormat.format(promo.endDate)}';

    return DataRow(
      cells: [
        DataCell(
          Text(
            promo.promotionCode,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        DataCell(
          Text(
            promo.promotionName,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        DataCell(
          Text(
            discountStr,
            style: const TextStyle(
              color: ColorPalette.primaryContainer,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        DataCell(Text(timeStr, style: const TextStyle(fontSize: 12))),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: promo.isActive
                  ? ColorPalette.success.withValues(alpha: 0.1)
                  : ColorPalette.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              promo.isActive ? 'Hoạt động' : 'Tạm dừng',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: promo.isActive
                    ? ColorPalette.success
                    : ColorPalette.textMuted,
              ),
            ),
          ),
        ),
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(
                  Icons.edit_rounded,
                  size: 18,
                  color: ColorPalette.tertiary,
                ),
                tooltip: 'Chỉnh sửa',
                onPressed: () => onEdit(promo),
              ),
              Switch(
                value: promo.isActive,
                onChanged: (_) => onToggleStatus(promo.promotionId.toString()),
                activeTrackColor: ColorPalette.success,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPagination() {
    final effectiveTotalPages = totalPages == 0 ? 1 : totalPages;
    return AppPaginationBar(
      currentPage: currentPage,
      totalPages: effectiveTotalPages,
      totalCount: totalCount,
      itemLabel: 'khuyến mãi',
      pageSize: (totalCount / effectiveTotalPages).ceil(),
      onPageChanged: onPageChanged,
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: ColorPalette.surfaceWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ColorPalette.borderSubtle),
      ),
      child: Column(
        children: [
          Icon(
            Icons.campaign_outlined,
            size: 48,
            color: ColorPalette.borderSubtle,
          ),
          const SizedBox(height: 16),
          const Text(
            'Chưa có chương trình khuyến mãi nào',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
