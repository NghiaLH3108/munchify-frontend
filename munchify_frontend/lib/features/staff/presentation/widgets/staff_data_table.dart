import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/theme/AppTypography.dart';
import '../../../../core/theme/ColorPalette.dart';
import '../../domain/entities/staff_entity.dart';

/// Responsive data table and card view for staff list:
/// - Table Card Header Bar with count and view mode toggle
/// - Proportional horizontal scrolling table view
/// - Responsive card grid view
/// - Integrated status toggle switch and edit button callbacks
/// - Bottom slot for pagination widget
class StaffDataTable extends StatelessWidget {
  final List<StaffEntity> items;
  final int currentPage;
  final int pageSize;
  final int totalPages;
  final int totalCount;
  final bool isCardView;
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
    this.paginationWidget,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return _buildEmptyState();
    }

    return Container(
      decoration: BoxDecoration(
        color: ColorPalette.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ColorPalette.borderSubtle),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Table Card Header Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
            child: Wrap(
              spacing: 16,
              runSpacing: 12,
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Danh sách nhân viên',
                          style: AppTypography.plusJakarta(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: ColorPalette.onSurfaceDark,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: ColorPalette.primaryFixed,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '$totalCount người',
                            style: AppTypography.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: ColorPalette.primaryContainer,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Hiển thị trang $currentPage / $totalPages — bao gồm cả admin và nhân viên.',
                      style: AppTypography.inter(
                          fontSize: 12, color: ColorPalette.textMuted),
                    ),
                  ],
                ),
                Wrap(
                  spacing: 10,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    // View Mode Switcher
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: ColorPalette.webBgAdmin,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: ColorPalette.borderSubtle),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildViewModeButton(
                            icon: Icons.table_rows_rounded,
                            tooltip: 'Dạng bảng chi tiết',
                            isSelected: !isCardView,
                            onTap: () => onToggleViewMode(false),
                          ),
                          _buildViewModeButton(
                            icon: Icons.grid_view_rounded,
                            tooltip: 'Dạng thẻ lưới trực quan',
                            isSelected: isCardView,
                            onTap: () => onToggleViewMode(true),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: ColorPalette.borderSubtle),

          // Main Content: Either Table OR Card Grid
          if (!isCardView)
            LayoutBuilder(
              builder: (context, constraints) {
                final effectiveWidth = math.max(920.0, constraints.maxWidth);
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: effectiveWidth,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildProportionalTableHeader(),
                        ...items.asMap().entries.map((e) {
                          final index =
                              e.key + 1 + ((currentPage - 1) * pageSize);
                          return _buildProportionalTableRow(
                              context, e.value, index);
                        }),
                      ],
                    ),
                  ),
                );
              },
            )
          else
            _buildStaffCardGrid(context, items),

          // Optional Pagination Slot
          if (paginationWidget != null) ...[
            const Divider(height: 1, color: ColorPalette.borderSubtle),
            paginationWidget!,
          ],
        ],
      ),
    );
  }

  // ─── Proportional Flex Table Header ─────────────────────────────────────────
  Widget _buildProportionalTableHeader() {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: ColorPalette.webBgAdmin.withValues(alpha: 0.8),
        border:
            const Border(bottom: BorderSide(color: ColorPalette.borderSubtle)),
      ),
      child: const Row(
        children: [
          SizedBox(width: 44, child: Text('#', style: AppTypography.tableHeader)),
          SizedBox(width: 12),
          Expanded(
              flex: 4,
              child: Text('NHÂN VIÊN', style: AppTypography.tableHeader)),
          Expanded(
              flex: 2,
              child: Text('VAI TRÒ', style: AppTypography.tableHeader)),
          Expanded(
              flex: 3,
              child: Text('LIÊN HỆ', style: AppTypography.tableHeader)),
          Expanded(
              flex: 3,
              child: Text('TRẠNG THÁI', style: AppTypography.tableHeader)),
          SizedBox(
              width: 80,
              child: Text('THAO TÁC',
                  textAlign: TextAlign.right,
                  style: AppTypography.tableHeader)),
        ],
      ),
    );
  }

  // ─── Proportional Flex Table Row ────────────────────────────────────────────
  Widget _buildProportionalTableRow(
      BuildContext context, StaffEntity staff, int index) {
    final isAdmin = staff.role.toUpperCase() == 'ADMIN';
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onEditStaff(staff),
        hoverColor: ColorPalette.webBgAdmin.withValues(alpha: 0.4),
        child: Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: const BoxDecoration(
            border: Border(
                bottom: BorderSide(
                    color: ColorPalette.borderSubtle, width: 0.5)),
          ),
          child: Row(
            children: [
              // Index #
              SizedBox(
                width: 44,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF1F5F9),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '$index',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Staff Name + Avatar
              Expanded(
                flex: 4,
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 17,
                      backgroundColor: isAdmin
                          ? ColorPalette.amber.withValues(alpha: 0.2)
                          : ColorPalette.info.withValues(alpha: 0.12),
                      child: Text(
                        _getInitials(staff.fullName),
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                          color: isAdmin
                              ? const Color(0xFF92400E)
                              : const Color(0xFF1E40AF),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            staff.fullName,
                            style:
                                AppTypography.labelLarge.copyWith(fontSize: 13),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '@${staff.username}',
                            style: AppTypography.dashboardSubtitle
                                .copyWith(fontSize: 11),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Role Badge
              Expanded(
                flex: 2,
                child: Align(
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
                          color: isAdmin
                              ? const Color(0xFF92400E)
                              : const Color(0xFF1E40AF),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          staff.role,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: isAdmin
                                ? const Color(0xFF92400E)
                                : const Color(0xFF1E40AF),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Contact
              Expanded(
                flex: 3,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.phone_outlined,
                            size: 13, color: ColorPalette.textMuted),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            staff.phone ?? '—',
                            style: const TextStyle(
                                fontSize: 12, color: ColorPalette.textMuted),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.email_outlined,
                            size: 13, color: ColorPalette.textMuted),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            staff.email ?? '—',
                            style: const TextStyle(
                                fontSize: 12, color: ColorPalette.textMuted),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Status Toggle
              Expanded(
                flex: 3,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Switch(
                        value: staff.isActive,
                        activeTrackColor:
                            ColorPalette.success.withValues(alpha: 0.3),
                        activeThumbColor: ColorPalette.success,
                        inactiveTrackColor:
                            ColorPalette.error.withValues(alpha: 0.15),
                        inactiveThumbColor:
                            ColorPalette.error.withValues(alpha: 0.6),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        onChanged: (val) => onToggleStatus(staff),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: staff.isActive
                              ? ColorPalette.success.withValues(alpha: 0.08)
                              : ColorPalette.error.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          staff.isActive ? 'Hoạt động' : 'Tạm khóa',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: staff.isActive
                                ? ColorPalette.success
                                : ColorPalette.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Actions
              SizedBox(
                width: 80,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    color: ColorPalette.appetizingOrange,
                    tooltip: 'Chỉnh sửa',
                    style: IconButton.styleFrom(
                      backgroundColor:
                          ColorPalette.appetizingOrange.withValues(alpha: 0.08),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      minimumSize: const Size(34, 34),
                    ),
                    onPressed: () => onEditStaff(staff),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── View Mode Switcher Button ──────────────────────────────────────────────
  Widget _buildViewModeButton({
    required IconData icon,
    required String tooltip,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? ColorPalette.surface : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 3,
                      offset: const Offset(0, 1),
                    ),
                  ]
                : null,
          ),
          child: Icon(
            icon,
            size: 16,
            color: isSelected
                ? ColorPalette.appetizingOrange
                : ColorPalette.textMuted,
          ),
        ),
      ),
    );
  }

  // ─── Modern Card Grid View (Alternative Layout) ─────────────────────────────
  Widget _buildStaffCardGrid(BuildContext context, List<StaffEntity> cardItems) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final crossAxisCount = constraints.maxWidth > 1150
              ? 3
              : (constraints.maxWidth > 700 ? 2 : 1);
          const gap = 16.0;
          final cardWidth =
              (constraints.maxWidth - ((crossAxisCount - 1) * gap)) /
                  crossAxisCount;

          return Wrap(
            spacing: gap,
            runSpacing: gap,
            children: cardItems.asMap().entries.map((e) {
              final index = e.key + 1 + ((currentPage - 1) * pageSize);
              return SizedBox(
                width: cardWidth,
                child: _buildStaffCard(context, e.value, index),
              );
            }).toList(),
          );
        },
      ),
    );
  }

  Widget _buildStaffCard(BuildContext context, StaffEntity staff, int index) {
    final isAdmin = staff.role.toUpperCase() == 'ADMIN';
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
              CircleAvatar(
                radius: 20,
                backgroundColor: isAdmin
                    ? ColorPalette.amber.withValues(alpha: 0.2)
                    : ColorPalette.info.withValues(alpha: 0.12),
                child: Text(
                  _getInitials(staff.fullName),
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: isAdmin
                        ? const Color(0xFF92400E)
                        : const Color(0xFF1E40AF),
                  ),
                ),
              ),
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
                      style: AppTypography.dashboardSubtitle.copyWith(fontSize: 11),
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
                    color: isAdmin
                        ? const Color(0xFF92400E)
                        : const Color(0xFF1E40AF),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: ColorPalette.borderSubtle),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.phone_outlined,
                  size: 13, color: ColorPalette.textMuted),
              const SizedBox(width: 6),
              Text(staff.phone ?? '—',
                  style: const TextStyle(
                      fontSize: 12, color: ColorPalette.textMuted)),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.email_outlined,
                  size: 13, color: ColorPalette.textMuted),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  staff.email ?? '—',
                  style: const TextStyle(
                      fontSize: 12, color: ColorPalette.textMuted),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Switch(
                    value: staff.isActive,
                    activeTrackColor:
                        ColorPalette.success.withValues(alpha: 0.3),
                    activeThumbColor: ColorPalette.success,
                    inactiveTrackColor:
                        ColorPalette.error.withValues(alpha: 0.15),
                    inactiveThumbColor:
                        ColorPalette.error.withValues(alpha: 0.6),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    onChanged: (val) => onToggleStatus(staff),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    staff.isActive ? 'Hoạt động' : 'Tạm khóa',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: staff.isActive
                          ? ColorPalette.success
                          : ColorPalette.error,
                    ),
                  ),
                ],
              ),
              OutlinedButton.icon(
                onPressed: () => onEditStaff(staff),
                icon: const Icon(Icons.edit_outlined, size: 14),
                label: const Text('Chỉnh sửa'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: ColorPalette.appetizingOrange,
                  side: BorderSide(
                      color: ColorPalette.appetizingOrange
                          .withValues(alpha: 0.4)),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
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

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 48),
      decoration: BoxDecoration(
        color: ColorPalette.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ColorPalette.borderSubtle),
      ),
      child: Column(
        children: [
          Icon(Icons.search_off_rounded,
              size: 48, color: ColorPalette.textMuted.withValues(alpha: 0.5)),
          const SizedBox(height: 14),
          const Text('Không tìm thấy nhân viên phù hợp',
              style: AppTypography.titleLarge),
          const SizedBox(height: 6),
          const Text('Vui lòng thử từ khóa tìm kiếm khác hoặc xóa bộ lọc.',
              style: AppTypography.dashboardSubtitle),
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
