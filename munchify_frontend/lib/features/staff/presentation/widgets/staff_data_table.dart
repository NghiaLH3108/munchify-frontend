import 'package:flutter/material.dart';
import '../../../../core/theme/AppTypography.dart';
import '../../../../core/theme/ColorPalette.dart';
import '../../../../core/widgets/admin/admin_widgets.dart';
import '../../domain/entities/staff_entity.dart';

/// Danh sách nhân viên dựng trên template dùng chung [AdminDataTable]:
/// - Thanh tiêu đề có badge đếm và toggle Bảng/Lưới
/// - Bảng theo tỉ lệ flex, cuộn ngang khi hẹp
/// - Lưới thẻ responsive
/// - Switch trạng thái và nút chỉnh sửa
/// - Slot phân trang ở dưới
class StaffDataTable extends StatelessWidget {
  final List<StaffEntity> items;
  final int currentPage;
  final int pageSize;
  final int totalPages;
  final int totalCount;
  final bool isCardView;
  final bool isRefreshing;
  final ValueChanged<bool> onToggleViewMode;
  final ValueChanged<StaffEntity> onEditStaff;
  final ValueChanged<StaffEntity> onToggleStatus;
  final Widget? paginationWidget;

  const StaffDataTable({
    super.key,
    required this.items,
    required this.currentPage,
    required this.pageSize,
    required this.totalPages,
    required this.totalCount,
    required this.isCardView,
    required this.onToggleViewMode,
    required this.onEditStaff,
    required this.onToggleStatus,
    this.isRefreshing = false,
    this.paginationWidget,
  });

  static const _adminFg = Color(0xFF92400E);
  static const _staffFg = Color(0xFF1E40AF);

  @override
  Widget build(BuildContext context) {
    return AdminDataTable<StaffEntity>(
      title: 'Danh sách nhân viên',
      countLabel: '$totalCount người',
      subtitle:
          'Hiển thị trang $currentPage / $totalPages — bao gồm cả admin và nhân viên.',
      items: items,
      indexOffset: (currentPage - 1) * pageSize,
      isRefreshing: isRefreshing,
      onRowTap: onEditStaff,
      isCardView: isCardView,
      onToggleView: onToggleViewMode,
      cardBuilder: (context, staff, _) => _buildStaffCard(staff),
      pagination: paginationWidget,
      emptyState: const AdminEmptyState(
        icon: Icons.search_off_rounded,
        title: 'Không tìm thấy nhân viên phù hợp',
        subtitle: 'Vui lòng thử từ khóa tìm kiếm khác hoặc xóa bộ lọc.',
      ),
      columns: [
        AdminTableColumn.index<StaffEntity>(),
        AdminTableColumn(
          label: 'NHÂN VIÊN',
          flex: 4,
          cellBuilder: (_, staff, _) => Row(
            children: [
              _avatar(staff, 17, 12),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      staff.fullName,
                      style: AppTypography.labelLarge.copyWith(fontSize: 13),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '@${staff.username}',
                      style:
                          AppTypography.dashboardSubtitle.copyWith(fontSize: 11),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        AdminTableColumn(
          label: 'VAI TRÒ',
          flex: 2,
          cellBuilder: (_, staff, _) {
            final isAdmin = _isAdmin(staff);
            final fg = isAdmin ? _adminFg : _staffFg;
            return Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isAdmin
                      ? ColorPalette.amber.withValues(alpha: 0.12)
                      : ColorPalette.info.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isAdmin
                        ? ColorPalette.amber.withValues(alpha: 0.35)
                        : ColorPalette.info.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isAdmin ? Icons.shield_rounded : Icons.badge_rounded,
                      size: 13,
                      color: fg,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      staff.role,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: fg,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        AdminTableColumn(
          label: 'LIÊN HỆ',
          flex: 3,
          cellBuilder: (_, staff, _) => Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _contactLine(Icons.phone_outlined, staff.phone),
              const SizedBox(height: 3),
              _contactLine(Icons.email_outlined, staff.email),
            ],
          ),
        ),
        AdminTableColumn(
          label: 'TRẠNG THÁI',
          flex: 3,
          cellBuilder: (_, staff, _) => FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _statusSwitch(staff),
                const SizedBox(width: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: staff.isActive
                        ? ColorPalette.success.withValues(alpha: 0.08)
                        : ColorPalette.error.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: _statusText(staff),
                ),
              ],
            ),
          ),
        ),
        AdminTableColumn(
          label: 'THAO TÁC',
          width: 80,
          align: TextAlign.right,
          cellBuilder: (_, staff, _) => Align(
            alignment: Alignment.centerRight,
            child: AdminRowActionButton(
              icon: Icons.edit_outlined,
              color: ColorPalette.appetizingOrange,
              tooltip: 'Chỉnh sửa',
              onPressed: () => onEditStaff(staff),
            ),
          ),
        ),
      ],
    );
  }

