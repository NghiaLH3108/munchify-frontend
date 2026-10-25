import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/ColorPalette.dart';
import '../../../../core/theme/AppTypography.dart';
import '../../domain/entities/admin_order_detail_entity.dart';

class OrderDetailModal extends StatelessWidget {
  final AdminOrderDetailEntity order;

  const OrderDetailModal({super.key, required this.order});

  static void show(BuildContext context, AdminOrderDetailEntity order) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => OrderDetailModal(order: order),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    final timeFormat = DateFormat('HH:mm – dd/MM/yyyy');

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        width: 680,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        decoration: BoxDecoration(
          color: ColorPalette.surfaceWhite,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Modal Header ──────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: ColorPalette.borderSubtle)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: ColorPalette.primaryFixed.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.receipt_long_rounded,
                      color: ColorPalette.primaryContainer,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              order.orderCode,
                              style: AppTypography.plusJakarta(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: ColorPalette.onSurfaceDark,
                              ),
                            ),
                            const SizedBox(width: 10),
                            _buildStatusBadge(order.orderStatus),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          timeFormat.format(order.createdAt),
                          style: AppTypography.inter(
                            fontSize: 12,
                            color: ColorPalette.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                    color: ColorPalette.textMuted,
                    tooltip: 'Đóng',
                  ),
                ],
              ),
            ),

            // ── Scrollable Body ───────────────────────────────────────────
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Operational Metadata (Cashier & Customer)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9FAFB),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: ColorPalette.borderSubtle),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'THU NGÂN LẬP ĐƠN',
                                  style: AppTypography.inter(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: ColorPalette.textMuted,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.badge_outlined, size: 16, color: ColorPalette.primaryContainer),
                                    const SizedBox(width: 6),
                                    Text(
                                      order.staffName ?? 'Chưa phân bổ',
                                      style: AppTypography.inter(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: ColorPalette.onSurfaceDark,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Container(width: 1, height: 36, color: ColorPalette.borderSubtle),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'KHÁCH HÀNG',
                                  style: AppTypography.inter(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: ColorPalette.textMuted,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.person_outline, size: 16, color: ColorPalette.primaryContainer),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        order.customerName != null
                                            ? '${order.customerName} (${order.customerPhone ?? ''})'
                                            : 'Khách lẻ tại quầy',
                                        style: AppTypography.inter(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: ColorPalette.onSurfaceDark,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Products Snapshot Table
                    Text(
                      'Danh sách món ăn & sản phẩm',
                      style: AppTypography.plusJakarta(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: ColorPalette.onSurfaceDark,
                      ),
                    ),
                    const SizedBox(height: 10),

                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: ColorPalette.borderSubtle),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Table(
                          columnWidths: const {
                            0: FlexColumnWidth(4),
                            1: FlexColumnWidth(2),
                            2: FlexColumnWidth(1.5),
                            3: FlexColumnWidth(2.5),
                          },
                          children: [
                            TableRow(
                              decoration: const BoxDecoration(color: Color(0xFFF3F4F6)),
                              children: [
                                _tableHeader('Tên món'),
                                _tableHeader('Đơn giá', align: TextAlign.right),
                                _tableHeader('Số lượng', align: TextAlign.center),
                                _tableHeader('Thành tiền', align: TextAlign.right),
                              ],
                            ),
                            ...order.orderDetails.map((item) {
                              return TableRow(
                                decoration: const BoxDecoration(
                                  border: Border(top: BorderSide(color: ColorPalette.borderSubtle)),
                                ),
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.productName,
                                          style: AppTypography.inter(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: ColorPalette.onSurfaceDark,
                                          ),
                                        ),
                                        Text(
                                          'ĐVT: ${item.unitName}',
                                          style: AppTypography.inter(
                                            fontSize: 11,
                                            color: ColorPalette.textMuted,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                    child: Text(
                                      currency.format(item.unitPrice),
                                      textAlign: TextAlign.right,
                                      style: AppTypography.inter(fontSize: 12, color: ColorPalette.onSurfaceDark),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                    child: Text(
                                      '${item.quantity}',
                                      textAlign: TextAlign.center,
                                      style: AppTypography.inter(fontSize: 13, fontWeight: FontWeight.w700),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                    child: Text(
                                      currency.format(item.totalAmount),
                                      textAlign: TextAlign.right,
                                      style: AppTypography.inter(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: ColorPalette.onSurfaceDark,
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Financial Summary Breakdown
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFDF9),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFFFE0B2)),
                      ),
                      child: Column(
                        children: [
                          _summaryRow('Tạm tính tiền hàng:', currency.format(order.subtotal)),
                          if (order.discountAmount > 0)
                            _summaryRow('Chiết khấu khuyến mãi:', '- ${currency.format(order.discountAmount)}', color: Colors.green.shade700),
                          if (order.pointsRedeemed > 0)
                            _summaryRow('Đổi điểm tích lũy (${order.pointsRedeemed} điểm):', '- ${currency.format(order.pointsRedeemed * 1000)}', color: Colors.amber.shade800),
                          const Divider(height: 20, color: ColorPalette.borderSubtle),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'TỔNG CỘNG THANH TOÁN:',
                                style: AppTypography.plusJakarta(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: ColorPalette.onSurfaceDark,
                                ),
                              ),
                              Text(
                                currency.format(order.totalAmount),
                                style: AppTypography.plusJakarta(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: ColorPalette.dangerCrimson,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Text(
                                'Phương thức thanh toán: ',
                                style: AppTypography.inter(fontSize: 12, color: ColorPalette.textMuted),
                              ),
                              _buildPaymentBadge(order.payment.paymentMethod),
                              const Spacer(),
                              if (order.pointsEarned > 0)
                                Row(
                                  children: [
                                    const Icon(Icons.stars_rounded, size: 16, color: Colors.amber),
                                    const SizedBox(width: 4),
                                    Text(
                                      '+${order.pointsEarned} điểm tích lũy',
                                      style: AppTypography.inter(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.amber.shade800,
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Modal Footer ──────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: ColorPalette.borderSubtle)),
              ),
              alignment: Alignment.centerRight,
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: OutlinedButton.styleFrom(
                  foregroundColor: ColorPalette.onSurfaceDark,
                  side: const BorderSide(color: ColorPalette.borderSubtle),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Đóng'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tableHeader(String text, {TextAlign align = TextAlign.left}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Text(
        text,
        textAlign: align,
        style: AppTypography.inter(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: ColorPalette.textMuted,
        ),
      ),
    );
  }

  Widget _summaryRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTypography.inter(fontSize: 13, color: ColorPalette.textMuted)),
          Text(
            value,
            style: AppTypography.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: color ?? ColorPalette.onSurfaceDark,
            ),
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
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
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: AppTypography.inter(fontSize: 12, fontWeight: FontWeight.w700, color: color),
        ),
      ],
    );
  }
}
