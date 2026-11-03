import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/AppTypography.dart';
import '../../../../core/theme/ColorPalette.dart';
import '../../../../core/widgets/admin/admin_widgets.dart';
import '../../../../core/widgets/app_pagination_bar.dart';
import '../../domain/entities/product_entity.dart';
import '../bloc/product_admin_bloc.dart';
import '../bloc/product_admin_event.dart';
import 'product_form_dialog.dart';

class ProductDataTable extends StatelessWidget {
  final List<ProductEntity> products;
  final int currentPage;
  final int totalPages;
  final int totalCount;
  final int startIndex;
  final int endIndex;
  final ValueChanged<int> onPageChanged;

  const ProductDataTable({
    super.key,
    required this.products,
    required this.currentPage,
    required this.totalPages,
    required this.totalCount,
    required this.startIndex,
    required this.endIndex,
    required this.onPageChanged,
  });

  static final NumberFormat _vnd =
      NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0);

  @override
  Widget build(BuildContext context) {
    final indexOffset = startIndex > 0 ? startIndex - 1 : 0;

    return AdminDataTable<ProductEntity>(
      title: 'Danh sách sản phẩm',
      countLabel: '$totalCount món',
      subtitle: 'Hiển thị trang $currentPage / $totalPages.',
      items: products,
      indexOffset: indexOffset,
      minTableWidth: 960,
      onRowTap: (product) => ProductFormDialog.show(context, product: product),
      emptyState: const AdminEmptyState(
        icon: Icons.restaurant_menu_rounded,
        title: 'Chưa có sản phẩm nào phù hợp',
        subtitle: 'Thử thay đổi bộ lọc hoặc thêm món mới vào thực đơn.',
      ),
      columns: [
        AdminTableColumn.index<ProductEntity>(),
        AdminTableColumn(
          label: 'MÓN / SẢN PHẨM',
          flex: 4,
          cellBuilder: (_, product, _) => Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 40,
                  height: 40,
                  color: ColorPalette.amberTint,
                  child: product.imageUrl != null &&
                          product.imageUrl!.isNotEmpty
                      ? Image.network(
                          product.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => const Icon(
                            Icons.fastfood_rounded,
                            size: 18,
                            color: ColorPalette.appetizingOrange,
                          ),
                        )
                      : const Icon(
                          Icons.fastfood_rounded,
                          size: 18,
                          color: ColorPalette.appetizingOrange,
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: AppTypography.labelLarge.copyWith(fontSize: 13),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${product.sku} · ĐVT: ${product.unitName ?? 'N/A'}',
                      style:
                          AppTypography.dashboardSubtitle.copyWith(fontSize: 11),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        AdminTableColumn(
          label: 'DANH MỤC',
          flex: 2,
          cellBuilder: (_, product, _) => Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: ColorPalette.primaryFixed.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                product.categoryName ?? 'Chưa phân loại',
                style: AppTypography.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: ColorPalette.primaryContainer,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
        AdminTableColumn(
          label: 'ĐƠN GIÁ',
          flex: 2,
          cellBuilder: (_, product, _) => Text(
            _vnd.format(product.price),
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: ColorPalette.appetizingOrange,
            ),
          ),
        ),
        AdminTableColumn(
          label: 'TỒN KHO / ĐỊNH MỨC',
          flex: 2,
          cellBuilder: (_, product, _) {
            final isLow = product.stockQuantity <= product.minStockLevel;
            return Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isLow
                      ? ColorPalette.dangerCrimson.withValues(alpha: 0.1)
                      : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${product.stockQuantity} / ${product.minStockLevel}',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: isLow
                        ? ColorPalette.dangerCrimson
                        : ColorPalette.textPrimary,
                  ),
                ),
              ),
            );
          },
        ),
        AdminTableColumn(
          label: 'TRẠNG THÁI',
          flex: 3,
          cellBuilder: (ctx, product, _) => FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Switch(
                  value: product.isActive,
                  activeTrackColor: ColorPalette.success.withValues(alpha: 0.3),
                  activeThumbColor: ColorPalette.success,
                  inactiveTrackColor:
                      ColorPalette.error.withValues(alpha: 0.15),
                  inactiveThumbColor: ColorPalette.error.withValues(alpha: 0.6),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  onChanged: (value) {
                    ctx
                        .read<ProductAdminBloc>()
                        .add(ToggleProductStatusEvent(product.id, value));
                  },
                ),
                const SizedBox(width: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: product.isActive
                        ? ColorPalette.success.withValues(alpha: 0.08)
                        : ColorPalette.error.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    product.isActive ? 'Đang bán' : 'Ngừng bán',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: product.isActive
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
          cellBuilder: (ctx, product, _) => Align(
            alignment: Alignment.centerRight,
            child: AdminRowActionButton(
              icon: Icons.edit_outlined,
              color: ColorPalette.appetizingOrange,
              tooltip: 'Chỉnh sửa',
              onPressed: () =>
                  ProductFormDialog.show(ctx, product: product),
            ),
          ),
        ),
      ],
      pagination: AppPaginationBar(
        currentPage: currentPage,
        totalPages: totalPages,
        totalCount: totalCount,
        itemLabel: 'món',
        startIndex: startIndex,
        endIndex: endIndex,
        onPageChanged: onPageChanged,
      ),
    );
  }
}
