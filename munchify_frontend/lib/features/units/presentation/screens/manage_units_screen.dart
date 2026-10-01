import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/ColorPalette.dart';
import '../../../../core/theme/AppTypography.dart';
import '../../domain/entities/unit_entity.dart';
import '../bloc/unit_bloc.dart';
import '../bloc/unit_event.dart';
import '../bloc/unit_state.dart';
import '../widgets/unit_form_dialog.dart';
import '../widgets/unit_delete_confirm_dialog.dart';

class ManageUnitsScreen extends StatefulWidget {
  final bool embedInShell;

  const ManageUnitsScreen({super.key, this.embedInShell = false});

  @override
  State<ManageUnitsScreen> createState() => _ManageUnitsScreenState();
}

class _ManageUnitsScreenState extends State<ManageUnitsScreen> {
  int _currentPage = 1;
  static const int _pageSize = 10;
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
    context.read<UnitBloc>().add(
      LoadUnitsEvent(
        searchTerm: '',
        isActive: _selectedStatus,
        page: _currentPage,
        pageSize: _pageSize,
      ),
    );
  }

  void _onStatusFilterChanged(bool? status) {
    setState(() {
      _selectedStatus = status;
      _currentPage = 1;
    });
    _loadData();
  }

  void _showAddUnit() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const UnitFormDialog(),
    );

    if (result != null) {
      if (!mounted) return;
      context.read<UnitBloc>().add(
        CreateUnitEvent(
          unitName: result['unitName'],
          description: result['description'],
          isActive: result['isActive'],
        ),
      );
    }
  }

  void _showEditUnit(UnitEntity unit) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: false,
      builder: (context) => UnitFormDialog(
        id: unit.id,
        initialName: unit.unitName,
        initialDescription: unit.description,
        initialIsActive: unit.isActive,
      ),
    );

    if (result != null) {
      if (!mounted) return;
      context.read<UnitBloc>().add(
        UpdateUnitEvent(
          id: unit.id,
          unitName: result['unitName'],
          description: result['description'],
          isActive: result['isActive'],
        ),
      );
    }
  }

  void _showDeleteConfirm(UnitEntity unit) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => UnitDeleteConfirmDialog(unitName: unit.unitName),
    );

    if (confirmed == true) {
      if (!mounted) return;
      context.read<UnitBloc>().add(DeleteUnitEvent(unit.id));
    }
  }

  void _toggleUnitStatus(UnitEntity unit) {
    context.read<UnitBloc>().add(
      UpdateUnitEvent(
        id: unit.id,
        unitName: unit.unitName,
        description: unit.description,
        isActive: !unit.isActive,
      ),
    );
  }

  String _getInitials(String name) {
    if (name.isEmpty) return 'U';
    final parts = name.trim().split(' ');
    if (parts.length > 1) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final bodyContent = BlocConsumer<UnitBloc, UnitState>(
      listener: (context, state) {
        if (state is UnitLoaded && state.successMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(
                    Icons.check_circle_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      state.successMessage!,
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
              backgroundColor: ColorPalette.success,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              margin: const EdgeInsets.all(16),
            ),
          );
        } else if (state is UnitError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(
                    Icons.error_outline_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      state.message,
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
              backgroundColor: ColorPalette.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              margin: const EdgeInsets.all(16),
            ),
          );
        }
      },
      buildWhen: (previous, current) =>
          current is UnitLoading ||
          current is UnitLoaded ||
          current is UnitError,
      builder: (context, state) {
        if (state is UnitLoading) {
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
                Text(
                  'Đang đồng bộ đơn vị tính...',
                  style: AppTypography.dashboardSubtitle,
                ),
              ],
            ),
          );
        } else if (state is UnitError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 48,
                  color: ColorPalette.error,
                ),
                const SizedBox(height: 16),
                Text(
                  'Đã xảy ra lỗi: ${state.message}',
                  style: const TextStyle(color: ColorPalette.error),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _loadData,
                  child: const Text('Thử lại'),
                ),
              ],
            ),
          );
        } else if (state is UnitLoaded) {
          final allItems = state.units;

          final filteredItems = allItems.where((u) {
            if (_searchQuery.isEmpty) return true;
            final q = _searchQuery.toLowerCase();
            return u.unitName.toLowerCase().contains(q) ||
                (u.description?.toLowerCase().contains(q) ?? false);
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
                _buildTableCard(context, filteredItems, state.isListEnd),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );

    if (widget.embedInShell) {
      return Scaffold(
        backgroundColor: ColorPalette.webBgAdmin,
        body: bodyContent,
      );
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
  // STICKY HEADER
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
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: ColorPalette.appetizingOrange.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.lunch_dining_rounded,
                  color: ColorPalette.appetizingOrange,
                  size: 22,
                ),
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
                Row(
                  children: [
                    const Icon(
                      Icons.chevron_right_rounded,
                      size: 18,
                      color: ColorPalette.textMuted,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Trang chủ',
                      style: AppTypography.labelSmall.copyWith(
                        color: ColorPalette.textMuted,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 6),
                      child: Text(
                        '/',
                        style: TextStyle(
                          color: ColorPalette.textMuted,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    Text(
                      'Đơn vị tính',
                      style: AppTypography.labelSmall.copyWith(
                        color: ColorPalette.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
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
                      if (!isNarrow) ...[
                        SizedBox(
                          width: 240,
                          height: 38,
                          child: TextField(
                            onChanged: (val) =>
                                setState(() => _searchQuery = val.trim()),
                            controller: _searchController,
                            style: const TextStyle(fontSize: 13),
                            decoration: InputDecoration(
                              hintText: 'Tìm nhanh...',
                              hintStyle: const TextStyle(
                                fontSize: 12,
                                color: ColorPalette.textMuted,
                              ),
                              prefixIcon: const Icon(
                                Icons.search_rounded,
                                size: 18,
                                color: ColorPalette.textMuted,
                              ),
                              filled: true,
                              fillColor: ColorPalette.webBgAdmin.withValues(
                                alpha: 0.7,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                  color: ColorPalette.borderSubtle,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                  color: ColorPalette.borderSubtle,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                  color: ColorPalette.appetizingOrange,
                                  width: 1.5,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                      if (!isVeryNarrow) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
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
                                  color: ColorPalette.success,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Text(
                                'Online',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: ColorPalette.success,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                      ],
                      IconButton(
                        onPressed: _loadData,
                        icon: const Icon(
                          Icons.refresh_rounded,
                          size: 20,
                          color: ColorPalette.textMuted,
                        ),
                        tooltip: 'Tải lại',
                        style: IconButton.styleFrom(
                          backgroundColor: ColorPalette.webBgAdmin,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: ColorPalette.borderSubtle),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            const CircleAvatar(
                              radius: 14,
                              backgroundColor:
                                  ColorPalette.surfaceContainerHigh,
                              child: Text(
                                'AD',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: ColorPalette.appetizingOrange,
                                ),
                              ),
                            ),
                            if (!isVeryNarrow) ...[
                              const SizedBox(width: 8),
                              const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Admin',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: ColorPalette.textPrimary,
                                    ),
                                  ),
                                  Text(
                                    'Quản trị',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                      color: ColorPalette.appetizingOrange,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 6),
                              const Icon(
                                Icons.keyboard_arrow_down_rounded,
                                size: 16,
                                color: ColorPalette.textMuted,
                              ),
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
                    'Quản lý Đơn vị tính',
                    style: AppTypography.plusJakarta(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: ColorPalette.onSurfaceDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Quản lý các đơn vị tính cho sản phẩm (Bịch, Gói, Lon, Chai, Ly...).',
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
                      const Icon(
                        Icons.sync_rounded,
                        size: 16,
                        color: ColorPalette.tertiary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Đồng bộ lúc ${DateFormat('HH:mm:ss').format(DateTime.now())}',
                        style: AppTypography.inter(
                          fontSize: 12,
                          color: ColorPalette.textMuted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 14),
                  ElevatedButton.icon(
                    onPressed: _showAddUnit,
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: const Text('Thêm Đơn vị'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorPalette.primaryContainer,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 12,
                      ),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      textStyle: AppTypography.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
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
          _buildFilterToolbar(context),
        ],
      ),
    );
  }

  Widget _buildFilterToolbar(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 700;
        final filterChips = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _filterChip('Tất cả', null),
            const SizedBox(width: 8),
            _filterChip('Hoạt động', true),
            const SizedBox(width: 8),
            _filterChip('Tạm ngưng', false),
          ],
        );
        final viewToggle = Container(
          decoration: BoxDecoration(
            color: ColorPalette.surfaceWhite,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: ColorPalette.borderSubtle),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _viewToggleBtn(
                Icons.table_rows_rounded,
                !_isCardView,
                () => setState(() => _isCardView = false),
                tooltip: 'Dạng bảng',
              ),
              _viewToggleBtn(
                Icons.grid_view_rounded,
                _isCardView,
                () => setState(() => _isCardView = true),
                tooltip: 'Dạng thẻ',
              ),
            ],
          ),
        );

        if (isNarrow) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: filterChips,
              ),
              const SizedBox(height: 10),
              Align(alignment: Alignment.centerRight, child: viewToggle),
            ],
          );
        }
        return Row(children: [filterChips, const Spacer(), viewToggle]);
      },
    );
  }

  Widget _filterChip(String label, bool? value) {
    final isSelected = _selectedStatus == value;
    return GestureDetector(
      onTap: () => _onStatusFilterChanged(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected
              ? ColorPalette.appetizingOrange
              : ColorPalette.surfaceWhite,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? ColorPalette.appetizingOrange
                : ColorPalette.borderSubtle,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : ColorPalette.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _viewToggleBtn(
    IconData icon,
    bool active,
    VoidCallback onTap, {
    String? tooltip,
  }) {
    return Tooltip(
      message: tooltip ?? '',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(7),
        child: Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: active
                ? ColorPalette.appetizingOrange.withValues(alpha: 0.12)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(7),
          ),
          child: Icon(
            icon,
            size: 18,
            color: active
                ? ColorPalette.appetizingOrange
                : ColorPalette.textMuted,
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // KPI METRICS
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildKpiMetrics(List<UnitEntity> unitList) {
    final total = unitList.length;
    final active = unitList.where((u) => u.isActive).length;
    final inactive = total - active;

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
            _buildMetricCard(
              title: 'TỔNG ĐƠN VỊ TÍNH',
              value: total.toString(),
              subtitle: 'Tất cả đơn vị đo lường',
              icon: Icons.straighten_rounded,
              iconColor: ColorPalette.primaryContainer,
              iconBg: ColorPalette.primaryFixed.withValues(alpha: 0.6),
              width: cardWidth,
            ),
            _buildMetricCard(
              title: 'ĐANG SỬ DỤNG',
              value: active.toString(),
              subtitle:
                  '${((active / (total == 0 ? 1 : total)) * 100).round()}% tổng đơn vị',
              icon: Icons.check_circle_outline_rounded,
              iconColor: ColorPalette.tertiary,
              iconBg: ColorPalette.tertiary.withValues(alpha: 0.1),
              width: cardWidth,
              trendValue: '+$active',
              trendPositive: true,
            ),
            _buildMetricCard(
              title: 'TẠM NGƯNG',
              value: inactive.toString(),
              subtitle: 'Không sử dụng trong POS',
              icon: Icons.block_rounded,
              iconColor: ColorPalette.dangerCrimson,
              iconBg: ColorPalette.dangerCrimson.withValues(alpha: 0.08),
              width: cardWidth,
              isWarning: inactive > 0,
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
          // Gradient accent bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 3,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isWarning
                      ? [ColorPalette.dangerCrimson, ColorPalette.error]
                      : [iconColor, iconColor.withValues(alpha: 0.6)],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 18),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: iconColor, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTypography.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: ColorPalette.textMuted,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        value,
                        style: AppTypography.plusJakarta(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: ColorPalette.onSurfaceDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              subtitle,
                              style: AppTypography.inter(
                                fontSize: 11,
                                color: ColorPalette.textMuted,
                              ),
                            ),
                          ),
                          if (trendValue != null) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: trendPositive
                                    ? ColorPalette.success.withValues(
                                        alpha: 0.1,
                                      )
                                    : ColorPalette.error.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                trendValue,
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: trendPositive
                                      ? ColorPalette.success
                                      : ColorPalette.error,
                                ),
                              ),
                            ),
                          ],
                        ],
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

  // ═══════════════════════════════════════════════════════════════════════════
  // TABLE / CARD CONTENT
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildTableCard(
    BuildContext context,
    List<UnitEntity> items,
    bool isListEnd,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: ColorPalette.surfaceWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ColorPalette.borderSubtle),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Table Header Bar
          _buildTableHeaderBar(items.length),
          // Content
          _isCardView ? _buildCardGrid(items) : _buildDataTable(items),
          // Pagination
          _buildPaginationBar(items.length, isListEnd),
        ],
      ),
    );
  }

  Widget _buildTableHeaderBar(int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: ColorPalette.surfaceWhite,
        border: Border(bottom: BorderSide(color: ColorPalette.borderSubtle)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: ColorPalette.appetizingOrange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.straighten_rounded,
              color: ColorPalette.appetizingOrange,
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            'Danh sách đơn vị tính',
            style: AppTypography.plusJakarta(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: ColorPalette.onSurfaceDark,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: ColorPalette.primaryFixed.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$count kết quả',
              style: AppTypography.inter(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: ColorPalette.primaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── DATA TABLE ──
  Widget _buildDataTable(List<UnitEntity> items) {
    if (items.isEmpty) return _buildEmptyState();

    return LayoutBuilder(
      builder: (context, constraints) {
        final effectiveWidth = math.max(800.0, constraints.maxWidth);
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
                  return _buildProportionalTableRow(e.value, index);
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProportionalTableHeader() {
    const headerStyle = TextStyle(
      fontFamily: 'Inter',
      fontSize: 11,
      fontWeight: FontWeight.w700,
      color: ColorPalette.textMuted,
      letterSpacing: 0.4,
    );
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: ColorPalette.webBgAdmin.withValues(alpha: 0.8),
        border: const Border(
          bottom: BorderSide(color: ColorPalette.borderSubtle),
        ),
      ),
      child: const Row(
        children: [
          SizedBox(width: 44, child: Text('#', style: headerStyle)),
          SizedBox(width: 12),
          Expanded(flex: 3, child: Text('ĐƠN VỊ TÍNH', style: headerStyle)),
          Expanded(flex: 5, child: Text('MÔ TẢ', style: headerStyle)),
          Expanded(flex: 3, child: Text('TRẠNG THÁI', style: headerStyle)),
          SizedBox(
            width: 90,
            child: Text(
              'THAO TÁC',
              textAlign: TextAlign.right,
              style: headerStyle,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProportionalTableRow(UnitEntity unit, int index) {
    final initials = _getInitials(unit.unitName);
    final colors = [
      const Color(0xFFE65100),
      const Color(0xFF1565C0),
      const Color(0xFF2E7D32),
      const Color(0xFF6A1B9A),
      const Color(0xFF00838F),
    ];
    final avatarColor = colors[unit.id % colors.length];

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _showEditUnit(unit),
        hoverColor: ColorPalette.webBgAdmin.withValues(alpha: 0.4),
        child: Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: ColorPalette.borderSubtle, width: 0.5),
            ),
          ),
          child: Row(
            children: [
              // STT
              SizedBox(
                width: 44,
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
              const SizedBox(width: 12),
              // Đơn vị tính
              Expanded(
                flex: 3,
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: avatarColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        initials,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: avatarColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            unit.unitName,
                            style: AppTypography.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: ColorPalette.onSurfaceDark,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'ID #${unit.id}',
                            style: AppTypography.inter(
                              fontSize: 11,
                              color: ColorPalette.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Mô tả
              Expanded(
                flex: 5,
                child: Text(
                  unit.description?.isNotEmpty == true
                      ? unit.description!
                      : '—',
                  style: AppTypography.inter(
                    fontSize: 13,
                    color: unit.description?.isNotEmpty == true
                        ? ColorPalette.textSecondary
                        : ColorPalette.textMuted,
                    fontStyle: unit.description?.isNotEmpty == true
                        ? FontStyle.normal
                        : FontStyle.italic,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // Trạng thái
              Expanded(
                flex: 3,
                child: Row(
                  children: [
                    Switch(
                      value: unit.isActive,
                      activeColor: ColorPalette.success,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      onChanged: (_) => _toggleUnitStatus(unit),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: unit.isActive
                            ? ColorPalette.success.withValues(alpha: 0.1)
                            : ColorPalette.dangerCrimson.withValues(
                                alpha: 0.08,
                              ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        unit.isActive ? 'Hoạt động' : 'Tạm ngưng',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: unit.isActive
                              ? ColorPalette.success
                              : ColorPalette.dangerCrimson,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Thao tác
              SizedBox(
                width: 90,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _actionIconBtn(
                      icon: Icons.edit_rounded,
                      tooltip: 'Chỉnh sửa',
                      color: ColorPalette.primaryContainer,
                      bg: ColorPalette.primaryFixed.withValues(alpha: 0.5),
                      onTap: () => _showEditUnit(unit),
                    ),
                    const SizedBox(width: 8),
                    _actionIconBtn(
                      icon: Icons.delete_outline_rounded,
                      tooltip: 'Xóa',
                      color: ColorPalette.dangerCrimson,
                      bg: ColorPalette.dangerCrimson.withValues(alpha: 0.08),
                      onTap: () => _showDeleteConfirm(unit),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _actionIconBtn({
    required IconData icon,
    required String tooltip,
    required Color color,
    required Color bg,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 16),
        ),
      ),
    );
  }

  // ── CARD GRID ──
  Widget _buildCardGrid(List<UnitEntity> items) {
    if (items.isEmpty) return _buildEmptyState();

    return Padding(
      padding: const EdgeInsets.all(20),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final crossAxisCount = constraints.maxWidth > 900
              ? 4
              : constraints.maxWidth > 650
              ? 3
              : constraints.maxWidth > 440
              ? 2
              : 1;
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.6,
            ),
            itemCount: items.length,
            itemBuilder: (context, index) => _buildUnitCard(items[index]),
          );
        },
      ),
    );
  }

  Widget _buildUnitCard(UnitEntity unit) {
    final colors = [
      const Color(0xFFE65100),
      const Color(0xFF1565C0),
      const Color(0xFF2E7D32),
      const Color(0xFF6A1B9A),
      const Color(0xFF00838F),
    ];
    final color = colors[unit.id % colors.length];

    return Container(
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
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 3,
              color: unit.isActive ? color : ColorPalette.borderSubtle,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 16, 14, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          _getInitials(unit.unitName),
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: color,
                          ),
                        ),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: unit.isActive
                            ? ColorPalette.success.withValues(alpha: 0.1)
                            : ColorPalette.dangerCrimson.withValues(
                                alpha: 0.08,
                              ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        unit.isActive ? 'Hoạt động' : 'Tạm ngưng',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: unit.isActive
                              ? ColorPalette.success
                              : ColorPalette.dangerCrimson,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  unit.unitName,
                  style: AppTypography.plusJakarta(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: ColorPalette.onSurfaceDark,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (unit.description?.isNotEmpty == true) ...[
                  const SizedBox(height: 2),
                  Text(
                    unit.description!,
                    style: AppTypography.inter(
                      fontSize: 11,
                      color: ColorPalette.textMuted,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _actionIconBtn(
                      icon: Icons.edit_rounded,
                      tooltip: 'Chỉnh sửa',
                      color: ColorPalette.primaryContainer,
                      bg: ColorPalette.primaryFixed.withValues(alpha: 0.5),
                      onTap: () => _showEditUnit(unit),
                    ),
                    const SizedBox(width: 6),
                    _actionIconBtn(
                      icon: Icons.delete_outline_rounded,
                      tooltip: 'Xóa',
                      color: ColorPalette.dangerCrimson,
                      bg: ColorPalette.dangerCrimson.withValues(alpha: 0.08),
                      onTap: () => _showDeleteConfirm(unit),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── EMPTY STATE ──
  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Center(
        child: Column(
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: ColorPalette.appetizingOrange.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.straighten_rounded,
                color: ColorPalette.appetizingOrange,
                size: 36,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Không tìm thấy đơn vị tính',
              style: AppTypography.plusJakarta(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: ColorPalette.onSurfaceDark,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Thử thay đổi bộ lọc hoặc thêm đơn vị mới.',
              style: AppTypography.inter(
                fontSize: 13,
                color: ColorPalette.textMuted,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _showAddUnit,
              icon: const Icon(Icons.add_rounded, size: 16),
              label: const Text('Thêm Đơn vị mới'),
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorPalette.appetizingOrange,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                textStyle: AppTypography.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── PAGINATION ──
  Widget _buildPaginationBar(int count, bool isListEnd) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: ColorPalette.webBgAdmin.withValues(alpha: 0.5),
        border: Border(top: BorderSide(color: ColorPalette.borderSubtle)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Hiển thị $count kết quả · Trang $_currentPage',
            style: AppTypography.inter(
              fontSize: 12,
              color: ColorPalette.textMuted,
            ),
          ),
          Row(
            children: [
              _paginationBtn(
                icon: Icons.chevron_left_rounded,
                enabled: _currentPage > 1,
                onTap: () {
                  setState(() => _currentPage--);
                  _loadData();
                },
                tooltip: 'Trang trước',
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: ColorPalette.appetizingOrange,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '$_currentPage',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              _paginationBtn(
                icon: Icons.chevron_right_rounded,
                enabled: !isListEnd,
                onTap: () {
                  setState(() => _currentPage++);
                  _loadData();
                },
                tooltip: 'Trang tiếp',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _paginationBtn({
    required IconData icon,
    required bool enabled,
    required VoidCallback onTap,
    String? tooltip,
  }) {
    return Tooltip(
      message: tooltip ?? '',
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: enabled
                ? ColorPalette.surfaceWhite
                : ColorPalette.webBgAdmin,
            border: Border.all(color: ColorPalette.borderSubtle),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(
            icon,
            size: 18,
            color: enabled
                ? ColorPalette.textSecondary
                : ColorPalette.textMuted,
          ),
        ),
      ),
    );
  }
}
