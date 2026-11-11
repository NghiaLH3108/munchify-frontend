import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/ColorPalette.dart';
import '../../../../core/theme/AppTypography.dart';
import '../../../../core/widgets/admin/admin_widgets.dart';
import '../../../../core/widgets/app_pagination_bar.dart';
import '../../domain/entities/unit_entity.dart';
import '../bloc/unit_bloc.dart';
import '../bloc/unit_event.dart';
import '../bloc/unit_state.dart';
import '../widgets/unit_form_dialog.dart';
import '../widgets/unit_delete_confirm_dialog.dart';
import '../../../../core/widgets/app_toast.dart';

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

  static const _avatarColors = [
    Color(0xFFE65100),
    Color(0xFF1565C0),
    Color(0xFF2E7D32),
    Color(0xFF6A1B9A),
    Color(0xFF00838F),
  ];

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

  Color _colorFor(UnitEntity unit) =>
      _avatarColors[unit.id % _avatarColors.length];

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<UnitBloc, UnitState>(
      listener: (context, state) {
        if (state is UnitLoaded && state.successMessage != null) {
          AppToast.success(state.successMessage!, context: context);
        } else if (state is UnitError) {
          AppToast.error(state.message, context: context);
        }
      },
      buildWhen: (previous, current) =>
          current is UnitLoading ||
          current is UnitLoaded ||
          current is UnitError,
      builder: (context, state) {
        Widget? stateView;
        List<Widget> kpis = const [];
        Widget? table;

        if (state is UnitLoading) {
          stateView = const AdminLoadingView(
            message: 'Đang đồng bộ đơn vị tính...',
          );
        } else if (state is UnitError) {
          stateView = AdminErrorView(message: state.message, onRetry: _loadData);
        } else if (state is UnitLoaded) {
          final filteredItems = state.units.where((u) {
            if (_searchQuery.isEmpty) return true;
            final q = _searchQuery.toLowerCase();
            return u.unitName.toLowerCase().contains(q) ||
                (u.description?.toLowerCase().contains(q) ?? false);
          }).toList();

          kpis = _buildKpiCards(state.kpiUnits);
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
            breadcrumb: 'Đơn vị tính',
            onRefresh: _loadData,
            onQuickSearch: (val) => setState(() => _searchQuery = val),
          ),
          header: AdminPageHeader(
            icon: Icons.straighten_rounded,
            title: 'Quản lý Đơn vị tính',
            subtitle:
                'Quản lý các đơn vị tính cho sản phẩm (Bịch, Gói, Lon, Chai, Ly...).',
            addButtonText: 'Thêm Đơn vị',
            onAddPressed: _showAddUnit,
          ),
          filterBar: _buildFilterToolbar(),
          kpiCards: kpis,
          table: table,
          stateView: stateView,
        );
      },
    );
  }

  Widget _buildFilterToolbar() {
    return AdminFilterBar(
      searchController: _searchController,
      searchHint: 'Tìm theo tên đơn vị, mô tả...',
      onSearchChanged: (val) => setState(() => _searchQuery = val.trim()),
      onClearSearch: () => setState(() => _searchQuery = ''),
      filters: [
        AdminDropdownFilter<bool?>(
          value: _selectedStatus,
          items: const [
            DropdownMenuItem(value: null, child: Text('Tất cả trạng thái')),
            DropdownMenuItem(value: true, child: Text('Hoạt động')),
            DropdownMenuItem(value: false, child: Text('Tạm ngưng')),
          ],
          onChanged: _onStatusFilterChanged,
        ),
      ],
    );
  }

  List<Widget> _buildKpiCards(List<UnitEntity> unitList) {
    final total = unitList.length;
    final active = unitList.where((u) => u.isActive).length;
    final inactive = total - active;

    return [
      AdminKpiCard(
        title: 'TỔNG ĐƠN VỊ TÍNH',
        value: total.toString(),
        subtitle: 'Tất cả đơn vị đo lường',
        icon: Icons.straighten_rounded,
        iconColor: ColorPalette.primaryContainer,
        iconBg: ColorPalette.primaryFixed.withValues(alpha: 0.6),
      ),
      AdminKpiCard(
        title: 'ĐANG SỬ DỤNG',
        value: active.toString(),
        subtitle:
            '${((active / (total == 0 ? 1 : total)) * 100).round()}% tổng đơn vị',
        icon: Icons.check_circle_outline_rounded,
        iconColor: ColorPalette.tertiary,
        iconBg: ColorPalette.tertiary.withValues(alpha: 0.1),
        showTrendIcon: true,
        trendPositive: true,
      ),
      AdminKpiCard(
        title: 'TẠM NGƯNG',
        value: inactive.toString(),
        subtitle: 'Không sử dụng trong POS',
        icon: Icons.block_rounded,
        iconColor: ColorPalette.dangerCrimson,
        iconBg: ColorPalette.dangerCrimson.withValues(alpha: 0.08),
        isWarning: inactive > 0,
      ),
    ];
  }

  Widget _buildTable(
    List<UnitEntity> items,
    bool isListEnd,
    bool isRefreshing,
  ) {
    return AdminDataTable<UnitEntity>(
      title: 'Danh sách đơn vị tính',
      countLabel: '${items.length} mục',
      subtitle: 'Hiển thị trang $_currentPage.',
      items: items,
      indexOffset: (_currentPage - 1) * _pageSize,
      minTableWidth: 800,
      isRefreshing: isRefreshing,
      onRowTap: _showEditUnit,
      isCardView: _isCardView,
      onToggleView: (v) => setState(() => _isCardView = v),
      cardBuilder: (context, unit, _) => _buildUnitCard(unit),
      emptyState: AdminEmptyState(
        icon: Icons.straighten_rounded,
        title: 'Không tìm thấy đơn vị tính',
        subtitle: 'Thử thay đổi bộ lọc hoặc thêm đơn vị mới.',
        action: ElevatedButton.icon(
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
      ),
      columns: [
        AdminTableColumn.index<UnitEntity>(),
        AdminTableColumn(
          label: 'ĐƠN VỊ TÍNH',
          flex: 3,
          cellBuilder: (_, unit, _) {
            final avatarColor = _colorFor(unit);
            return Row(
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
                    _getInitials(unit.unitName),
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
            );
          },
        ),
        AdminTableColumn(
          label: 'MÔ TẢ',
          flex: 5,
          cellBuilder: (_, unit, _) {
            final hasDesc = unit.description?.isNotEmpty == true;
            return Text(
              hasDesc ? unit.description! : '—',
              style: AppTypography.inter(
                fontSize: 13,
                color:
                    hasDesc ? ColorPalette.textSecondary : ColorPalette.textMuted,
                fontStyle: hasDesc ? FontStyle.normal : FontStyle.italic,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            );
          },
        ),
        AdminTableColumn(
          label: 'TRẠNG THÁI',
          flex: 3,
          cellBuilder: (_, unit, _) => FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Switch(
                  value: unit.isActive,
                  activeTrackColor: ColorPalette.success.withValues(alpha: 0.3),
                  activeThumbColor: ColorPalette.success,
                  inactiveTrackColor:
                      ColorPalette.error.withValues(alpha: 0.15),
                  inactiveThumbColor: ColorPalette.error.withValues(alpha: 0.6),
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
                        : ColorPalette.dangerCrimson.withValues(alpha: 0.08),
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
        ),
        AdminTableColumn(
          label: 'THAO TÁC',
          width: 90,
          align: TextAlign.right,
          cellBuilder: (_, unit, _) => Align(
            alignment: Alignment.centerRight,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AdminRowActionButton(
                  icon: Icons.edit_outlined,
                  color: ColorPalette.appetizingOrange,
                  tooltip: 'Chỉnh sửa',
                  onPressed: () => _showEditUnit(unit),
                ),
                const SizedBox(width: 6),
                AdminRowActionButton(
                  icon: Icons.delete_outline_rounded,
                  color: ColorPalette.dangerCrimson,
                  tooltip: 'Xóa',
                  onPressed: () => _showDeleteConfirm(unit),
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
        itemLabel: 'đơn vị tính',
        pageSize: _pageSize,
        onPageChanged: (page) {
          setState(() => _currentPage = page);
          _loadData();
        },
      ),
    );
  }

  Widget _buildUnitCard(UnitEntity unit) {
    final color = _colorFor(unit);
    final hasDesc = unit.description?.isNotEmpty == true;

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
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Text(
                  _getInitials(unit.unitName),
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      unit.unitName,
                      style: AppTypography.labelLarge.copyWith(fontSize: 14),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'ID #${unit.id}',
                      style:
                          AppTypography.dashboardSubtitle.copyWith(fontSize: 12),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit_outlined, size: 16),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
                color: ColorPalette.appetizingOrange,
                onPressed: () => _showEditUnit(unit),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded, size: 16),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
                color: ColorPalette.dangerCrimson,
                onPressed: () => _showDeleteConfirm(unit),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: ColorPalette.borderSubtle),
          const SizedBox(height: 12),
          Text(
            hasDesc ? unit.description! : 'Không có mô tả',
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
            children: [
              Switch(
                value: unit.isActive,
                activeTrackColor: ColorPalette.success.withValues(alpha: 0.3),
                activeThumbColor: ColorPalette.success,
                inactiveTrackColor: ColorPalette.error.withValues(alpha: 0.15),
                inactiveThumbColor: ColorPalette.error.withValues(alpha: 0.6),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                onChanged: (_) => _toggleUnitStatus(unit),
              ),
              const SizedBox(width: 6),
              Text(
                unit.isActive ? 'Hoạt động' : 'Tạm ngưng',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color:
                      unit.isActive ? ColorPalette.success : ColorPalette.error,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
