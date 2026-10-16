import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/ColorPalette.dart';
import '../../domain/entities/order_entity.dart';

/// Màn hình hóa đơn sau khi thanh toán thành công.
///
/// Hiển thị toàn bộ thông tin đơn hàng.
/// Nút "In hóa đơn" hiển thị bản in dạng dialog (POS thermal style).
/// Nút "Đóng" → pop về màn hình bán hàng.
class ReceiptScreen extends StatelessWidget {
  final OrderEntity order;

  const ReceiptScreen({Key? key, required this.order}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    final dateFormat = DateFormat('HH:mm – dd/MM/yyyy');

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        backgroundColor: ColorPalette.appetizingOrange,
        foregroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Thanh toán thành công',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
            icon: const Icon(Icons.close),
            tooltip: 'Đóng',
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Success banner ──────────────────────────────────────────────
          Container(
            color: ColorPalette.appetizingOrange,
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            child: Column(
              children: [
                const Icon(Icons.check_circle, color: Colors.white, size: 56),
                const SizedBox(height: 8),
                Text(
                  currency.format(order.totalAmount),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '# ${order.orderCode}',
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),

          // ── Receipt body ────────────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _ReceiptCard(
                    child: Column(
                      children: [
                        // Header
                        const Text(
                          'MUNCHIFY POS',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          dateFormat.format(order.createdAt),
                          style: const TextStyle(
                              color: ColorPalette.textSecondary,
                              fontSize: 13),
                        ),
                        if (order.customerName != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            'KH: ${order.customerName}',
                            style: const TextStyle(
                                color: ColorPalette.textSecondary,
                                fontSize: 13),
                          ),
                        ],
                        const Divider(height: 24),

                        // Items
                        ...order.orderDetails.map(
                          (d) => Padding(
                            padding:
                                const EdgeInsets.symmetric(vertical: 5),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(d.productName,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14)),
                                      Text(
                                        '${currency.format(d.unitPrice)} × ${d.quantity} ${d.unitName}',
                                        style: const TextStyle(
                                          color: ColorPalette.textSecondary,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  currency.format(d.totalAmount),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const Divider(height: 24),

                        // Totals
                        _AmountRow(
                            'Tạm tính', currency.format(order.subtotal)),
                        if (order.discountAmount > 0)
                          _AmountRow(
                            'Giảm giá',
                            '- ${currency.format(order.discountAmount)}',
                            valueColor: Colors.green,
                          ),
                        if (order.pointsRedeemed > 0)
                          _AmountRow(
                            'Điểm quy đổi',
                            '- ${currency.format(order.pointsRedeemed * 1000)}',
                            valueColor: Colors.green,
                          ),
                        const SizedBox(height: 6),
                        _AmountRow(
                          'Tổng thanh toán',
                          currency.format(order.totalAmount),
                          isBold: true,
                          valueColor: ColorPalette.error,
                        ),
                        const SizedBox(height: 4),
                        _AmountRow(
                          'Phương thức TT',
                          _paymentLabel(order.payment.paymentMethod),
                        ),

                        const Divider(height: 24),

                        // Points earned
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade50,
                            borderRadius: BorderRadius.circular(10),
                            border:
                                Border.all(color: Colors.amber.shade200),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.stars,
                                  color: Colors.amber, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Tích lũy +${order.pointsEarned} điểm',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                    color: Colors.amber,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ── Action buttons ──────────────────────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _showPrintPreview(context, order),
                          icon: const Icon(Icons.print_outlined),
                          label: const Text('In hóa đơn'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor:
                                ColorPalette.appetizingOrange,
                            side: const BorderSide(
                                color: ColorPalette.appetizingOrange),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(
                                vertical: 14),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () =>
                              Navigator.of(context).popUntil((r) => r.isFirst),
                          icon: const Icon(Icons.add_shopping_cart),
                          label: const Text('Bán tiếp'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ColorPalette.appetizingOrange,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(
                                vertical: 14),
                            elevation: 0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _paymentLabel(String method) {
    switch (method) {
      case 'QR_CODE':
        return 'QR Code';
      case 'BANK_TRANSFER':
        return 'Chuyển khoản';
      default:
        return 'Tiền mặt';
    }
  }

  void _showPrintPreview(BuildContext context, OrderEntity order) {
    final currency = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.receipt_long, color: ColorPalette.appetizingOrange),
            SizedBox(width: 8),
            Text('Hóa đơn'),
          ],
        ),
        content: SizedBox(
          width: 300,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('━━━━━━━━━━━━━━━━━━━━━━━'),
                const Text('MUNCHIFY POS',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Text(order.orderCode),
                const Text('━━━━━━━━━━━━━━━━━━━━━━━'),
                ...order.orderDetails.map(
                  (d) => Text(
                      '${d.productName} x${d.quantity}  ${currency.format(d.totalAmount)}'),
                ),
                const Text('━━━━━━━━━━━━━━━━━━━━━━━'),
                Text('TỔNG: ${currency.format(order.totalAmount)}',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                Text('Điểm tích: +${order.pointsEarned}'),
                const Text('Cảm ơn quý khách!'),
                const Text('━━━━━━━━━━━━━━━━━━━━━━━'),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }
}

class _ReceiptCard extends StatelessWidget {
  final Widget child;
  const _ReceiptCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _AmountRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final bool isBold;

  const _AmountRow(this.label, this.value,
      {this.valueColor, this.isBold = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isBold ? 15 : 13,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: isBold
                  ? ColorPalette.textPrimary
                  : ColorPalette.textSecondary,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isBold ? 16 : 13,
              fontWeight: FontWeight.bold,
              color: valueColor ?? ColorPalette.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
