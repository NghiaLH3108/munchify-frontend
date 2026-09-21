import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/ColorPalette.dart';
import '../../../../core/theme/AppTypography.dart';
import '../../domain/entities/staff_entity.dart';
import '../bloc/staff_bloc.dart';
import '../bloc/staff_event.dart';
import '../bloc/staff_state.dart';
import '../widgets/staff_form_dialog.dart';

class StaffManagementScreen extends StatefulWidget {
  final bool embedInShell;
  const StaffManagementScreen({super.key, this.embedInShell = false});

  @override
  State<StaffManagementScreen> createState() => _StaffManagementScreenState();
}

class _StaffManagementScreenState extends State<StaffManagementScreen> {
  int _currentPage = 1;
  static const int _pageSize = 10;
  String? _selectedRole;
  bool? _selectedStatus;
  String _searchQuery = '';
  bool _isCardView = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadData() {
    context.read<StaffBloc>().add(
          LoadStaffList(
            page: _currentPage,
            pageSize: _pageSize,
            role: _selectedRole,
            isActive: _selectedStatus,
          ),
        );
  }

  void _onRoleFilterChanged(String? role) {
    setState(() {
      _selectedRole = role;
      _currentPage = 1;
    });
    _loadData();
  }

  void _onStatusFilterChanged(bool? status) {
    setState(() {
      _selectedStatus = status;
      _currentPage = 1;
    });
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    final bodyContent = BlocConsumer<StaffBloc, StaffState>(
                listener: (context, state) {
                  if (state is StaffActionSuccess) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
                            const SizedBox(width: 10),
                            Expanded(child: Text(state.message, style: const TextStyle(fontSize: 13))),
                          ],
                        ),
                        backgroundColor: ColorPalette.success,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        margin: const EdgeInsets.all(16),
                      ),
                    );
                    _loadData();
                  } else if (state is StaffError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            const Icon(Icons.error_outline_rounded, color: Colors.white, size: 18),
                            const SizedBox(width: 10),
                            Expanded(child: Text(state.message, style: const TextStyle(fontSize: 13))),
                          ],
                        ),
                        backgroundColor: ColorPalette.error,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        margin: const EdgeInsets.all(16),
                      ),
                    );
                  }
                },
                buildWhen: (previous, current) =>
                    current is StaffLoading || current is StaffListLoaded || current is StaffError,
                builder: (context, state) {
                  if (state is StaffLoading) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 40,
                            height: 40,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              color: ColorPalette.appetizingOrange,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text('Đang đồng bộ danh sách nhân viên...',
                              style: AppTypography.dashboardSubtitle),
                        ],
                      ),
                    );
                  } else if (state is StaffError) {
                    return _buildErrorState(state.message);
                  } else if (state is StaffListLoaded) {
                    final allItems = state.result.items;
                    final filteredItems = allItems.where((staff) {
                      if (_searchQuery.isEmpty) return true;
                      final q = _searchQuery.toLowerCase();
                      return staff.fullName.toLowerCase().contains(q) ||
                          staff.username.toLowerCase().contains(q) ||
                          (staff.phone?.toLowerCase().contains(q) ?? false) ||
                          (staff.email?.toLowerCase().contains(q) ?? false);
                    }).toList();

                    return SingleChildScrollView(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildPageTitleBar(context),
                          const SizedBox(height: 20),
                          _buildKpiMetrics(allItems),
                          const SizedBox(height: 24),
                          _buildStaffTableCard(context, filteredItems,
                              state.result.totalPages, state.result.totalCount),
                        ],
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              );

    if (widget.embedInShell) {
      return bodyContent;
    }

    return Scaffold(
      backgroundColor: ColorPalette.webBgAdmin,
      body: SafeArea(
        child: Column(
          children: [
            _buildStickyHeader(context),
            Expanded(child: bodyContent),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // STICKY HEADER (matches mockup top nav bar)
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildStickyHeader(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      decoration: BoxDecoration(
        color: ColorPalette.surface,
        border: Border(bottom: BorderSide(color: ColorPalette.borderSubtle)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 950;
          final isVeryNarrow = constraints.maxWidth < 650;

          return Row(
            children: [
              // Brand identity
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: ColorPalette.appetizingOrange.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.lunch_dining_rounded,
                    color: ColorPalette.appetizingOrange, size: 22),
              ),
              const SizedBox(width: 12),
              const Text(
                'Munchify POS',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: ColorPalette.warmDarkGrey,
                ),
              ),
              if (!isNarrow) ...[
                const SizedBox(width: 10),
                // Breadcrumb
                Row(
                  children: [
                    const Icon(Icons.chevron_right_rounded,
                        size: 18, color: ColorPalette.textMuted),
                    const SizedBox(width: 4),
                    Text('Trang chủ',
                        style: AppTypography.labelSmall.copyWith(
                          color: ColorPalette.textMuted,
                          decoration: TextDecoration.none,
                        )),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 6),
                      child: Text('/', style: TextStyle(color: ColorPalette.textMuted, fontSize: 12)),
                    ),
                    Text('Nhân viên & Quyền',
                        style: AppTypography.labelSmall.copyWith(
                          color: ColorPalette.textPrimary,
                          fontWeight: FontWeight.w700,
                        )),
                  ],
                ),
              ],
              const Spacer(),
              Flexible(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  reverse: true,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Global search
                      if (!isNarrow) ...[
                        SizedBox(
                          width: 240,
                          height: 38,
                          child: TextField(
                            style: const TextStyle(fontSize: 13),
                            decoration: InputDecoration(
                              hintText: 'Tìm nhanh... (Ctrl+K)',
                              hintStyle: TextStyle(fontSize: 12, color: ColorPalette.textMuted),
                              prefixIcon: const Icon(Icons.search_rounded, size: 18, color: ColorPalette.textMuted),
                              filled: true,
                              fillColor: ColorPalette.webBgAdmin.withValues(alpha: 0.7),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: ColorPalette.borderSubtle),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: ColorPalette.borderSubtle),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(color: ColorPalette.appetizingOrange, width: 1.5),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                      // Status badge
                      if (!isVeryNarrow) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: ColorPalette.success.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 7,
                                height: 7,
                                decoration: const BoxDecoration(
                                    color: ColorPalette.success, shape: BoxShape.circle),
                              ),
                              const SizedBox(width: 6),
                              const Text('Online',
                                  style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: ColorPalette.success)),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                      ],
                      // Reload
                      IconButton(
                        onPressed: _loadData,
                        icon: const Icon(Icons.refresh_rounded, size: 20, color: ColorPalette.textMuted),
                        tooltip: 'Tải lại danh sách',
                        style: IconButton.styleFrom(
                          backgroundColor: ColorPalette.webBgAdmin,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // User avatar
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          border: Border.all(color: ColorPalette.borderSubtle),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 14,
                              backgroundColor: ColorPalette.surfaceContainerHigh,
                              child: const Text('HM',
                                  style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: ColorPalette.appetizingOrange)),
                            ),
                            if (!isVeryNarrow) ...[
                              const SizedBox(width: 8),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Hoàng Minh',
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: ColorPalette.textPrimary)),
                                  Text('Admin',
                                      style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w500,
                                          color: ColorPalette.appetizingOrange)),
                                ],
                              ),
                              const SizedBox(width: 6),
                              const Icon(Icons.keyboard_arrow_down_rounded,
                                  size: 16, color: ColorPalette.textMuted),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // PAGE TITLE BAR + FILTER + ACTION
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildPageTitleBar(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 768;
            final titleWidget = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Quản lý Nhân sự & Phân quyền',
                  style: AppTypography.plusJakarta(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: ColorPalette.onSurfaceDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Phân quyền tài khoản, cấu hình thông tin nhân sự và giám sát trạng thái hoạt động.',
                  style: AppTypography.inter(
                    fontSize: 13,
                    color: ColorPalette.textMuted,
                  ),
                ),
              ],
            );

            final actionsWidget = Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.sync_rounded, size: 16, color: ColorPalette.tertiary),
                    const SizedBox(width: 6),
                    Text(
                      'Đồng bộ lúc 14:28:10',
                      style: AppTypography.inter(
                        fontSize: 12,
                        color: ColorPalette.textMuted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 14),
                ElevatedButton.icon(
                  onPressed: () => _openStaffDialog(context),
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('+ Thêm Nhân Viên'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorPalette.primaryContainer,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    textStyle: AppTypography.inter(fontSize: 13, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            );

            if (isWide) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(child: titleWidget),
                  const SizedBox(width: 16),
                  actionsWidget,
                ],
              );
            } else {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  titleWidget,
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: actionsWidget,
                  ),
                ],
              );
            }
          },
        ),
        const SizedBox(height: 18),
        // Filter toolbar
        _buildFilterToolbar(context),
      ],
    ),
  );
}

  // ═══════════════════════════════════════════════════════════════════════════
  // KPI METRIC CARDS (mockup style: white, icon box, border subtle)
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildKpiMetrics(List<StaffEntity> staffList) {
    final total = staffList.length;
    final active = staffList.where((s) => s.isActive).length;
    final admins = staffList.where((s) => s.role.toUpperCase() == 'ADMIN').length;
    final locked = total - active;

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount =
            constraints.maxWidth > 1050 ? 4 : (constraints.maxWidth > 550 ? 2 : 1);
        final gap = 16.0;
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
              subtitle: '${((active / (total == 0 ? 1 : total)) * 100).round()}% tổng nhân viên',
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
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: ColorPalette.borderSubtle)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(subtitle, style: AppTypography.dashboardSubtitle.copyWith(fontSize: 11)),
                if (trendValue != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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
                          trendPositive ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                          size: 14,
                          color: trendPositive ? ColorPalette.success : ColorPalette.error,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          trendValue,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: trendPositive ? ColorPalette.success : ColorPalette.error,
                          ),
                        ),
                      ],
                    ),
                  ),
                if (isWarning)
                  Icon(Icons.warning_amber_rounded, size: 16, color: ColorPalette.warning),
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

  // ═══════════════════════════════════════════════════════════════════════════
  // ═══════════════════════════════════════════════════════════════════════════
  // PILL FILTER TOOLBAR (mockup style)
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildFilterToolbar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: ColorPalette.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ColorPalette.borderSubtle),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 880;
          return isWide
              ? Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: _buildSearchInputField(),
                    ),
                    const SizedBox(width: 16),
                    _buildPillFilters(),
                  ],
                )
              : Wrap(
                  spacing: 12,
                  runSpacing: 10,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: _buildSearchInputField(),
                    ),
                    _buildPillFilters(),
                  ],
                );
        },
      ),
    );
  }

  Widget _buildSearchInputField() {
    return SizedBox(
      height: 40,
      child: TextField(
        controller: _searchController,
        onChanged: (val) => setState(() => _searchQuery = val.trim()),
        style: const TextStyle(fontSize: 13),
        decoration: InputDecoration(
          hintText: 'Tìm theo họ tên, username, SĐT...',
          hintStyle: const TextStyle(fontSize: 12, color: ColorPalette.textMuted),
          prefixIcon: const Icon(Icons.search_rounded, size: 18, color: ColorPalette.textMuted),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear_rounded, size: 16),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                )
              : null,
          filled: true,
          fillColor: ColorPalette.webBgAdmin.withValues(alpha: 0.6),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: ColorPalette.appetizingOrange, width: 1.5),
          ),
        ),
      ),
    );
  }

  Widget _buildPillFilters() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        // Role pills
        _buildPillFilter(
          label: 'Tất cả',
          isActive: _selectedRole == null && _selectedStatus == null,
          onTap: () {
            _onRoleFilterChanged(null);
            _onStatusFilterChanged(null);
          },
        ),
        _buildPillFilter(
          label: 'Admin',
          isActive: _selectedRole == 'ADMIN',
          onTap: () => _onRoleFilterChanged(
              _selectedRole == 'ADMIN' ? null : 'ADMIN'),
          icon: Icons.shield_rounded,
        ),
        _buildPillFilter(
          label: 'Staff',
          isActive: _selectedRole == 'STAFF',
          onTap: () => _onRoleFilterChanged(
              _selectedRole == 'STAFF' ? null : 'STAFF'),
          icon: Icons.badge_rounded,
        ),
        Container(width: 1, height: 24, color: ColorPalette.borderSubtle),
        _buildPillFilter(
          label: 'Hoạt động',
          isActive: _selectedStatus == true,
          onTap: () => _onStatusFilterChanged(
              _selectedStatus == true ? null : true),
          activeColor: ColorPalette.success,
        ),
        _buildPillFilter(
          label: 'Tạm khóa',
          isActive: _selectedStatus == false,
          onTap: () => _onStatusFilterChanged(
              _selectedStatus == false ? null : false),
          activeColor: ColorPalette.error,
        ),
      ],
    );
  }

  Widget _buildPillFilter({
    required String label,
    required bool isActive,
    required VoidCallback onTap,
    IconData? icon,
    Color? activeColor,
  }) {
    final color = activeColor ?? ColorPalette.appetizingOrange;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isActive ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? color : ColorPalette.borderSubtle,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon,
                  size: 14,
                  color: isActive ? Colors.white : ColorPalette.textMuted),
              const SizedBox(width: 5),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isActive ? Colors.white : ColorPalette.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
            // ═══════════════════════════════════════════════════════════════════════════
  // DATA TABLE / CARD CONTAINER (Responsive & Zoom-Resilient)
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildStaffTableCard(
      BuildContext context, List<StaffEntity> items, int totalPages, int totalCount) {
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
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
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
                      'Hiển thị trang $_currentPage / $totalPages — bao gồm cả admin và nhân viên.',
                      style: AppTypography.inter(fontSize: 12, color: ColorPalette.textMuted),
                    ),
                  ],
                ),
                Wrap(
                  spacing: 10,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    // View Mode Switcher: Table View vs Card Grid View
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
                            isSelected: !_isCardView,
                            onTap: () => setState(() => _isCardView = false),
                          ),
                          _buildViewModeButton(
                            icon: Icons.grid_view_rounded,
                            tooltip: 'Dạng thẻ lưới trực quan',
                            isSelected: _isCardView,
                            onTap: () => setState(() => _isCardView = true),
                          ),
                        ],
                      ),
                    ),
                    // Export button
                    OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.ios_share_rounded, size: 16, color: ColorPalette.tertiary),
                      label: const Text('Xuất Excel / PDF'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: ColorPalette.onSurfaceDark,
                        side: const BorderSide(color: ColorPalette.borderSubtle),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        textStyle: AppTypography.inter(fontSize: 12, fontWeight: FontWeight.w600),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: ColorPalette.borderSubtle),

          // Main Content: Either Proportional Flex Table OR Modern Card Grid
          if (!_isCardView)
            LayoutBuilder(
              builder: (context, constraints) {
                // Stretches to 100% of the available card width!
                // If zoom or screen size makes width < 920, horizontal scroll activates smoothly without squishing.
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
                          final index = e.key + 1 + ((_currentPage - 1) * _pageSize);
                          return _buildProportionalTableRow(context, e.value, index);
                        }),
                      ],
                    ),
                  ),
                );
              },
            )
          else
            _buildStaffCardGrid(context, items),

          // Pagination
          const Divider(height: 1, color: ColorPalette.borderSubtle),
          _buildPagination(totalPages, totalCount),
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
        border: const Border(bottom: BorderSide(color: ColorPalette.borderSubtle)),
      ),
      child: Row(
        children: const [
          SizedBox(width: 44, child: Text('#', style: AppTypography.tableHeader)),
          SizedBox(width: 12),
          Expanded(flex: 4, child: Text('NHÂN VIÊN', style: AppTypography.tableHeader)),
          Expanded(flex: 2, child: Text('VAI TRÒ', style: AppTypography.tableHeader)),
          Expanded(flex: 3, child: Text('LIÊN HỆ', style: AppTypography.tableHeader)),
          Expanded(flex: 3, child: Text('TRẠNG THÁI', style: AppTypography.tableHeader)),
          SizedBox(width: 80, child: Text('THAO TÁC', textAlign: TextAlign.right, style: AppTypography.tableHeader)),
        ],
      ),
    );
  }

  // ─── Proportional Flex Table Row ────────────────────────────────────────────
  Widget _buildProportionalTableRow(BuildContext context, StaffEntity staff, int index) {
    final isAdmin = staff.role.toUpperCase() == 'ADMIN';
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _openStaffDialog(context, staffToEdit: staff),
        hoverColor: ColorPalette.webBgAdmin.withValues(alpha: 0.4),
        child: Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: ColorPalette.borderSubtle, width: 0.5)),
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
                            style: AppTypography.labelLarge.copyWith(fontSize: 13),
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
                  ],
                ),
              ),
              // Role Badge
              Expanded(
                flex: 2,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
                            style: const TextStyle(fontSize: 12, color: ColorPalette.textMuted),
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
                            style: const TextStyle(fontSize: 12, color: ColorPalette.textMuted),
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
                        activeTrackColor: ColorPalette.success.withValues(alpha: 0.3),
                        activeThumbColor: ColorPalette.success,
                        inactiveTrackColor: ColorPalette.error.withValues(alpha: 0.15),
                        inactiveThumbColor: ColorPalette.error.withValues(alpha: 0.6),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        onChanged: (val) {
                          context.read<StaffBloc>().add(ToggleStaffStatusEvent(staff.userId));
                        },
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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
                            color: staff.isActive ? ColorPalette.success : ColorPalette.error,
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
                      backgroundColor: ColorPalette.appetizingOrange.withValues(alpha: 0.08),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      minimumSize: const Size(34, 34),
                    ),
                    onPressed: () => _openStaffDialog(context, staffToEdit: staff),
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
            color: isSelected ? ColorPalette.appetizingOrange : ColorPalette.textMuted,
          ),
        ),
      ),
    );
  }

  // ─── Modern Card Grid View (Alternative Layout) ─────────────────────────────
  Widget _buildStaffCardGrid(BuildContext context, List<StaffEntity> items) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final crossAxisCount = constraints.maxWidth > 1150
              ? 3
              : (constraints.maxWidth > 700 ? 2 : 1);
          final gap = 16.0;
          final cardWidth =
              (constraints.maxWidth - ((crossAxisCount - 1) * gap)) / crossAxisCount;

          return Wrap(
            spacing: gap,
            runSpacing: gap,
            children: items.asMap().entries.map((e) {
              final index = e.key + 1 + ((_currentPage - 1) * _pageSize);
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
                      style: AppTypography.dashboardSubtitle.copyWith(fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isAdmin
                      ? ColorPalette.amber.withValues(alpha: 0.12)
                      : ColorPalette.info.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(6),
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
                      size: 12,
                      color: isAdmin ? const Color(0xFF92400E) : const Color(0xFF1E40AF),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      staff.role,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: isAdmin ? const Color(0xFF92400E) : const Color(0xFF1E40AF),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: ColorPalette.borderSubtle),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.phone_outlined, size: 14, color: ColorPalette.textMuted),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  staff.phone ?? 'Chưa cập nhật SĐT',
                  style: const TextStyle(fontSize: 12, color: ColorPalette.textMuted),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.email_outlined, size: 14, color: ColorPalette.textMuted),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  staff.email ?? 'Chưa cập nhật email',
                  style: const TextStyle(fontSize: 12, color: ColorPalette.textMuted),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: ColorPalette.borderSubtle),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Switch(
                    value: staff.isActive,
                    activeTrackColor: ColorPalette.success.withValues(alpha: 0.3),
                    activeThumbColor: ColorPalette.success,
                    inactiveTrackColor: ColorPalette.error.withValues(alpha: 0.15),
                    inactiveThumbColor: ColorPalette.error.withValues(alpha: 0.6),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    onChanged: (val) {
                      context.read<StaffBloc>().add(ToggleStaffStatusEvent(staff.userId));
                    },
                  ),
                  const SizedBox(width: 6),
                  Text(
                    staff.isActive ? 'Hoạt động' : 'Tạm khóa',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: staff.isActive ? ColorPalette.success : ColorPalette.error,
                    ),
                  ),
                ],
              ),
              OutlinedButton.icon(
                onPressed: () => _openStaffDialog(context, staffToEdit: staff),
                icon: const Icon(Icons.edit_outlined, size: 14),
                label: const Text('Chỉnh sửa'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: ColorPalette.appetizingOrange,
                  side: BorderSide(color: ColorPalette.appetizingOrange.withValues(alpha: 0.4)),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // PAGINATION
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildPagination(int totalPages, int totalCount) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
      child: Wrap(
        spacing: 12,
        runSpacing: 10,
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(
            'Hiển thị trang $_currentPage / $totalPages (Tổng $totalCount nhân viên)',
            style: AppTypography.dashboardSubtitle,
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildPaginationButton(
                icon: Icons.chevron_left_rounded,
                label: 'Trước',
                enabled: _currentPage > 1,
                onTap: () {
                  setState(() => _currentPage--);
                  _loadData();
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: ColorPalette.appetizingOrange,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$_currentPage',
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.white),
                  ),
                ),
              ),
              _buildPaginationButton(
                icon: Icons.chevron_right_rounded,
                label: 'Sau',
                enabled: _currentPage < totalPages,
                onTap: () {
                  setState(() => _currentPage++);
                  _loadData();
                },
                iconRight: true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaginationButton({
    required IconData icon,
    required String label,
    required bool enabled,
    required VoidCallback onTap,
    bool iconRight = false,
  }) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: ColorPalette.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: ColorPalette.borderSubtle),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!iconRight)
              Icon(icon, size: 16,
                  color: enabled ? ColorPalette.textPrimary : ColorPalette.textMuted),
            if (!iconRight) const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: enabled ? ColorPalette.textPrimary : ColorPalette.textMuted,
              ),
            ),
            if (iconRight) const SizedBox(width: 4),
            if (iconRight)
              Icon(icon, size: 16,
                  color: enabled ? ColorPalette.textPrimary : ColorPalette.textMuted),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // EMPTY & ERROR STATES
  // ═══════════════════════════════════════════════════════════════════════════
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
          Icon(Icons.search_off_rounded, size: 48,
              color: ColorPalette.textMuted.withValues(alpha: 0.5)),
          const SizedBox(height: 14),
          Text('Không tìm thấy nhân viên phù hợp',
              style: AppTypography.titleLarge),
          const SizedBox(height: 6),
          Text('Vui lòng thử từ khóa tìm kiếm khác hoặc xóa bộ lọc.',
              style: AppTypography.dashboardSubtitle),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: ColorPalette.error.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.cloud_off_rounded,
                  color: ColorPalette.error, size: 44),
            ),
            const SizedBox(height: 16),
            Text('Không thể tải dữ liệu', style: AppTypography.dashboardHeadline),
            const SizedBox(height: 8),
            Text(message,
                style: AppTypography.dashboardSubtitle, textAlign: TextAlign.center),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _loadData,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Thử Lại'),
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorPalette.appetizingOrange,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // HELPERS
  // ═══════════════════════════════════════════════════════════════════════════
  void _openStaffDialog(BuildContext context, {StaffEntity? staffToEdit}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => BlocProvider.value(
        value: context.read<StaffBloc>(),
        child: StaffFormDialog(staffToEdit: staffToEdit),
      ),
    );
  }

  String _getInitials(String fullName) {
    final parts = fullName.trim().split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return 'U';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }
}
