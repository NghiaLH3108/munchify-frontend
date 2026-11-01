import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/ColorPalette.dart';
import '../../../../core/widgets/admin/admin_widgets.dart';
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError
                  ? Icons.error_outline_rounded
                  : Icons.check_circle_rounded,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: 10),
            Expanded(
                child: Text(message, style: const TextStyle(fontSize: 13))),
          ],
        ),
        backgroundColor: isError ? ColorPalette.error : ColorPalette.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final body = BlocConsumer<ComboBloc, ComboState>(
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
        if (state is ComboLoading || state is ComboInitial) {
          return const Center(
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: ColorPalette.appetizingOrange,
            ),
          );
        }
        if (state is ComboError) {
          return _buildError(state.message);
        }
        if (state is ComboLoaded) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildTitleBar(),
                const SizedBox(height: 20),
                _buildToolbar(),
                const SizedBox(height: 20),
                _buildKpiMetrics(state),
                const SizedBox(height: 16),
                _buildTableCard(state),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );

    return Scaffold(
      backgroundColor: ColorPalette.webBgAdmin,
      body: widget.embedInShell ? body : SafeArea(child: body),
    );
  }

  Widget _buildKpiMetrics(ComboLoaded state) {
    final combos = state.combos;
    final total = state.totalCount > 0 ? state.totalCount : combos.length;
    final active = combos.where((c) => c.isActive).length;
    final inactive = combos.where((c) => !c.isActive).length;

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
            AdminKpiCard(
              title: 'TỔNG COMBO',
              value: total.toString(),
              subtitle: 'Gói combo ưu đãi',
              icon: Icons.fastfood_rounded,
              iconColor: ColorPalette.primaryContainer,
              iconBg: ColorPalette.primaryFixed.withValues(alpha: 0.6),
              width: cardWidth,
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
              width: cardWidth,
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
              width: cardWidth,
              isWarning: inactive > 0,
            ),
          ],
        );
      },
    );
  }

  Widget _buildError(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: ColorPalette.error),
          const SizedBox(height: 16),
          Text('Đã xảy ra lỗi: $message',
              style: const TextStyle(color: ColorPalette.error)),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: _loadData, child: const Text('Thử lại')),
        ],
      ),
    );
  }

  Widget _buildTitleBar() {
    return AdminPageHeader(
      icon: Icons.fastfood_rounded,
      title: 'Quản lý Combo',
      subtitle: 'Tạo và quản lý combo gồm nhiều sản phẩm đơn với giá ưu đãi',
      addButtonText: 'Thêm combo',
      onAddPressed: _openingForm ? null : _showCreate,
    );
  }

  Widget _buildToolbar() {
    return AdminFilterBar(
      searchController: _searchController,
      searchHint: 'Tìm theo tên hoặc mã combo...',
      onSearchChanged: _onSearchChanged,
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

  Widget _buildTableCard(ComboLoaded state) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: ColorPalette.borderSubtle),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          if (state.isRefreshing)
            const LinearProgressIndicator(
              minHeight: 2,
              color: ColorPalette.appetizingOrange,
              backgroundColor: Colors.transparent,
            ),
          LayoutBuilder(
            builder: (context, constraints) {
              const minWidth = 980.0;
              final width =
                  constraints.maxWidth < minWidth ? minWidth : constraints.maxWidth;
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: width,
                  child: Column(
                    children: [
                      _buildHeaderRow(),
                      if (state.combos.isEmpty)
                        _buildEmpty()
                      else
                        ...state.combos.map(_buildRow),
                    ],
                  ),
                ),
              );
            },
          ),
          _buildPagination(state),
        ],
      ),
    );
  }

  Widget _buildHeaderRow() {
    TextStyle style = const TextStyle(
      fontFamily: 'Inter',
      fontSize: 11,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.6,
      color: ColorPalette.textMuted,
    );
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: const BoxDecoration(
        color: Color(0xFFF8FAFC),
        borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
        border: Border(bottom: BorderSide(color: ColorPalette.borderSubtle)),
      ),
      child: Row(
        children: [
          Expanded(flex: 4, child: Text('COMBO', style: style)),
          Expanded(flex: 5, child: Text('SẢN PHẨM THÀNH PHẦN', style: style)),
          Expanded(flex: 2, child: Text('GIÁ BÁN', style: style)),
          Expanded(flex: 2, child: Text('TIẾT KIỆM', style: style)),
          Expanded(flex: 2, child: Text('TRẠNG THÁI', style: style)),
          SizedBox(width: 96, child: Text('THAO TÁC', style: style)),
        ],
      ),
    );
  }

  Widget _buildRow(ComboEntity combo) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: ColorPalette.borderSubtle)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(flex: 4, child: _buildNameCell(combo)),
          Expanded(flex: 5, child: _buildItemsCell(combo)),
          Expanded(
            flex: 2,
            child: Column(
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
                Text(
                  'Lẻ: ${_vnd.format(combo.retailTotal)}',
                  style: const TextStyle(
                      fontSize: 11, color: ColorPalette.textMuted),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
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
          Expanded(flex: 2, child: _buildStatusBadge(combo)),
          SizedBox(
            width: 96,
            child: Row(
              children: [
                IconButton(
                  tooltip: 'Chỉnh sửa',
                  constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                  icon: const Icon(Icons.edit_outlined,
                      size: 20, color: ColorPalette.info),
                  onPressed: _openingForm ? null : () => _showEdit(combo),
                ),
                IconButton(
                  tooltip: 'Xóa',
                  constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                  icon: const Icon(Icons.delete_outline_rounded,
                      size: 20, color: ColorPalette.dangerCrimson),
                  onPressed: () => _confirmDelete(combo),
                ),
              ],
            ),
          ),
        ],
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
                    errorBuilder: (_, __, ___) => const Icon(
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                combo.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
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
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: combo.items.map((i) {
        final isOutOfStock = i.componentStockQuantity < i.quantity;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: isOutOfStock
                ? ColorPalette.dangerCrimson.withValues(alpha: 0.1)
                : ColorPalette.surfaceVariant,
            borderRadius: BorderRadius.circular(8),
            border: isOutOfStock
                ? Border.all(color: ColorPalette.dangerCrimson.withValues(alpha: 0.3))
                : null,
          ),
          child: Text(
            '${i.quantity} × ${i.componentProductName}${isOutOfStock ? ' (Hết)' : ''}',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isOutOfStock ? ColorPalette.dangerCrimson : const Color(0xFF334155),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStatusBadge(ComboEntity combo) {
    final active = combo.isActive;
    final isOutOfStock = combo.isOutOfStock;

    final color = active ? ColorPalette.success : ColorPalette.textMuted;
    return Align(
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
                  decoration: BoxDecoration(color: color, shape: BoxShape.circle),
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
                Icon(Icons.warning_amber_rounded, size: 12, color: ColorPalette.dangerCrimson),
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
    );
  }

  Widget _buildEmpty() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 56),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: ColorPalette.primaryFixed.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.fastfood_outlined,
                size: 32, color: ColorPalette.primaryContainer),
          ),
          const SizedBox(height: 12),
          const Text('Chưa có combo nào',
              style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          const Text('Nhấn "Thêm combo" để tạo combo đầu tiên',
              style: TextStyle(fontSize: 12, color: ColorPalette.textMuted)),
        ],
      ),
    );
  }

  Widget _buildPagination(ComboLoaded state) {
    final totalPages = state.totalPages == 0 ? 1 : state.totalPages;
    final from = state.totalCount == 0
        ? 0
        : (state.page - 1) * state.pageSize + 1;
    final to = (from + state.combos.length - 1).clamp(0, state.totalCount);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Hiển thị $from–$to / ${state.totalCount} combo',
              style: const TextStyle(
                  fontSize: 12, color: ColorPalette.textMuted),
            ),
          ),
          IconButton(
            tooltip: 'Trang trước',
            constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
            onPressed:
                state.page > 1 ? () => _goToPage(state.page - 1) : null,
            icon: const Icon(Icons.chevron_left_rounded),
          ),
          Text('Trang ${state.page} / $totalPages',
              style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  fontWeight: FontWeight.w600)),
          IconButton(
            tooltip: 'Trang sau',
            constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
            onPressed: state.page < totalPages
                ? () => _goToPage(state.page + 1)
                : null,
            icon: const Icon(Icons.chevron_right_rounded),
          ),
        ],
      ),
    );
  }
}
