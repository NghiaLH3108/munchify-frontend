import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/ColorPalette.dart';
import '../../../../core/theme/AppTypography.dart';
import '../../../../core/widgets/admin/admin_widgets.dart';
import '../../../../core/widgets/app_pagination_bar.dart';
import '../../domain/entities/category_entity.dart';
import '../bloc/category_bloc.dart';
import '../bloc/category_event.dart';
import '../bloc/category_state.dart';
import '../widgets/category_form_dialog.dart';
import '../widgets/delete_confirm_dialog.dart';
import '../../../../core/widgets/app_toast.dart';

class ManageCategoriesScreen extends StatefulWidget {
  final bool embedInShell;

  const ManageCategoriesScreen({super.key, this.embedInShell = false});

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
    context.read<CategoryBloc>().add(
      LoadCategoriesEvent(
        searchTerm: '', // Local search used for immediate response
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

  void _showAddCategory() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const CategoryFormDialog(),
    );

    if (result != null) {
      if (!mounted) return;
      context.read<CategoryBloc>().add(
        CreateCategoryEvent(
          categoryName: result['categoryName'],
          description: result['description'],
          isActive: result['isActive'],
        ),
      );
    }
  }

  void _showEditCategory(
    int id,
    String name,
    String? desc,
    bool isActive,
  ) async {
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
      context.read<CategoryBloc>().add(
        UpdateCategoryEvent(
          id: id,
          categoryName: result['categoryName'],
          description: result['description'],
          isActive: result['isActive'],
        ),
      );
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
    context.read<CategoryBloc>().add(
      UpdateCategoryEvent(
        id: cat.id,
        categoryName: cat.categoryName,
        description: cat.description,
        isActive: !cat.isActive,
      ),
    );
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
          AppToast.success(state.successMessage!, context: context);
        } else if (state is CategoryError) {
          AppToast.error(state.message, context: context);
        }
      },
      buildWhen: (previous, current) =>
          current is CategoryLoading ||
          current is CategoryLoaded ||
          current is CategoryError,
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
                Text(
                  'Đang đồng bộ danh mục...',
                  style: AppTypography.dashboardSubtitle,
                ),
              ],
            ),
          );
        } else if (state is CategoryError) {
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
        } else if (state is CategoryLoaded) {
          final allItems = state.categories;
          final kpiItems = state.kpiCategories;

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
                _buildKpiMetrics(kpiItems),
                const SizedBox(height: 24),
                _buildTableCard(
                  context,
                  filteredItems,
                  state.isListEnd,
                  isRefreshing: state.isRefreshing,
                ),
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
                      'Danh mục',
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
                            style: const TextStyle(fontSize: 13),
                            decoration: InputDecoration(
                              hintText: 'Tìm nhanh... (Ctrl+K)',
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
                        tooltip: 'Tải lại danh sách',
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AdminPageHeader(
          icon: Icons.category_rounded,
          title: 'Quản lý Danh mục',
          subtitle:
              'Quản lý các nhóm danh mục sản phẩm trong thực đơn và điểm bán.',
          addButtonText: 'Thêm Danh mục',
          onAddPressed: _showAddCategory,
        ),
        const SizedBox(height: 18),
        _buildFilterToolbar(context),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // KPI METRICS
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildKpiMetrics(List<CategoryEntity> catList) {
    final total = catList.length;
    final active = catList.where((c) => c.isActive).length;
    final locked = total - active;
    final totalProducts = catList.fold<int>(
      0,
      (sum, item) => sum + item.productCount,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 1050
            ? 4
            : (constraints.maxWidth > 550 ? 2 : 1);
        final gap = 16.0;
        final cardWidth =
            (constraints.maxWidth - ((crossAxisCount - 1) * gap)) /
            crossAxisCount;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            AdminKpiCard(
              title: 'TỔNG DANH MỤC',
              value: total.toString(),
              subtitle: 'Tất cả nhóm sản phẩm',
              icon: Icons.category_rounded,
              iconColor: ColorPalette.primaryContainer,
              iconBg: ColorPalette.primaryFixed.withValues(alpha: 0.6),
              width: cardWidth,
            ),
            AdminKpiCard(
              title: 'TỔNG SẢN PHẨM',
              value: totalProducts.toString(),
              subtitle: 'Trong tất cả danh mục',
              icon: Icons.fastfood_rounded,
              iconColor: ColorPalette.adminPurple,
              iconBg: ColorPalette.adminPurple.withValues(alpha: 0.1),
              width: cardWidth,
            ),
            AdminKpiCard(
              title: 'ĐANG KINH DOANH',
              value: active.toString(),
              subtitle:
                  '${((active / (total == 0 ? 1 : total)) * 100).round()}% tổng danh mục',
              icon: Icons.storefront_rounded,
              iconColor: ColorPalette.tertiary,
              iconBg: ColorPalette.tertiary.withValues(alpha: 0.1),
              width: cardWidth,
              showTrendIcon: true,
              trendPositive: true,
            ),
            AdminKpiCard(
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

  // ═══════════════════════════════════════════════════════════════════════════
  // FILTER TOOLBAR (Sử dụng AdminFilterBar & AdminDropdownFilter dùng chung)
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildFilterToolbar(BuildContext context) {
    return AdminFilterBar(
      searchController: _searchController,
      searchHint: 'Tìm theo tên danh mục, mô tả...',
      onSearchChanged: (val) => setState(() => _searchQuery = val.trim()),
      onClearSearch: () => setState(() => _searchQuery = ''),
      filters: [
        AdminDropdownFilter<bool?>(
          value: _selectedStatus,
          items: const [
            DropdownMenuItem(value: null, child: Text('Tất cả trạng thái')),
            DropdownMenuItem(value: true, child: Text('Hoạt động')),
            DropdownMenuItem(value: false, child: Text('Ngừng hoạt động')),
          ],
          onChanged: _onStatusFilterChanged,
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // DATA TABLE / CARD
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildTableCard(
    BuildContext context,
    List<CategoryEntity> items,
    bool isListEnd, {
    bool isRefreshing = false,
  }) {
    if (items.isEmpty && !isRefreshing) {
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
              Icon(
                Icons.category_outlined,
                size: 60,
                color: ColorPalette.textMuted.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 16),
              const Text(
                'Chưa có danh mục nào phù hợp',
                style: TextStyle(color: ColorPalette.textMuted, fontSize: 16),
              ),
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
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (isRefreshing)
            const LinearProgressIndicator(
              minHeight: 2,
              color: ColorPalette.appetizingOrange,
              backgroundColor: Colors.transparent,
            ),
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
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 3,
                          ),
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
                      style: AppTypography.inter(
                        fontSize: 12,
                        color: ColorPalette.textMuted,
                      ),
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
                          final index =
                              e.key + 1 + ((_currentPage - 1) * _pageSize);
                          return _buildProportionalTableRow(
                            context,
                            e.value,
                            index,
                          );
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
          _buildPagination(isListEnd, items.length),
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
        border: const Border(
          bottom: BorderSide(color: ColorPalette.borderSubtle),
        ),
      ),
      child: const Row(
        children: [
          SizedBox(
            width: 44,
            child: Text('#', style: AppTypography.tableHeader),
          ),
          SizedBox(width: 12),
          Expanded(
            flex: 3,
            child: Text('TÊN DANH MỤC', style: AppTypography.tableHeader),
          ),
          Expanded(
            flex: 4,
            child: Text('MÔ TẢ', style: AppTypography.tableHeader),
          ),
          Expanded(
            flex: 2,
            child: Text('SẢN PHẨM', style: AppTypography.tableHeader),
          ),
          Expanded(
            flex: 2,
            child: Text('TRẠNG THÁI', style: AppTypography.tableHeader),
          ),
          SizedBox(
            width: 90,
            child: Text(
              'THAO TÁC',
              textAlign: TextAlign.right,
              style: AppTypography.tableHeader,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProportionalTableRow(
    BuildContext context,
    CategoryEntity cat,
    int index,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _showEditCategory(
          cat.id,
          cat.categoryName,
          cat.description,
          cat.isActive,
        ),
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
                  style: const TextStyle(
                    fontSize: 12,
                    color: ColorPalette.textMuted,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Expanded(
                flex: 2,
                child: Row(
                  children: [
                    const Icon(
                      Icons.fastfood_rounded,
                      size: 14,
                      color: ColorPalette.textMuted,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${cat.productCount} món',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: ColorPalette.textPrimary,
                      ),
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
                        activeTrackColor: ColorPalette.success.withValues(
                          alpha: 0.3,
                        ),
                        activeThumbColor: ColorPalette.success,
                        inactiveTrackColor: ColorPalette.error.withValues(
                          alpha: 0.15,
                        ),
                        inactiveThumbColor: ColorPalette.error.withValues(
                          alpha: 0.6,
                        ),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        onChanged: (val) => _toggleCategoryStatus(cat),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
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
                            color: cat.isActive
                                ? ColorPalette.success
                                : ColorPalette.error,
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
                          backgroundColor: ColorPalette.appetizingOrange
                              .withValues(alpha: 0.08),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          minimumSize: const Size(34, 34),
                        ),
                        onPressed: () => _showEditCategory(
                          cat.id,
                          cat.categoryName,
                          cat.description,
                          cat.isActive,
                        ),
                      ),
                      const SizedBox(width: 6),
                      IconButton(
                        icon: const Icon(
                          Icons.delete_outline_rounded,
                          size: 18,
                        ),
                        color: ColorPalette.dangerCrimson,
                        tooltip: 'Xóa',
                        style: IconButton.styleFrom(
                          backgroundColor: ColorPalette.dangerCrimson
                              .withValues(alpha: 0.08),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          minimumSize: const Size(34, 34),
                        ),
                        onPressed: () =>
                            _showDeleteConfirm(cat.id, cat.categoryName),
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
            color: isSelected
                ? ColorPalette.appetizingOrange
                : ColorPalette.textMuted,
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
              (constraints.maxWidth - ((crossAxisCount - 1) * gap)) /
              crossAxisCount;

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

  Widget _buildCategoryCard(
    BuildContext context,
    CategoryEntity cat,
    int index,
  ) {
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
                      style: AppTypography.dashboardSubtitle.copyWith(
                        fontSize: 12,
                      ),
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
                    constraints: const BoxConstraints(
                      minWidth: 30,
                      minHeight: 30,
                    ),
                    color: ColorPalette.appetizingOrange,
                    onPressed: () => _showEditCategory(
                      cat.id,
                      cat.categoryName,
                      cat.description,
                      cat.isActive,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded, size: 16),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 30,
                      minHeight: 30,
                    ),
                    color: ColorPalette.dangerCrimson,
                    onPressed: () =>
                        _showDeleteConfirm(cat.id, cat.categoryName),
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
                    activeTrackColor: ColorPalette.success.withValues(
                      alpha: 0.3,
                    ),
                    activeThumbColor: ColorPalette.success,
                    inactiveTrackColor: ColorPalette.error.withValues(
                      alpha: 0.15,
                    ),
                    inactiveThumbColor: ColorPalette.error.withValues(
                      alpha: 0.6,
                    ),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    onChanged: (val) => _toggleCategoryStatus(cat),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    cat.isActive ? 'Hoạt động' : 'Đã ẩn',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: cat.isActive
                          ? ColorPalette.success
                          : ColorPalette.error,
                    ),
                  ),
                ],
              ),
              if (cat.createdAt != null)
                Text(
                  'Tạo lúc: ${DateFormat('dd/MM/yyyy').format(cat.createdAt!)}',
                  style: const TextStyle(
                    fontSize: 10,
                    color: ColorPalette.textMuted,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPagination(bool isListEnd, int count) {
    final totalPages = isListEnd ? _currentPage : _currentPage + 1;
    return AppPaginationBar(
      currentPage: _currentPage,
      totalPages: totalPages,
      totalCount: count,
      itemLabel: 'danh mục',
      pageSize: _pageSize,
      onPageChanged: (page) {
        setState(() => _currentPage = page);
        _loadData();
      },
    );
  }
}
