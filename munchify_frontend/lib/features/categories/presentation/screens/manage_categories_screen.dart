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

  void _editCat(CategoryEntity cat) => _showEditCategory(
        cat.id,
        cat.categoryName,
        cat.description,
        cat.isActive,
      );

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
    return BlocConsumer<CategoryBloc, CategoryState>(
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
        Widget? stateView;
        List<Widget> kpis = const [];
        Widget? table;

        if (state is CategoryLoading && state is! CategoryLoaded) {
          stateView = const AdminLoadingView(message: 'Đang đồng bộ danh mục...');
        } else if (state is CategoryError) {
          stateView = AdminErrorView(message: state.message, onRetry: _loadData);
        } else if (state is CategoryLoaded) {
          final filteredItems = state.categories.where((cat) {
            if (_searchQuery.isEmpty) return true;
            final q = _searchQuery.toLowerCase();
            return cat.categoryName.toLowerCase().contains(q) ||
                (cat.description?.toLowerCase().contains(q) ?? false);
          }).toList();

          kpis = _buildKpiCards(state.kpiCategories);
          table = _buildTable(
            filteredItems,
            state.isListEnd,
            state.isRefreshing,
          );
        } else {
          stateView = const SizedBox.shrink();
        }

        return AdminListScaffold(
          embedInShell: widget.embedInShell,
          stickyHeader: AdminStickyHeader(
            breadcrumb: 'Danh mục',
            onRefresh: _loadData,
            onQuickSearch: (v) => setState(() => _searchQuery = v),
          ),
          header: AdminPageHeader(
            icon: Icons.category_rounded,
            title: 'Quản lý Danh mục',
            subtitle:
                'Quản lý các nhóm danh mục sản phẩm trong thực đơn và điểm bán.',
            addButtonText: 'Thêm Danh mục',
            onAddPressed: _showAddCategory,
          ),
          filterBar: _buildFilterToolbar(),
          kpiCards: kpis,
          table: table,
          stateView: stateView,
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // KPI METRICS
  // ═══════════════════════════════════════════════════════════════════════════
  List<Widget> _buildKpiCards(List<CategoryEntity> catList) {
    final total = catList.length;
    final active = catList.where((c) => c.isActive).length;
    final locked = total - active;
    final totalProducts = catList.fold<int>(
      0,
      (sum, item) => sum + item.productCount,
    );

    return [
      AdminKpiCard(
        title: 'TỔNG DANH MỤC',
        value: total.toString(),
        subtitle: 'Tất cả nhóm sản phẩm',
        icon: Icons.category_rounded,
        iconColor: ColorPalette.primaryContainer,
        iconBg: ColorPalette.primaryFixed.withValues(alpha: 0.6),
      ),
      AdminKpiCard(
        title: 'TỔNG SẢN PHẨM',
        value: totalProducts.toString(),
        subtitle: 'Trong tất cả danh mục',
        icon: Icons.fastfood_rounded,
        iconColor: ColorPalette.adminPurple,
        iconBg: ColorPalette.adminPurple.withValues(alpha: 0.1),
      ),
      AdminKpiCard(
        title: 'ĐANG KINH DOANH',
        value: active.toString(),
        subtitle:
            '${((active / (total == 0 ? 1 : total)) * 100).round()}% tổng danh mục',
        icon: Icons.storefront_rounded,
        iconColor: ColorPalette.tertiary,
        iconBg: ColorPalette.tertiary.withValues(alpha: 0.1),
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
        isWarning: locked > 0,
      ),
    ];
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // FILTER TOOLBAR
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildFilterToolbar() {
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
  // DATA TABLE (template dùng chung)
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildTable(
    List<CategoryEntity> items,
    bool isListEnd,
    bool isRefreshing,
  ) {
    return AdminDataTable<CategoryEntity>(
      title: 'Danh sách danh mục',
      countLabel: '${items.length} mục',
      subtitle: 'Hiển thị trang $_currentPage.',
      items: items,
      indexOffset: (_currentPage - 1) * _pageSize,
      isRefreshing: isRefreshing,
      onRowTap: _editCat,
      isCardView: _isCardView,
      onToggleView: (v) => setState(() => _isCardView = v),
      cardBuilder: (context, cat, _) => _buildCategoryCard(cat),
      emptyState: const AdminEmptyState(
        icon: Icons.category_outlined,
        title: 'Chưa có danh mục nào phù hợp',
      ),
      columns: [
        AdminTableColumn.index<CategoryEntity>(),
        AdminTableColumn(
          label: 'TÊN DANH MỤC',
          flex: 3,
          cellBuilder: (_, cat, _) => Row(
            children: [
              _initialsBox(cat.categoryName, 34, 14),
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
        AdminTableColumn(
          label: 'MÔ TẢ',
          flex: 4,
          cellBuilder: (_, cat, _) => Text(
            cat.description ?? '—',
            style: const TextStyle(fontSize: 12, color: ColorPalette.textMuted),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        AdminTableColumn(
          label: 'SẢN PHẨM',
          flex: 2,
          cellBuilder: (_, cat, _) => Row(
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
        AdminTableColumn(
          label: 'TRẠNG THÁI',
          flex: 2,
          cellBuilder: (_, cat, _) => FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _statusSwitch(cat),
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
                  child: _statusText(cat),
                ),
              ],
            ),
          ),
        ),
        AdminTableColumn(
          label: 'THAO TÁC',
          width: 90,
          align: TextAlign.right,
          cellBuilder: (_, cat, _) => Align(
            alignment: Alignment.centerRight,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AdminRowActionButton(
                  icon: Icons.edit_outlined,
                  color: ColorPalette.appetizingOrange,
                  tooltip: 'Chỉnh sửa',
                  onPressed: () => _editCat(cat),
                ),
                const SizedBox(width: 6),
                AdminRowActionButton(
                  icon: Icons.delete_outline_rounded,
                  color: ColorPalette.dangerCrimson,
                  tooltip: 'Xóa',
                  onPressed: () => _showDeleteConfirm(cat.id, cat.categoryName),
                ),
              ],
            ),
          ),
        ),
      ],
      pagination: AppPaginationBar(
        currentPage: _currentPage,
        totalPages: isListEnd ? _currentPage : _currentPage + 1,
        totalCount: items.length,
        itemLabel: 'danh mục',
        pageSize: _pageSize,
        onPageChanged: (page) {
          setState(() => _currentPage = page);
          _loadData();
        },
      ),
    );
  }

  Widget _initialsBox(String name, double size, double fontSize) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: ColorPalette.primaryFixed,
        borderRadius: BorderRadius.circular(8),
      ),
      alignment: Alignment.center,
      child: Text(
        _getInitials(name),
        style: TextStyle(
          color: ColorPalette.primaryContainer,
          fontWeight: FontWeight.bold,
          fontSize: fontSize,
        ),
      ),
    );
  }

  Widget _statusSwitch(CategoryEntity cat) {
    return Switch(
      value: cat.isActive,
      activeTrackColor: ColorPalette.success.withValues(alpha: 0.3),
      activeThumbColor: ColorPalette.success,
      inactiveTrackColor: ColorPalette.error.withValues(alpha: 0.15),
      inactiveThumbColor: ColorPalette.error.withValues(alpha: 0.6),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      onChanged: (_) => _toggleCategoryStatus(cat),
    );
  }

  Widget _statusText(CategoryEntity cat) {
    return Text(
      cat.isActive ? 'Hoạt động' : 'Đã ẩn',
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: cat.isActive ? ColorPalette.success : ColorPalette.error,
      ),
    );
  }

  Widget _buildCategoryCard(CategoryEntity cat) {
    final hasDesc = cat.description != null && cat.description!.isNotEmpty;
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
              _initialsBox(cat.categoryName, 40, 16),
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
              IconButton(
                icon: const Icon(Icons.edit_outlined, size: 16),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
                color: ColorPalette.appetizingOrange,
                onPressed: () => _editCat(cat),
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
          const SizedBox(height: 14),
          const Divider(height: 1, color: ColorPalette.borderSubtle),
          const SizedBox(height: 12),
          Text(
            hasDesc ? cat.description! : 'Không có mô tả',
            style: TextStyle(
              fontSize: 12,
              color: hasDesc ? ColorPalette.textPrimary : ColorPalette.textMuted,
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
                  _statusSwitch(cat),
                  const SizedBox(width: 6),
                  _statusText(cat),
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
}
