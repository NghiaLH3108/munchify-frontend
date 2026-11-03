import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/ColorPalette.dart';
import '../../../../core/widgets/admin/admin_widgets.dart';
import '../../../../core/widgets/app_pagination_bar.dart';
import '../../../../injection_container.dart';
import '../../domain/entities/combo_entity.dart';
import '../../domain/entities/combo_form_options_entity.dart';
import '../../domain/entities/combo_input.dart';
import '../bloc/combo_bloc.dart';
import '../bloc/combo_event.dart';
import '../bloc/combo_form_options_cubit.dart';
import '../bloc/combo_state.dart';
import '../widgets/combo_delete_confirm_dialog.dart';
import '../widgets/combo_form_dialog.dart';
import '../../../../core/widgets/app_toast.dart';

class ManageCombosScreen extends StatefulWidget {
  final bool embedInShell;

  const ManageCombosScreen({super.key, this.embedInShell = false});

  @override
  State<ManageCombosScreen> createState() => _ManageCombosScreenState();
}

class _ManageCombosScreenState extends State<ManageCombosScreen> {
  static const int _pageSize = 10;
  static final NumberFormat _vnd =
      NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0);

  final TextEditingController _searchController = TextEditingController();
  late final ComboFormOptionsCubit _optionsCubit;
  Timer? _debounce;

  bool? _selectedStatus;
  String _searchQuery = '';
  int _currentPage = 1;
  bool _openingForm = false;

  @override
  void initState() {
    super.initState();
    _optionsCubit = sl<ComboFormOptionsCubit>();
    _loadData();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _optionsCubit.close();
    super.dispose();
  }

  void _loadData() {
    context.read<ComboBloc>().add(LoadCombosEvent(
          searchTerm: _searchQuery,
          isActive: _selectedStatus,
          page: _currentPage,
          pageSize: _pageSize,
        ));
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      setState(() {
        _searchQuery = value.trim();
        _currentPage = 1;
      });
      _loadData();
    });
  }

  void _onStatusChanged(bool? status) {
    setState(() {
      _selectedStatus = status;
      _currentPage = 1;
    });
    _loadData();
  }

  void _goToPage(int page) {
    setState(() => _currentPage = page);
    _loadData();
  }

  Future<ComboFormOptionsEntity?> _loadOptions() async {
    await _optionsCubit.load();
    final s = _optionsCubit.state;
    if (s is ComboFormOptionsLoaded) return s.options;
    if (!mounted) return null;
    final message = s is ComboFormOptionsError
        ? s.message
        : 'Không thể tải dữ liệu biểu mẫu combo';
    _showSnack(message, isError: true);
    return null;
  }

  Future<void> _showCreate() async {
    if (_openingForm) return;
    setState(() => _openingForm = true);
    final options = await _loadOptions();
    if (!mounted) return;
    setState(() => _openingForm = false);
    if (options == null) return;

    await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => ComboFormDialog(
        options: options,
        onSubmit: (input) => _submitCreate(input),
      ),
    );
  }

  Future<void> _showEdit(ComboEntity combo) async {
    if (_openingForm) return;
    setState(() => _openingForm = true);
    final options = await _loadOptions();
    if (!mounted) return;
    setState(() => _openingForm = false);
    if (options == null) return;

    await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => ComboFormDialog(
        combo: combo,
        options: options,
        onSubmit: (input) => _submitUpdate(combo.id, input),
      ),
    );
  }

  Future<String?> _submitCreate(ComboInput input) {
    final completer = Completer<String?>();
    context
        .read<ComboBloc>()
        .add(CreateComboEvent(input: input, completer: completer));
    return completer.future;
  }

  Future<String?> _submitUpdate(int id, ComboInput input) {
    final completer = Completer<String?>();
    context
        .read<ComboBloc>()
        .add(UpdateComboEvent(id: id, input: input, completer: completer));
    return completer.future;
  }

  Future<void> _confirmDelete(ComboEntity combo) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => ComboDeleteConfirmDialog(comboName: combo.name),
    );
    if (confirmed == true && mounted) {
      context.read<ComboBloc>().add(DeleteComboEvent(combo.id));
    }
  }

  void _showSnack(String message, {bool isError = false}) {
    if (isError) {
      AppToast.error(message, context: context);
    } else {
      AppToast.success(message, context: context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ComboBloc, ComboState>(
      listener: (context, state) {
        if (state is ComboLoaded) {
          if (state.successMessage != null) {
            _showSnack(state.successMessage!);
          } else if (state.errorMessage != null) {
            _showSnack(state.errorMessage!, isError: true);
          }
          if (state.page != _currentPage) {
            setState(() => _currentPage = state.page);
          }
        }
      },
      builder: (context, state) {
        Widget? stateView;
        List<Widget> kpis = const [];
        Widget? table;

        if (state is ComboLoading || state is ComboInitial) {
          stateView = const AdminLoadingView(
            message: 'Đang đồng bộ danh sách combo...',
          );
        } else if (state is ComboError) {
          stateView = AdminErrorView(message: state.message, onRetry: _loadData);
        } else if (state is ComboLoaded) {
          kpis = _buildKpiCards(state);
          table = _buildTable(state);
        } else {
          stateView = const SizedBox.shrink();
        }

        return AdminListScaffold(
          embedInShell: widget.embedInShell,
          stickyHeader: AdminStickyHeader(
            breadcrumb: 'Combo',
            onRefresh: _loadData,
            onQuickSearch: _onSearchChanged,
          ),
          header: AdminPageHeader(
            icon: Icons.fastfood_rounded,
            title: 'Quản lý Combo',
            subtitle:
                'Tạo và quản lý combo gồm nhiều sản phẩm đơn với giá ưu đãi',
            addButtonText: 'Thêm combo',
            onAddPressed: _openingForm ? null : _showCreate,
          ),
          filterBar: _buildToolbar(),
          kpiCards: kpis,
          table: table,
          stateView: stateView,
        );
      },
    );
  }

  List<Widget> _buildKpiCards(ComboLoaded state) {
    final combos = state.combos;
    final total = state.totalCount > 0 ? state.totalCount : combos.length;
    final active = combos.where((c) => c.isActive).length;
    final inactive = combos.where((c) => !c.isActive).length;

    return [
      AdminKpiCard(
        title: 'TỔNG COMBO',
        value: total.toString(),
        subtitle: 'Gói combo ưu đãi',
        icon: Icons.fastfood_rounded,
        iconColor: ColorPalette.primaryContainer,
        iconBg: ColorPalette.primaryFixed.withValues(alpha: 0.6),
      ),
      AdminKpiCard(
        title: 'ĐANG BÁN',
        value: active.toString(),
        subtitle: total > 0
            ? 'Chiếm ${((active / (total == 0 ? 1 : total)) * 100).round()}% danh bạ'
            : 'Đang phục vụ khách',
        icon: Icons.check_circle_outline_rounded,
        iconColor: ColorPalette.tertiary,
        iconBg: ColorPalette.tertiary.withValues(alpha: 0.1),
        showTrendIcon: true,
        trendPositive: true,
      ),
      AdminKpiCard(
        title: 'NGỪNG BÁN',
        value: inactive.toString(),
        subtitle: 'Tạm ngưng phục vụ',
        icon: Icons.pause_circle_outline_rounded,
        iconColor: ColorPalette.textMuted,
        iconBg: const Color(0xFFF1F5F9),
        isWarning: inactive > 0,
      ),
    ];
  }

  Widget _buildToolbar() {
    return AdminFilterBar(
      searchController: _searchController,
      searchHint: 'Tìm theo tên hoặc mã combo...',
      onSearchChanged: _onSearchChanged,
      onClearSearch: () {
        _debounce?.cancel();
        setState(() {
          _searchQuery = '';
          _currentPage = 1;
        });
        _loadData();
      },
      filters: [
        AdminDropdownFilter<bool?>(
          value: _selectedStatus,
          items: const [
            DropdownMenuItem(value: null, child: Text('Tất cả trạng thái')),
            DropdownMenuItem(value: true, child: Text('Đang bán')),
            DropdownMenuItem(value: false, child: Text('Ngừng bán')),
          ],
          onChanged: _onStatusChanged,
        ),
      ],
    );
  }

  Widget _buildTable(ComboLoaded state) {
    final totalPages = state.totalPages == 0 ? 1 : state.totalPages;
    return AdminDataTable<ComboEntity>(
      title: 'Danh sách combo',
      countLabel: '${state.totalCount} combo',
      subtitle: 'Hiển thị trang ${state.page} / $totalPages.',
      items: state.combos,
      indexOffset: (state.page - 1) * state.pageSize,
      minTableWidth: 980,
      rowHeight: 72,
      isRefreshing: state.isRefreshing,
      onRowTap: _openingForm ? null : _showEdit,
      emptyState: const AdminEmptyState(
        icon: Icons.fastfood_outlined,
        title: 'Chưa có combo nào',
        subtitle: 'Nhấn "Thêm combo" để tạo combo đầu tiên',
      ),
      columns: [
        AdminTableColumn.index<ComboEntity>(),
        AdminTableColumn(
          label: 'COMBO',
          flex: 3,
          cellBuilder: (_, combo, _) => _buildNameCell(combo),
        ),
        AdminTableColumn(
          label: 'SẢN PHẨM THÀNH PHẦN',
          flex: 5,
          cellBuilder: (_, combo, _) => _buildItemsCell(combo),
        ),
        AdminTableColumn(
          label: 'GIÁ BÁN',
          flex: 2,
          cellBuilder: (_, combo, _) => Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _vnd.format(combo.price),
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: ColorPalette.appetizingOrange,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Lẻ: ${_vnd.format(combo.retailTotal)}',
                style: const TextStyle(
                    fontSize: 11, color: ColorPalette.textMuted),
              ),
            ],
          ),
        ),
        AdminTableColumn(
          label: 'TIẾT KIỆM',
          flex: 2,
          cellBuilder: (_, combo, _) => Text(
            combo.savingAmount > 0 ? _vnd.format(combo.savingAmount) : '—',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: combo.savingAmount > 0
                  ? ColorPalette.success
                  : ColorPalette.textMuted,
            ),
          ),
        ),
        AdminTableColumn(
          label: 'TRẠNG THÁI',
          flex: 3,
          cellBuilder: (_, combo, _) => _buildStatusBadge(combo),
        ),
        AdminTableColumn(
          label: 'THAO TÁC',
          width: 84,
          align: TextAlign.right,
          cellBuilder: (_, combo, _) => Align(
            alignment: Alignment.centerRight,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AdminRowActionButton(
                  icon: Icons.edit_outlined,
                  color: ColorPalette.appetizingOrange,
                  tooltip: 'Chỉnh sửa',
                  onPressed: _openingForm ? null : () => _showEdit(combo),
                ),
                const SizedBox(width: 6),
                AdminRowActionButton(
                  icon: Icons.delete_outline_rounded,
                  color: ColorPalette.dangerCrimson,
                  tooltip: 'Xóa',
                  onPressed: () => _confirmDelete(combo),
                ),
              ],
            ),
          ),
        ),
      ],
      pagination: AppPaginationBar(
        currentPage: state.page,
        totalPages: totalPages,
        totalCount: state.totalCount,
        itemLabel: 'combo',
        pageSize: state.pageSize,
        onPageChanged: _goToPage,
      ),
    );
  }

  Widget _buildNameCell(ComboEntity combo) {
    final hasImage = combo.imageUrl != null && combo.imageUrl!.isNotEmpty;
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Container(
            width: 44,
            height: 44,
            color: ColorPalette.amberTint,
            child: hasImage
                ? Image.network(
                    combo.imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => const Icon(
                        Icons.fastfood_rounded,
                        color: ColorPalette.appetizingOrange),
                  )
                : const Icon(Icons.fastfood_rounded,
                    color: ColorPalette.appetizingOrange),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                combo.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E293B),
                ),
              ),
              Text(
                '${combo.code} · ${combo.categoryName}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontSize: 11, color: ColorPalette.textMuted),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildItemsCell(ComboEntity combo) {
    if (combo.items.isEmpty) {
      return const Text('—',
          style: TextStyle(color: ColorPalette.textMuted));
    }
    final allNames = combo.items
        .map((i) => '${i.quantity} × ${i.componentProductName}')
        .join('\n');
    final visibleItems = combo.items.take(2).toList();
    final remaining = combo.items.length - visibleItems.length;

    return Tooltip(
      message: allNames,
      waitDuration: const Duration(milliseconds: 300),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Wrap(
          spacing: 6,
          runSpacing: 6,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            for (final item in visibleItems) _buildItemChip(item),
            if (remaining > 0)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: ColorPalette.primaryFixed.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '+$remaining món',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: ColorPalette.primaryContainer,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemChip(ComboComponentEntity i) {
    final isOutOfStock = i.componentStockQuantity < i.quantity;
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 185),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isOutOfStock
              ? ColorPalette.dangerCrimson.withValues(alpha: 0.1)
              : ColorPalette.surfaceVariant,
          borderRadius: BorderRadius.circular(8),
          border: isOutOfStock
              ? Border.all(
                  color: ColorPalette.dangerCrimson.withValues(alpha: 0.3))
              : null,
        ),
        child: Text(
          '${i.quantity} × ${i.componentProductName}${isOutOfStock ? ' (Hết)' : ''}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: isOutOfStock
                ? ColorPalette.dangerCrimson
                : const Color(0xFF334155),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(ComboEntity combo) {
    final active = combo.isActive;
    final isOutOfStock = combo.isOutOfStock;

    final color = active ? ColorPalette.success : ColorPalette.textMuted;
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Switch(
            value: combo.isActive,
            activeTrackColor: ColorPalette.success.withValues(alpha: 0.3),
            activeThumbColor: ColorPalette.success,
            inactiveTrackColor: ColorPalette.error.withValues(alpha: 0.15),
            inactiveThumbColor: ColorPalette.error.withValues(alpha: 0.6),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            onChanged: (val) {
              context.read<ComboBloc>().add(
                    ToggleComboStatusEvent(
                      id: combo.id,
                      currentIsActive: combo.isActive,
                    ),
                  );
            },
          ),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration:
                          BoxDecoration(color: color, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      active ? 'Đang bán' : 'Ngừng bán',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ),
              if (active && isOutOfStock) ...[
                const SizedBox(height: 4),
                const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.warning_amber_rounded,
                        size: 12, color: ColorPalette.dangerCrimson),
                    SizedBox(width: 4),
                    Text(
                      'Combo đã hết',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: ColorPalette.dangerCrimson,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
