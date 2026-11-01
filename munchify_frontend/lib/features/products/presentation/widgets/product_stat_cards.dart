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

  @override
  Widget build(BuildContext context) {
    final inactive = totalSkus >= activeCount ? totalSkus - activeCount : 0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 900
            ? 3
            : (constraints.maxWidth > 500 ? 2 : 1);
        const gap = 16.0;
        final cardWidth =
            (constraints.maxWidth - ((crossAxisCount - 1) * gap)) /
                crossAxisCount;

        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
                AdminKpiCard(
                  title: 'TỔNG MÓN / SKUS',
                  value: '$totalSkus món',
                  subtitle: 'Tất cả sản phẩm trong thực đơn',
                  icon: Icons.restaurant_menu_rounded,
                  iconColor: ColorPalette.primaryContainer,
                  iconBg: ColorPalette.primaryFixed.withValues(alpha: 0.6),
                  width: cardWidth,
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
                  width: cardWidth,
                  showTrendIcon: true,
                  trendPositive: true,
                ),
                AdminKpiCard(
                  title: 'NGỪNG KINH DOANH',
                  value: inactive.toString(),
                  subtitle: inactive > 0
                      ? 'Tạm ngưng phục vụ'
                      : 'Tất cả món đang mở bán',
                  icon: Icons.pause_circle_outline_rounded,
                  iconColor: ColorPalette.textMuted,
                  iconBg: const Color(0xFFF1F5F9),
                  width: cardWidth,
                  isWarning: inactive > 0,
                ),
              ],
            );
      },
    );
  }
}
