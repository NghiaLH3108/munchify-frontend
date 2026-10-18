import 'package:flutter/material.dart';
import '../../../../core/theme/ColorPalette.dart';
import '../../../../core/theme/AppTypography.dart';
import '../../domain/entities/promotion_entity.dart';

class PromotionStatCards extends StatelessWidget {
  final List<PromotionEntity> promotions;
  final int totalCount;

  const PromotionStatCards({
    super.key,
    required this.promotions,
    required this.totalCount,
  });

  @override
  Widget build(BuildContext context) {
    final activeCount = promotions.where((p) => p.isActive).length;
    final inactiveCount = totalCount - activeCount;

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 1050
            ? 3
            : (constraints.maxWidth > 550 ? 2 : 1);
        const gap = 16.0;
        final cardWidth =
            (constraints.maxWidth - ((crossAxisCount - 1) * gap)) /
                crossAxisCount;

        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            _buildMetricCard(
              title: 'TỔNG KHUYẾN MÃI',
              value: totalCount.toString(),
              subtitle: 'Tất cả các chương trình',
              icon: Icons.campaign_rounded,
              iconColor: ColorPalette.primaryContainer,
              iconBg: ColorPalette.primaryFixed.withValues(alpha: 0.6),
              width: cardWidth,
            ),
            _buildMetricCard(
              title: 'ĐANG HOẠT ĐỘNG',
              value: activeCount.toString(),
              subtitle: 'Chương trình đang chạy',
              icon: Icons.check_circle_outline_rounded,
              iconColor: ColorPalette.success,
              iconBg: ColorPalette.success.withValues(alpha: 0.1),
              width: cardWidth,
            ),
            _buildMetricCard(
              title: 'ĐÃ TẠM DỪNG',
              value: inactiveCount.toString(),
              subtitle: 'Chương trình đã dừng',
              icon: Icons.pause_circle_outline_rounded,
              iconColor: ColorPalette.textMuted,
              iconBg: ColorPalette.surfaceContainerHigh,
              width: cardWidth,
            ),
          ],
        );
      },
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required double width,
  }) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        color: ColorPalette.surfaceWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ColorPalette.borderSubtle),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTypography.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: ColorPalette.textMuted,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        value,
                        style: AppTypography.plusJakarta(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: ColorPalette.onSurfaceDark,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: iconColor, size: 22),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.only(top: 12),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: ColorPalette.borderSubtle)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      subtitle,
                      style: AppTypography.dashboardSubtitle.copyWith(fontSize: 11),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
