import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/ColorPalette.dart';
import '../../../../core/theme/AppTypography.dart';
import '../../../../core/widgets/app_pagination_bar.dart';
import '../../domain/entities/paged_orders_result.dart';

class OrderDataTable extends StatelessWidget {
  final PagedOrdersResult pagedOrders;
  final ValueChanged<int> onPageChanged;
  final ValueChanged<int> onViewDetail;

  const OrderDataTable({
    super.key,
    required this.pagedOrders,
    required this.onPageChanged,
    required this.onViewDetail,
  });

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    final timeFormat = DateFormat('dd/MM/yyyy HH:mm');

    final items = pagedOrders.items;

    if (items.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
        decoration: BoxDecoration(
          color: ColorPalette.surfaceWhite,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: ColorPalette.borderSubtle),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.search_off_rounded,
                size: 40,
                color: ColorPalette.textMuted,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Không tìm thấy đơn hàng nào',
              style: AppTypography.plusJakarta(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: ColorPalette.onSurfaceDark,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Thử thay đổi từ khóa tìm kiếm hoặc mở rộng khoảng ngày lọc.',
              style: AppTypography.inter(fontSize: 13, color: ColorPalette.textMuted),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: ColorPalette.surfaceWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ColorPalette.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Responsive DataTable (Adheres to MEMORY.md Rule) ────────────
          LayoutBuilder(
            builder: (context, constraints) {
              final double tableWidth = constraints.maxWidth > 950 ? constraints.maxWidth : 950.0;

              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: tableWidth,
                  child: DataTable(
                    headingRowColor: WidgetStateProperty.all(const Color(0xFFF9FAFB)),
                    headingTextStyle: AppTypography.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: ColorPalette.textMuted,
                    ),
                    dataRowMinHeight: 52,
                    dataRowMaxHeight: 56,
                    horizontalMargin: 20,
                    columnSpacing: 20,
                    columns: const [
                      DataColumn(label: Text('MÃ ĐƠN HÀNG')),
                      DataColumn(label: Text('THỜI GIAN')),
                      DataColumn(label: Text('THU NGÂN')),
                      DataColumn(label: Text('KHÁCH HÀNG')),
                      DataColumn(label: Text('SỐ LƯỢNG')),
                      DataColumn(label: Text('TỔNG TIỀN')),
                      DataColumn(label: Text('PHƯƠNG THỨC')),
                      DataColumn(label: Text('TRẠNG THÁI')),
                      DataColumn(label: Text('THAO TÁC')),
                    ],
                    rows: items.map((order) {
                      return DataRow(
                        cells: [
                          // Mã đơn hàng
                          DataCell(
                            InkWell(
                              onTap: () => onViewDetail(order.orderId),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.receipt_rounded,
                                    size: 16,
                                    color: ColorPalette.primaryContainer,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    order.orderCode,
                                    style: AppTypography.inter(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: ColorPalette.primaryContainer,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // Thời gian
                          DataCell(
                            Text(
                              timeFormat.format(order.createdAt),
                              style: AppTypography.inter(fontSize: 12, color: ColorPalette.textMuted),
                            ),
                          ),
                          // Thu ngân
                          DataCell(
                            Text(
                              order.staffName ?? '—',
                              style: AppTypography.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: ColorPalette.onSurfaceDark,
                              ),
                            ),
                          ),
                          // Khách hàng
                          DataCell(
                            Text(
                              order.customerName != null && order.customerName!.isNotEmpty
                                  ? order.customerName!
                                  : 'Khách lẻ',
                              style: AppTypography.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: ColorPalette.onSurfaceDark,
                              ),
                            ),
                          ),
                          // Số lượng
                          DataCell(
                            Text(
                              '${order.itemCount} món',
                              style: AppTypography.inter(fontSize: 12, color: ColorPalette.textMuted),
                            ),
                          ),
                          // Tổng tiền
                          DataCell(
                            Text(
                              currency.format(order.totalAmount),
                              style: AppTypography.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: ColorPalette.onSurfaceDark,
                              ),
                            ),
                          ),
                          // Phương thức TT
                          DataCell(_buildPaymentBadge(order.paymentMethod)),
                          // Trạng thái
                          DataCell(_buildStatusBadge(order.orderStatus)),
                          // Thao tác
                          DataCell(
                            IconButton(
                              icon: const Icon(Icons.visibility_outlined, size: 20),
                              color: ColorPalette.primaryContainer,
                              tooltip: 'Xem chi tiết đơn',
                              onPressed: () => onViewDetail(order.orderId),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              );
            },
          ),

          // ── Pagination Footer ───────────────────────────────────────────
          AppPaginationBar(
            currentPage: pagedOrders.pageNumber,
            totalPages: pagedOrders.totalPages > 0 ? pagedOrders.totalPages : 1,
            totalCount: pagedOrders.totalCount,
            itemLabel: 'đơn hàng',
            pageSize: pagedOrders.pageSize > 0 ? pagedOrders.pageSize : 10,
            onPageChanged: onPageChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bg;
    Color fg;
    String label;

    switch (status) {
      case 'COMPLETED':
        bg = const Color(0xFFE8F5E9);
        fg = const Color(0xFF2E7D32);
        label = 'Hoàn thành';
        break;
      case 'CANCELLED':
        bg = const Color(0xFFFFEBEE);
        fg = const Color(0xFFC62828);
        label = 'Đã hủy';
        break;
      default:
        bg = const Color(0xFFFFF3E0);
        fg = const Color(0xFFE65100);
        label = 'Chờ xử lý';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(color: fg, fontSize: 11, fontWeight: FontWeight.w700),
      ),
    );
  }

  Widget _buildPaymentBadge(String method) {
    IconData icon;
    String label;
    Color color;

    switch (method) {
      case 'QR_CODE':
        icon = Icons.qr_code_2_rounded;
        label = 'VietQR';
        color = const Color(0xFF0D47A1);
        break;
      case 'BANK_TRANSFER':
        icon = Icons.account_balance_rounded;
        label = 'Chuyển khoản';
        color = const Color(0xFF4A148C);
        break;
      default:
        icon = Icons.payments_rounded;
        label = 'Tiền mặt';
        color = const Color(0xFF2E7D32);
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: AppTypography.inter(fontSize: 12, fontWeight: FontWeight.w600, color: color),
        ),
      ],
    );
  }
}
