import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/ColorPalette.dart';
import '../../../../core/theme/AppTypography.dart';
import '../../data/models/admin_order_filter_params.dart';

class OrderFilterBar extends StatefulWidget {
  final AdminOrderFilterParams currentFilter;
  final ValueChanged<AdminOrderFilterParams> onFilterChanged;
  final VoidCallback onRefresh;

  const OrderFilterBar({
    super.key,
    required this.currentFilter,
    required this.onFilterChanged,
    required this.onRefresh,
  });

  @override
  State<OrderFilterBar> createState() => _OrderFilterBarState();
}

class _OrderFilterBarState extends State<OrderFilterBar> {
  late TextEditingController _searchController;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.currentFilter.searchQuery ?? '');
    _searchController.addListener(_onTextControllerChanged);
  }

  void _onTextControllerChanged() {
    setState(() {});
  }

  @override
  void didUpdateWidget(covariant OrderFilterBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentFilter.searchQuery != oldWidget.currentFilter.searchQuery) {
      final newText = widget.currentFilter.searchQuery ?? '';
      if (_searchController.text != newText) {
        _searchController.value = TextEditingValue(
          text: newText,
          selection: TextSelection.collapsed(offset: newText.length),
        );
      }
    }
  }

  @override
  void dispose() {
    _searchController.removeListener(_onTextControllerChanged);
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 350), () {
      _triggerSearch(value);
    });
  }

  void _triggerSearch(String value) {
    final trimmed = value.trim();
    widget.onFilterChanged(
      widget.currentFilter.copyWith(
        searchQuery: trimmed,
        clearSearch: trimmed.isEmpty,
        page: 1,
      ),
    );
  }

  void _clearSearch() {
    _debounceTimer?.cancel();
    _searchController.clear();
    _triggerSearch('');
  }

  bool get _isTodaySelected {
    if (widget.currentFilter.fromDate == null || widget.currentFilter.toDate == null) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final f = widget.currentFilter.fromDate!;
    final t = widget.currentFilter.toDate!;
    return DateTime(f.year, f.month, f.day) == today && DateTime(t.year, t.month, t.day) == today;
  }

  void _filterToday() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    if (_isTodaySelected) {
      widget.onFilterChanged(
        widget.currentFilter.copyWith(clearDate: true, page: 1),
      );
    } else {
      widget.onFilterChanged(
        widget.currentFilter.copyWith(
          fromDate: today,
          toDate: today,
          page: 1,
        ),
      );
    }
  }

  Future<void> _pickSingleDate({required bool isFrom}) async {
    final now = DateTime.now();
    final initial = isFrom
        ? (widget.currentFilter.fromDate ?? now)
        : (widget.currentFilter.toDate ?? widget.currentFilter.fromDate ?? now);

    final picked = await showDatePicker(
      context: context,
      initialDate: initial.isAfter(DateTime(now.year + 1)) ? now : initial,
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year + 1),
      helpText: isFrom ? 'Chọn ngày bắt đầu' : 'Chọn ngày kết thúc',
      cancelText: 'Hủy',
      confirmText: 'Áp dụng',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: ColorPalette.primaryContainer,
              onPrimary: Colors.white,
              onSurface: ColorPalette.onSurfaceDark,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      if (isFrom) {
        DateTime? newTo = widget.currentFilter.toDate;
        if (newTo != null && picked.isAfter(newTo)) {
          newTo = picked;
        }
        widget.onFilterChanged(
          widget.currentFilter.copyWith(
            fromDate: picked,
            toDate: newTo,
            page: 1,
          ),
        );
      } else {
        DateTime? newFrom = widget.currentFilter.fromDate;
        if (newFrom != null && picked.isBefore(newFrom)) {
          newFrom = picked;
        }
        widget.onFilterChanged(
          widget.currentFilter.copyWith(
            fromDate: newFrom,
            toDate: picked,
            page: 1,
          ),
        );
      }
    }
  }

  Widget _buildDateButton({
    required String label,
    required VoidCallback onTap,
    bool hasValue = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: hasValue ? ColorPalette.primaryFixed.withValues(alpha: 0.35) : const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: hasValue ? ColorPalette.primaryContainer : ColorPalette.borderSubtle,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.calendar_today_rounded,
              size: 13,
              color: hasValue ? ColorPalette.primaryContainer : ColorPalette.textMuted,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTypography.inter(
                fontSize: 12,
                fontWeight: hasValue ? FontWeight.w600 : FontWeight.w400,
                color: hasValue ? ColorPalette.primaryContainer : ColorPalette.onSurfaceDark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ColorPalette.surfaceWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ColorPalette.borderSubtle),
      ),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          // ── Search Input ──────────────────────────────────────────────────
          SizedBox(
            width: 280,
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              textInputAction: TextInputAction.search,
              onSubmitted: (value) {
                _debounceTimer?.cancel();
                _triggerSearch(value);
              },
              decoration: InputDecoration(
                hintText: 'Tìm theo mã đơn, khách, SĐT...',
                hintStyle: AppTypography.inter(fontSize: 13, color: ColorPalette.textMuted),
                prefixIcon: const Icon(Icons.search_rounded, size: 20, color: ColorPalette.textMuted),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 18),
                        tooltip: 'Xóa tìm kiếm',
                        onPressed: _clearSearch,
                      )
                    : null,
                isDense: true,
                filled: true,
                fillColor: const Color(0xFFF9FAFB),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: ColorPalette.borderSubtle),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: ColorPalette.borderSubtle),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: ColorPalette.primaryContainer, width: 1.5),
                ),
              ),
            ),
          ),

          // ── Quick "Hôm nay" Pill ──────────────────────────────────────────
          InkWell(
            onTap: _filterToday,
            borderRadius: BorderRadius.circular(8),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: _isTodaySelected ? ColorPalette.primaryContainer : const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _isTodaySelected ? ColorPalette.primaryContainer : ColorPalette.borderSubtle,
                ),
              ),
              child: Text(
                'Hôm nay',
                style: AppTypography.inter(
                  fontSize: 12,
                  fontWeight: _isTodaySelected ? FontWeight.w600 : FontWeight.w500,
                  color: _isTodaySelected ? Colors.white : ColorPalette.onSurfaceDark,
                ),
              ),
            ),
          ),

          // ── Inline Compact Date Picker: Từ ngày — Đến ngày ───────────────
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDateButton(
                label: widget.currentFilter.fromDate != null
                    ? DateFormat('dd/MM/yyyy').format(widget.currentFilter.fromDate!)
                    : 'Từ ngày',
                hasValue: widget.currentFilter.fromDate != null,
                onTap: () => _pickSingleDate(isFrom: true),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 6),
                child: Text('-', style: TextStyle(color: ColorPalette.textMuted, fontWeight: FontWeight.bold)),
              ),
              _buildDateButton(
                label: widget.currentFilter.toDate != null
                    ? DateFormat('dd/MM/yyyy').format(widget.currentFilter.toDate!)
                    : 'Đến ngày',
                hasValue: widget.currentFilter.toDate != null,
                onTap: () => _pickSingleDate(isFrom: false),
              ),
              if (widget.currentFilter.fromDate != null || widget.currentFilter.toDate != null) ...[
                const SizedBox(width: 4),
                IconButton(
                  icon: const Icon(Icons.cancel_rounded, size: 16, color: ColorPalette.textMuted),
                  tooltip: 'Xóa khoảng ngày',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                  onPressed: () {
                    widget.onFilterChanged(
                      widget.currentFilter.copyWith(clearDate: true, page: 1),
                    );
                  },
                ),
              ],
            ],
          ),

          // ── Status Dropdown ───────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: ColorPalette.borderSubtle),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: widget.currentFilter.orderStatus ?? 'ALL',
                icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 20),
                style: AppTypography.inter(fontSize: 13, color: ColorPalette.onSurfaceDark),
                items: const [
                  DropdownMenuItem(value: 'ALL', child: Text('Trạng thái: Tất cả')),
                  DropdownMenuItem(value: 'COMPLETED', child: Text('Hoàn thành')),
                  DropdownMenuItem(value: 'CANCELLED', child: Text('Đã hủy')),
                  DropdownMenuItem(value: 'PENDING', child: Text('Chờ xử lý')),
                ],
                onChanged: (val) {
                  widget.onFilterChanged(
                    widget.currentFilter.copyWith(
                      orderStatus: val,
                      clearStatus: val == null || val == 'ALL',
                      page: 1,
                    ),
                  );
                },
              ),
            ),
          ),

          // ── Payment Method Dropdown ───────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: ColorPalette.borderSubtle),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: widget.currentFilter.paymentMethod ?? 'ALL',
                icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 20),
                style: AppTypography.inter(fontSize: 13, color: ColorPalette.onSurfaceDark),
                items: const [
                  DropdownMenuItem(value: 'ALL', child: Text('Thanh toán: Tất cả')),
                  DropdownMenuItem(value: 'CASH', child: Text('Tiền mặt (CASH)')),
                  DropdownMenuItem(value: 'QR_CODE', child: Text('VietQR')),
                  DropdownMenuItem(value: 'BANK_TRANSFER', child: Text('Chuyển khoản')),
                ],
                onChanged: (val) {
                  widget.onFilterChanged(
                    widget.currentFilter.copyWith(
                      paymentMethod: val,
                      clearMethod: val == null || val == 'ALL',
                      page: 1,
                    ),
                  );
                },
              ),
            ),
          ),

          // ── Refresh Button ────────────────────────────────────────────────
          IconButton(
            onPressed: widget.onRefresh,
            icon: const Icon(Icons.refresh_rounded),
            color: ColorPalette.primaryContainer,
            tooltip: 'Làm mới danh sách',
          ),
        ],
      ),
    );
  }
}
