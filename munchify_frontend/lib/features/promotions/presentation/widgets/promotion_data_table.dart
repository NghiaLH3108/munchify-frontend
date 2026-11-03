import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/AppTypography.dart';
import '../../../../core/theme/ColorPalette.dart';
import '../../../../core/widgets/admin/admin_widgets.dart';
import '../../../../core/widgets/app_pagination_bar.dart';
import '../../domain/entities/promotion_entity.dart';

class PromotionDataTable extends StatelessWidget {
  final List<PromotionEntity> promotions;
  final Function(PromotionEntity) onEdit;
  final Function(String) onToggleStatus;
  final int totalPages;
  final int currentPage;
  final int totalCount;
  final int pageSize;
  final bool isRefreshing;
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
    this.pageSize = 10,
    this.isRefreshing = false,
  });

  static final DateFormat _df = DateFormat('dd/MM/yyyy');
  static final NumberFormat _vnd =
      NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0);

  @override
  Widget build(BuildContext context) {
    final effectiveTotalPages = totalPages == 0 ? 1 : totalPages;

    return AdminDataTable<PromotionEntity>(
      title: 'Danh sách khuyến mãi',
      countLabel: '$totalCount chương trình',
      subtitle: 'Hiển thị trang $currentPage / $effectiveTotalPages.',
      items: promotions,
      indexOffset: (currentPage - 1) * pageSize,
      minTableWidth: 920,
      isRefreshing: isRefreshing,
      onRowTap: onEdit,
      emptyState: const AdminEmptyState(
        icon: Icons.campaign_outlined,
        title: 'Chưa có chương trình khuyến mãi nào',
        subtitle: 'Nhấn "Thêm Khuyến mãi" để tạo chương trình ưu đãi đầu tiên.',
      ),
      columns: [
        AdminTableColumn.index<PromotionEntity>(),
        AdminTableColumn(
          label: 'MÃ KHUYẾN MÃI',
          flex: 2,
          cellBuilder: (_, promo, _) => Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: ColorPalette.primaryFixed.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                promo.promotionCode,
                style: AppTypography.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: ColorPalette.primaryContainer,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
        AdminTableColumn(
          label: 'TÊN CHƯƠNG TRÌNH',
          flex: 4,
          cellBuilder: (_, promo, _) => Text(
            promo.promotionName,
            style: AppTypography.labelLarge.copyWith(fontSize: 13),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        AdminTableColumn(
          label: 'MỨC GIẢM',
          flex: 2,
          cellBuilder: (_, promo, _) {
            final discountStr = promo.discountType == 'PERCENTAGE'
                ? '${promo.discountValue.toStringAsFixed(0)}%'
                : _vnd.format(promo.discountValue);
            return Text(
              discountStr,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: ColorPalette.appetizingOrange,
              ),
            );
          },
        ),
        AdminTableColumn(
          label: 'THỜI GIAN ÁP DỤNG',
          flex: 3,
          cellBuilder: (_, promo, _) => Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.date_range_rounded,
                size: 14,
                color: ColorPalette.textMuted,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  '${_df.format(promo.startDate)} - ${_df.format(promo.endDate)}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: ColorPalette.textMuted,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        AdminTableColumn(
          label: 'TRẠNG THÁI',
          flex: 3,
          cellBuilder: (_, promo, _) => FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Switch(
                  value: promo.isActive,
                  activeTrackColor: ColorPalette.success.withValues(alpha: 0.3),
                  activeThumbColor: ColorPalette.success,
                  inactiveTrackColor:
                      ColorPalette.error.withValues(alpha: 0.15),
                  inactiveThumbColor: ColorPalette.error.withValues(alpha: 0.6),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  onChanged: (_) =>
                      onToggleStatus(promo.promotionId.toString()),
                ),
                const SizedBox(width: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: promo.isActive
                        ? ColorPalette.success.withValues(alpha: 0.08)
                        : ColorPalette.error.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    promo.isActive ? 'Hoạt động' : 'Tạm dừng',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: promo.isActive
                          ? ColorPalette.success
                          : ColorPalette.error,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        AdminTableColumn(
          label: 'THAO TÁC',
          width: 80,
          align: TextAlign.right,
          cellBuilder: (_, promo, _) => Align(
            alignment: Alignment.centerRight,
            child: AdminRowActionButton(
              icon: Icons.edit_outlined,
              color: ColorPalette.appetizingOrange,
              tooltip: 'Chỉnh sửa',
              onPressed: () => onEdit(promo),
            ),
          ),
        ),
      ],
      pagination: AppPaginationBar(
        currentPage: currentPage,
        totalPages: effectiveTotalPages,
        totalCount: totalCount,
        itemLabel: 'khuyến mãi',
        pageSize: pageSize,
        onPageChanged: onPageChanged,
      ),
    );
  }
}
