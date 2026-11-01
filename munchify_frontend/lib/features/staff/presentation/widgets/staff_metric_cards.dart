import 'package:flutter/material.dart';
import '../../../../core/theme/ColorPalette.dart';
import '../../../../core/widgets/admin/admin_widgets.dart';
import '../../domain/entities/staff_entity.dart';

/// KPI metric cards displaying staff statistics using shared [AdminKpiCard]:
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
            AdminKpiCard(
              title: 'TỔNG NHÂN SỰ',
              value: total.toString(),
              subtitle: 'Tất cả tài khoản hệ thống',
              icon: Icons.groups_rounded,
              iconColor: ColorPalette.primaryContainer,
              iconBg: ColorPalette.primaryFixed.withValues(alpha: 0.6),
              width: cardWidth,
            ),
            AdminKpiCard(
              title: 'ĐANG HOẠT ĐỘNG',
              value: active.toString(),
              subtitle:
                  '${((active / (total == 0 ? 1 : total)) * 100).round()}% tổng nhân viên',
              icon: Icons.verified_user_rounded,
              iconColor: ColorPalette.tertiary,
              iconBg: ColorPalette.tertiary.withValues(alpha: 0.1),
              width: cardWidth,
              showTrendIcon: true,
              trendPositive: true,
            ),
            AdminKpiCard(
              title: 'QUẢN TRỊ VIÊN',
              value: admins.toString(),
              subtitle: 'Quyền hạn ADMIN',
              icon: Icons.admin_panel_settings_rounded,
              iconColor: ColorPalette.adminPurple,
              iconBg: ColorPalette.adminPurple.withValues(alpha: 0.1),
              width: cardWidth,
            ),
            AdminKpiCard(
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
}
