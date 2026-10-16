import 'package:flutter/material.dart';
import '../../../../core/theme/AppTypography.dart';
import '../../../../core/theme/ColorPalette.dart';
import '../../domain/entities/staff_entity.dart';

/// KPI metric cards displaying staff statistics:
/// - Total staff
/// - Active staff
/// - Administrators
/// - Locked/disabled accounts
class StaffMetricCards extends StatelessWidget {
  final List<StaffEntity> staffList;

  const StaffMetricCards({
    super.key,
    required this.staffList,
  });

  @override
  Widget build(BuildContext context) {
    final total = staffList.length;
    final active = staffList.where((s) => s.isActive).length;
    final admins = staffList.where((s) => s.role.toUpperCase() == 'ADMIN').length;
    final locked = total - active;

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount =
            constraints.maxWidth > 1050 ? 4 : (constraints.maxWidth > 550 ? 2 : 1);
        const gap = 16.0;
        final cardWidth =
            (constraints.maxWidth - ((crossAxisCount - 1) * gap)) / crossAxisCount;

        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            _buildMetricCard(
              title: 'TỔNG NHÂN SỰ',
              value: total.toString(),
              subtitle: 'Tất cả tài khoản hệ thống',
              icon: Icons.groups_rounded,
              iconColor: ColorPalette.primaryContainer,
              iconBg: ColorPalette.primaryFixed.withValues(alpha: 0.6),
              width: cardWidth,
            ),
            _buildMetricCard(
              title: 'ĐANG HOẠT ĐỘNG',
              value: active.toString(),
              subtitle:
                  '${((active / (total == 0 ? 1 : total)) * 100).round()}% tổng nhân viên',
              icon: Icons.verified_user_rounded,
              iconColor: ColorPalette.tertiary,
              iconBg: ColorPalette.tertiary.withValues(alpha: 0.1),
              width: cardWidth,
              trendValue: '+${active > 0 ? active : 0}',
              trendPositive: true,
            ),
            _buildMetricCard(
              title: 'QUẢN TRỊ VIÊN',
              value: admins.toString(),
              subtitle: 'Quyền hạn ADMIN',
              icon: Icons.admin_panel_settings_rounded,
              iconColor: ColorPalette.adminPurple,
              iconBg: ColorPalette.adminPurple.withValues(alpha: 0.1),
              width: cardWidth,
            ),
            _buildMetricCard(
              title: 'TẠM KHÓA',
              value: locked.toString(),
              subtitle: 'Bị vô hiệu hóa',
              icon: Icons.lock_person_rounded,
              iconColor: ColorPalette.dangerCrimson,
              iconBg: ColorPalette.dangerCrimson.withValues(alpha: 0.08),
              width: cardWidth,
              isWarning: locked > 0,
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
    String? trendValue,
    bool trendPositive = true,
    bool isWarning = false,
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
      child: Stack(
        children: [
          if (isWarning)
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: Container(
                width: 4,
                color: ColorPalette.warningTangerine,
              ),
            ),
          Padding(
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
                              color: isWarning && int.tryParse(value) != 0
                                  ? ColorPalette.dangerCrimson
                                  : ColorPalette.onSurfaceDark,
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
                      Text(
                        subtitle,
                        style: AppTypography.dashboardSubtitle.copyWith(fontSize: 11),
                      ),
                      if (trendValue != null)
                        Container(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: trendPositive
                                ? ColorPalette.success.withValues(alpha: 0.08)
                                : ColorPalette.error.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                trendPositive
                                    ? Icons.trending_up_rounded
                                    : Icons.trending_down_rounded,
                                size: 14,
                                color: trendPositive
                                    ? ColorPalette.success
                                    : ColorPalette.error,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                trendValue,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: trendPositive
                                      ? ColorPalette.success
                                      : ColorPalette.error,
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (isWarning)
                        const Icon(
                          Icons.warning_amber_rounded,
                          size: 16,
                          color: ColorPalette.warning,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
