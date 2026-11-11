import 'package:flutter/material.dart';
import '../../../../core/theme/ColorPalette.dart';
import '../../../../core/widgets/admin/admin_widgets.dart';

class ProductStatCards extends StatelessWidget {
  final int totalSkus;
  final int activeCount;
  final int lowStockCount;

  const ProductStatCards({
    super.key,
    required this.totalSkus,
    required this.activeCount,
    this.lowStockCount = 0,
  });

  static List<Widget> cards({
    required int totalSkus,
    required int activeCount,
    int lowStockCount = 0,
  }) {
    final inactive = totalSkus >= activeCount ? totalSkus - activeCount : 0;
    return [
      AdminKpiCard(
        title: 'TỔNG MÓN / SKUS',
        value: '$totalSkus món',
        subtitle: 'Tất cả sản phẩm trong thực đơn',
        icon: Icons.restaurant_menu_rounded,
        iconColor: ColorPalette.primaryContainer,
        iconBg: ColorPalette.primaryFixed.withValues(alpha: 0.6),
      ),
      AdminKpiCard(
        title: 'ĐANG KINH DOANH',
        value: activeCount.toString(),
        subtitle: totalSkus > 0
            ? 'Chiếm ${((activeCount / totalSkus) * 100).round()}% thực đơn'
            : 'Đang mở bán',
        icon: Icons.check_circle_outline_rounded,
        iconColor: ColorPalette.tertiary,
        iconBg: ColorPalette.tertiary.withValues(alpha: 0.1),
        showTrendIcon: true,
        trendPositive: true,
      ),
      AdminKpiCard(
        title: 'NGỪNG KINH DOANH',
        value: inactive.toString(),
        subtitle:
            inactive > 0 ? 'Tạm ngưng phục vụ' : 'Tất cả món đang mở bán',
        icon: Icons.pause_circle_outline_rounded,
        iconColor: ColorPalette.textMuted,
        iconBg: const Color(0xFFF1F5F9),
        isWarning: inactive > 0,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return AdminKpiRow(
      cards: cards(
        totalSkus: totalSkus,
        activeCount: activeCount,
        lowStockCount: lowStockCount,
      ),
    );
  }
}
