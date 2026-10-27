import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/AppTypography.dart';
import '../../../../core/theme/ColorPalette.dart';
import '../../domain/entities/revenue_summary_entity.dart';

class PaymentMethodBreakdownWidget extends StatelessWidget {
  final List<PaymentMethodBreakdownEntity> items;

  const PaymentMethodBreakdownWidget({super.key, required this.items});

  static final NumberFormat _vnd =
      NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0);

  static String _label(String method) {
    switch (method) {
      case 'CASH':
        return 'Tiền mặt';
      case 'QR_CODE':
        return 'VietQR';
      case 'BANK_TRANSFER':
        return 'Chuyển khoản';
      default:
        return method;
    }
  }

  static Color _color(String method) {
    switch (method) {
      case 'CASH':
        return ColorPalette.primaryContainer;
      case 'QR_CODE':
        return ColorPalette.tertiary;
      default:
        return const Color(0xFFF59E0B);
    }
  }

  @override
  Widget build(BuildContext context) {
    final total = items.fold<double>(0, (s, e) => s + e.amount);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ColorPalette.surfaceWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ColorPalette.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Phương thức thanh toán',
            style: AppTypography.plusJakarta(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: ColorPalette.onSurfaceDark,
            ),
          ),
          const SizedBox(height: 16),
          if (items.isEmpty)
            Text(
              'Chưa có dữ liệu',
              style: AppTypography.inter(
                  fontSize: 13, color: ColorPalette.textMuted),
            ),
          for (final e in items) ...[
            Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: _color(e.paymentMethod),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${_label(e.paymentMethod)} (${e.count} đơn)',
                    style: AppTypography.inter(
                        fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ),
                Text(
                  _vnd.format(e.amount),
                  style: AppTypography.inter(
                      fontSize: 13, fontWeight: FontWeight.w700),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: total <= 0 ? 0 : e.amount / total,
                minHeight: 8,
                backgroundColor: ColorPalette.borderSubtle,
                valueColor: AlwaysStoppedAnimation(_color(e.paymentMethod)),
              ),
            ),
            const SizedBox(height: 14),
          ],
        ],
      ),
    );
  }
}
