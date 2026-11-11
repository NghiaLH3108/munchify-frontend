import 'package:flutter/material.dart';
import '../../../../core/theme/ColorPalette.dart';
import '../../../../core/widgets/admin/admin_widgets.dart';
import '../../domain/entities/promotion_entity.dart';

class PromotionStatCards extends StatelessWidget {
  final List<PromotionEntity> promotions;
  final int totalCount;

  const PromotionStatCards({
    super.key,
    required this.promotions,
    required this.totalCount,
  });

  static List<Widget> cards({
    required List<PromotionEntity> promotions,
    required int totalCount,
  }) {
    final activeCount = promotions.where((p) => p.isActive).length;
    final inactiveCount = totalCount - activeCount;

    return [
      AdminKpiCard(
        title: 'TỔNG KHUYẾN MÃI',
        value: totalCount.toString(),
        subtitle: 'Tất cả các chương trình ưu đãi',
        icon: Icons.campaign_rounded,
        iconColor: ColorPalette.primaryContainer,
        iconBg: ColorPalette.primaryFixed.withValues(alpha: 0.6),
      ),
      AdminKpiCard(
        title: 'ĐANG HOẠT ĐỘNG',
        value: activeCount.toString(),
        subtitle: totalCount > 0
            ? 'Chiếm ${((activeCount / (totalCount == 0 ? 1 : totalCount)) * 100).round()}% chương trình'
            : 'Chương trình đang chạy',
        icon: Icons.check_circle_outline_rounded,
        iconColor: ColorPalette.tertiary,
        iconBg: ColorPalette.tertiary.withValues(alpha: 0.1),
        showTrendIcon: true,
        trendPositive: true,
      ),
      AdminKpiCard(
        title: 'ĐÃ TẠM DỪNG',
        value: inactiveCount.toString(),
        subtitle: 'Chương trình đã dừng / kết thúc',
        icon: Icons.pause_circle_outline_rounded,
        iconColor: ColorPalette.textMuted,
        iconBg: const Color(0xFFF1F5F9),
        isWarning: inactiveCount > 0,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return AdminKpiRow(
      cards: cards(promotions: promotions, totalCount: totalCount),
    );
  }
}