  bool _isAdmin(StaffEntity s) => s.role.toUpperCase() == 'ADMIN';

  Widget _avatar(StaffEntity staff, double radius, double fontSize) {
    final isAdmin = _isAdmin(staff);
    return CircleAvatar(
      radius: radius,
      backgroundColor: isAdmin
          ? ColorPalette.amber.withValues(alpha: 0.2)
          : ColorPalette.info.withValues(alpha: 0.12),
      child: Text(
        _getInitials(staff.fullName),
        style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: fontSize,
          color: isAdmin ? _adminFg : _staffFg,
        ),
      ),
    );
  }

  Widget _contactLine(IconData icon, String? value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: ColorPalette.textMuted),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            value ?? '—',
            style: const TextStyle(fontSize: 12, color: ColorPalette.textMuted),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _statusSwitch(StaffEntity staff) {
    return Switch(
      value: staff.isActive,
      activeTrackColor: ColorPalette.success.withValues(alpha: 0.3),
      activeThumbColor: ColorPalette.success,
      inactiveTrackColor: ColorPalette.error.withValues(alpha: 0.15),
      inactiveThumbColor: ColorPalette.error.withValues(alpha: 0.6),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      onChanged: (_) => onToggleStatus(staff),
    );
  }

  Widget _statusText(StaffEntity staff) {
    return Text(
      staff.isActive ? 'Hoạt động' : 'Tạm khóa',
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: staff.isActive ? ColorPalette.success : ColorPalette.error,
      ),
    );
  }

  Widget _buildStaffCard(StaffEntity staff) {
    final isAdmin = _isAdmin(staff);
    return Container(
      decoration: BoxDecoration(
        color: ColorPalette.surface,
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
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _avatar(staff, 20, 13),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      staff.fullName,
                      style: AppTypography.labelLarge.copyWith(fontSize: 14),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '@${staff.username}',
                      style:
                          AppTypography.dashboardSubtitle.copyWith(fontSize: 11),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isAdmin
                      ? ColorPalette.amber.withValues(alpha: 0.12)
                      : ColorPalette.info.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  staff.role,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isAdmin ? _adminFg : _staffFg,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: ColorPalette.borderSubtle),
          const SizedBox(height: 10),
          _contactLine(Icons.phone_outlined, staff.phone),
          const SizedBox(height: 4),
          _contactLine(Icons.email_outlined, staff.email),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _statusSwitch(staff),
                  const SizedBox(width: 4),
                  _statusText(staff),
                ],
              ),
              OutlinedButton.icon(
                onPressed: () => onEditStaff(staff),
                icon: const Icon(Icons.edit_outlined, size: 14),
                label: const Text('Chỉnh sửa'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: ColorPalette.appetizingOrange,
                  side: BorderSide(
                    color: ColorPalette.appetizingOrange.withValues(alpha: 0.4),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  textStyle:
                      const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getInitials(String fullName) {
    final parts =
        fullName.trim().split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return 'U';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }
}
