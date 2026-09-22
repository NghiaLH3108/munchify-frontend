import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/ColorPalette.dart';
import '../../../../core/theme/AppTypography.dart';
import '../../domain/entities/category_entity.dart';
import '../bloc/category_bloc.dart';
import '../bloc/category_event.dart';
import '../bloc/category_state.dart';
import '../widgets/category_form_dialog.dart';
import '../widgets/delete_confirm_dialog.dart';

class ManageCategoriesScreen extends StatefulWidget {
  final bool embedInShell;

  const ManageCategoriesScreen({
    super.key,
    this.embedInShell = false,
  });

  @override
  State<ManageCategoriesScreen> createState() => _ManageCategoriesScreenState();
}

class _ManageCategoriesScreenState extends State<ManageCategoriesScreen> {
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
    context.read<CategoryBloc>().add(LoadCategoriesEvent(
          searchTerm: '', // Local search used for immediate response
          isActive: _selectedStatus,
          page: _currentPage,
          pageSize: _pageSize,
        ));
  }

  void _onStatusFilterChanged(bool? status) {
    setState(() {
      _selectedStatus = status;
      _currentPage = 1;
    });
    _loadData();
  }

  void _showAddCategory() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const CategoryFormDialog(),
    );

    if (result != null) {
      if (!mounted) return;
      context.read<CategoryBloc>().add(CreateCategoryEvent(
            categoryName: result['categoryName'],
            description: result['description'],
            isActive: result['isActive'],
          ));
    }
  }

  void _showEditCategory(int id, String name, String? desc, bool isActive) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: false,
      builder: (context) => CategoryFormDialog(
        id: id,
        initialName: name,
        initialDescription: desc,
        initialIsActive: isActive,
      ),
    );

    if (result != null) {
      if (!mounted) return;
      context.read<CategoryBloc>().add(UpdateCategoryEvent(
            id: id,
            categoryName: result['categoryName'],
            description: result['description'],
            isActive: result['isActive'],
          ));
    }
  }

  void _showDeleteConfirm(int id, String name) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => DeleteConfirmDialog(categoryName: name),
    );

    if (confirmed == true) {
      if (!mounted) return;
      context.read<CategoryBloc>().add(DeleteCategoryEvent(id));
    }
  }

  void _toggleCategoryStatus(CategoryEntity cat) {
    context.read<CategoryBloc>().add(UpdateCategoryEvent(
          id: cat.id,
          categoryName: cat.categoryName,
          description: cat.description,
          isActive: !cat.isActive,
        ));
  }

  String _getInitials(String name) {
    if (name.isEmpty) return 'C';
    final parts = name.trim().split(' ');
    if (parts.length > 1) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final bodyContent = BlocConsumer<CategoryBloc, CategoryState>(
      listener: (context, state) {
        if (state is CategoryLoaded && state.successMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
                  const SizedBox(width: 10),
                  Expanded(child: Text(state.successMessage!, style: const TextStyle(fontSize: 13))),
                ],
              ),
              backgroundColor: ColorPalette.success,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              margin: const EdgeInsets.all(16),
            ),
          );
          // Reload if action was successful, wait, if CategoryLoaded is emitted it might already have new items.
          // In staff_management_screen they call _loadData() on StaffActionSuccess.
          // For CategoryLoaded, it's just state loaded, no need to load data again if the bloc does it.
          // But to be safe if bloc doesn't reload automatically, we'll see.
        } else if (state is CategoryError) {
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
          current is CategoryLoading || current is CategoryLoaded || current is CategoryError,
      builder: (context, state) {
        if (state is CategoryLoading && state is! CategoryLoaded) {
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
                Text('Đang đồng bộ danh mục...', style: AppTypography.dashboardSubtitle),
              ],
            ),
          );
        } else if (state is CategoryError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: ColorPalette.error),
                const SizedBox(height: 16),
                Text('Đã xảy ra lỗi: ${state.message}', style: const TextStyle(color: ColorPalette.error)),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _loadData,
                  child: const Text('Thử lại'),
                ),
              ],
            ),
          );
        } else if (state is CategoryLoaded) {
          final allItems = state.categories;
          
          final filteredItems = allItems.where((cat) {
            if (_searchQuery.isEmpty) return true;
            final q = _searchQuery.toLowerCase();
            return cat.categoryName.toLowerCase().contains(q) ||
                (cat.description?.toLowerCase().contains(q) ?? false);
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
                    Text('Danh mục',
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
                      if (!isNarrow) ...[
                        SizedBox(
                          width: 240,
                          height: 38,
                          child: TextField(
                            onChanged: (val) => setState(() => _searchQuery = val.trim()),
                            style: const TextStyle(fontSize: 13),
                            decoration: InputDecoration(
                              hintText: 'Tìm nhanh... (Ctrl+K)',
                              hintStyle: const TextStyle(fontSize: 12, color: ColorPalette.textMuted),
                              prefixIcon: const Icon(Icons.search_rounded, size: 18, color: ColorPalette.textMuted),
                              filled: true,
                              fillColor: ColorPalette.webBgAdmin.withValues(alpha: 0.7),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(color: ColorPalette.borderSubtle),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(color: ColorPalette.borderSubtle),
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
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          border: Border.all(color: ColorPalette.borderSubtle),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            const CircleAvatar(
                              radius: 14,
                              backgroundColor: ColorPalette.surfaceContainerHigh,
                              child: Text('AD',
                                  style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: ColorPalette.appetizingOrange)),
                            ),
                            if (!isVeryNarrow) ...[
                              const SizedBox(width: 8),
                              const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Admin',
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: ColorPalette.textPrimary)),
                                  Text('Quản trị',
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
                    'Quản lý Danh mục',
                    style: AppTypography.plusJakarta(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: ColorPalette.onSurfaceDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Quản lý các nhóm sản phẩm trong thực đơn và điểm bán.',
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
                    onPressed: _showAddCategory,
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: const Text('+ Thêm Danh mục'),
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
          _buildFilterToolbar(context),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // KPI METRICS
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildKpiMetrics(List<CategoryEntity> catList) {
    final total = catList.length;
    final active = catList.where((c) => c.isActive).length;
    final locked = total - active;
    final totalProducts = catList.fold<int>(0, (sum, item) => sum + item.productCount);

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
              title: 'TỔNG DANH MỤC',
              value: total.toString(),
              subtitle: 'Tất cả nhóm sản phẩm',
              icon: Icons.category_rounded,
              iconColor: ColorPalette.primaryContainer,
              iconBg: ColorPalette.primaryFixed.withValues(alpha: 0.6),
              width: cardWidth,
            ),
            _buildMetricCard(
              title: 'ĐANG KINH DOANH',
              value: active.toString(),
              subtitle: '${((active / (total == 0 ? 1 : total)) * 100).round()}% tổng danh mục',
              icon: Icons.storefront_rounded,
              iconColor: ColorPalette.tertiary,
              iconBg: ColorPalette.tertiary.withValues(alpha: 0.1),
              width: cardWidth,
              trendValue: '+${active > 0 ? active : 0}',
              trendPositive: true,
            ),
            _buildMetricCard(
              title: 'TỔNG SẢN PHẨM',
              value: totalProducts.toString(),
              subtitle: 'Trong tất cả danh mục',
              icon: Icons.fastfood_rounded,
              iconColor: ColorPalette.adminPurple,
              iconBg: ColorPalette.adminPurple.withValues(alpha: 0.1),
              width: cardWidth,
            ),
            _buildMetricCard(
              title: 'TẠM NGƯNG',
              value: locked.toString(),
              subtitle: 'Ngừng kinh doanh',
              icon: Icons.remove_circle_outline_rounded,
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
                        const Icon(Icons.warning_amber_rounded, size: 16, color: ColorPalette.warning),
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
  // PILL FILTER TOOLBAR
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
          hintText: 'Tìm theo tên danh mục, mô tả...',
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
        _buildPillFilter(
          label: 'Tất cả',
          isActive: _selectedStatus == null,
          onTap: () {
            _onStatusFilterChanged(null);
          },
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
          label: 'Ngừng hoạt động',
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
  // DATA TABLE / CARD
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildTableCard(BuildContext context, List<CategoryEntity> items, bool isListEnd) {
    if (items.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: ColorPalette.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: ColorPalette.borderSubtle),
        ),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.category_outlined, size: 60, color: ColorPalette.textMuted.withValues(alpha: 0.5)),
              const SizedBox(height: 16),
              const Text('Chưa có danh mục nào phù hợp', style: TextStyle(color: ColorPalette.textMuted, fontSize: 16)),
            ],
          ),
        ),
      );
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
                          'Danh sách danh mục',
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
                            '${items.length} mục',
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
                      'Hiển thị trang $_currentPage.',
                      style: AppTypography.inter(fontSize: 12, color: ColorPalette.textMuted),
                    ),
                  ],
                ),
                Wrap(
                  spacing: 10,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
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
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: ColorPalette.borderSubtle),

          if (!_isCardView)
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
            _buildCardGrid(context, items),

          const Divider(height: 1, color: ColorPalette.borderSubtle),
          _buildPagination(isListEnd),
        ],
      ),
    );
  }

  Widget _buildProportionalTableHeader() {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: ColorPalette.webBgAdmin.withValues(alpha: 0.8),
        border: const Border(bottom: BorderSide(color: ColorPalette.borderSubtle)),
      ),
      child: const Row(
        children: [
          SizedBox(width: 44, child: Text('#', style: AppTypography.tableHeader)),
          SizedBox(width: 12),
          Expanded(flex: 3, child: Text('TÊN DANH MỤC', style: AppTypography.tableHeader)),
          Expanded(flex: 4, child: Text('MÔ TẢ', style: AppTypography.tableHeader)),
          Expanded(flex: 2, child: Text('SẢN PHẨM', style: AppTypography.tableHeader)),
          Expanded(flex: 2, child: Text('TRẠNG THÁI', style: AppTypography.tableHeader)),
          SizedBox(width: 90, child: Text('THAO TÁC', textAlign: TextAlign.right, style: AppTypography.tableHeader)),
        ],
      ),
    );
  }

  Widget _buildProportionalTableRow(BuildContext context, CategoryEntity cat, int index) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _showEditCategory(cat.id, cat.categoryName, cat.description, cat.isActive),
        hoverColor: ColorPalette.webBgAdmin.withValues(alpha: 0.4),
        child: Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: ColorPalette.borderSubtle, width: 0.5)),
          ),
          child: Row(
            children: [
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
              Expanded(
                flex: 3,
                child: Row(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: ColorPalette.primaryFixed,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        _getInitials(cat.categoryName),
                        style: const TextStyle(
                          color: ColorPalette.primaryContainer,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        cat.categoryName,
                        style: AppTypography.labelLarge.copyWith(fontSize: 13),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 4,
                child: Text(
                  cat.description ?? '—',
                  style: const TextStyle(fontSize: 12, color: ColorPalette.textMuted),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Expanded(
                flex: 2,
                child: Row(
                  children: [
                    const Icon(Icons.fastfood_rounded, size: 14, color: ColorPalette.textMuted),
                    const SizedBox(width: 6),
                    Text(
                      '${cat.productCount} món',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: ColorPalette.textPrimary),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Switch(
                        value: cat.isActive,
                        activeTrackColor: ColorPalette.success.withValues(alpha: 0.3),
                        activeThumbColor: ColorPalette.success,
                        inactiveTrackColor: ColorPalette.error.withValues(alpha: 0.15),
                        inactiveThumbColor: ColorPalette.error.withValues(alpha: 0.6),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        onChanged: (val) => _toggleCategoryStatus(cat),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: cat.isActive
                              ? ColorPalette.success.withValues(alpha: 0.08)
                              : ColorPalette.error.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          cat.isActive ? 'Hoạt động' : 'Đã ẩn',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: cat.isActive ? ColorPalette.success : ColorPalette.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                width: 90,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, size: 18),
                        color: ColorPalette.appetizingOrange,
                        tooltip: 'Chỉnh sửa',
                        style: IconButton.styleFrom(
                          backgroundColor: ColorPalette.appetizingOrange.withValues(alpha: 0.08),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          minimumSize: const Size(34, 34),
                        ),
                        onPressed: () => _showEditCategory(cat.id, cat.categoryName, cat.description, cat.isActive),
                      ),
                      const SizedBox(width: 6),
                      IconButton(
                        icon: const Icon(Icons.delete_outline_rounded, size: 18),
                        color: ColorPalette.dangerCrimson,
                        tooltip: 'Xóa',
                        style: IconButton.styleFrom(
                          backgroundColor: ColorPalette.dangerCrimson.withValues(alpha: 0.08),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          minimumSize: const Size(34, 34),
                        ),
                        onPressed: () => _showDeleteConfirm(cat.id, cat.categoryName),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

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

  Widget _buildCardGrid(BuildContext context, List<CategoryEntity> items) {
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
                child: _buildCategoryCard(context, e.value, index),
              );
            }).toList(),
          );
        },
      ),
    );
  }

  Widget _buildCategoryCard(BuildContext context, CategoryEntity cat, int index) {
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
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: ColorPalette.primaryFixed,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Text(
                  _getInitials(cat.categoryName),
                  style: const TextStyle(
                    color: ColorPalette.primaryContainer,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cat.categoryName,
                      style: AppTypography.labelLarge.copyWith(fontSize: 14),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${cat.productCount} sản phẩm',
                      style: AppTypography.dashboardSubtitle.copyWith(fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 16),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
                    color: ColorPalette.appetizingOrange,
                    onPressed: () => _showEditCategory(cat.id, cat.categoryName, cat.description, cat.isActive),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded, size: 16),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
                    color: ColorPalette.dangerCrimson,
                    onPressed: () => _showDeleteConfirm(cat.id, cat.categoryName),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: ColorPalette.borderSubtle),
          const SizedBox(height: 12),
          Text(
            cat.description != null && cat.description!.isNotEmpty
                ? cat.description!
                : 'Không có mô tả',
            style: TextStyle(
              fontSize: 12,
              color: cat.description != null && cat.description!.isNotEmpty
                  ? ColorPalette.textPrimary
                  : ColorPalette.textMuted,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
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
                    value: cat.isActive,
                    activeTrackColor: ColorPalette.success.withValues(alpha: 0.3),
                    activeThumbColor: ColorPalette.success,
                    inactiveTrackColor: ColorPalette.error.withValues(alpha: 0.15),
                    inactiveThumbColor: ColorPalette.error.withValues(alpha: 0.6),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    onChanged: (val) => _toggleCategoryStatus(cat),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    cat.isActive ? 'Hoạt động' : 'Đã ẩn',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: cat.isActive ? ColorPalette.success : ColorPalette.error,
                    ),
                  ),
                ],
              ),
              if (cat.createdAt != null)
                Text(
                  'Tạo lúc: ${DateFormat('dd/MM/yyyy').format(cat.createdAt!)}',
                  style: const TextStyle(fontSize: 10, color: ColorPalette.textMuted),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPagination(bool isListEnd) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
      child: Wrap(
        spacing: 12,
        runSpacing: 10,
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(
            'Đang ở trang $_currentPage',
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
                enabled: !isListEnd,
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
}
