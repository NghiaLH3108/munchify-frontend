import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../theme/AppTypography.dart';
import '../../theme/ColorPalette.dart';
import 'admin_state_views.dart';
import 'admin_table_column.dart';

/// "Table card" chuẩn cho mọi danh sách Admin.
///
/// Gồm: thanh tiêu đề (tên + badge đếm + toggle Bảng/Lưới) → bảng
/// (header 44px, row 64px, cuộn ngang khi hẹp) hoặc lưới thẻ → phân trang.
///
/// Toggle Bảng/Lưới chỉ hiện khi truyền [cardBuilder].
class AdminDataTable<T> extends StatelessWidget {
  final String title;
  final String countLabel;
  final String? subtitle;
  final List<T> items;
  final List<AdminTableColumn<T>> columns;
  final int indexOffset;
  final ValueChanged<T>? onRowTap;
  final Widget Function(BuildContext context, T item, int index)? cardBuilder;
  final bool isCardView;
  final ValueChanged<bool>? onToggleView;
  final bool isRefreshing;
  final Widget? pagination;
  final Widget? emptyState;
  final double minTableWidth;
  final double rowHeight;
  final double columnSpacing;
  final List<Widget>? headerActions;

  const AdminDataTable({
    super.key,
    required this.title,
    required this.countLabel,
    required this.items,
    required this.columns,
    this.subtitle,
    this.indexOffset = 0,
    this.onRowTap,
    this.cardBuilder,
    this.isCardView = false,
    this.onToggleView,
    this.isRefreshing = false,
    this.pagination,
    this.emptyState,
    this.minTableWidth = 920,
    this.rowHeight = 64,
    this.columnSpacing = 16,
    this.headerActions,
  });

  bool get _canToggle => cardBuilder != null && onToggleView != null;

  @override
  Widget build(BuildContext context) {
    final showCards = _canToggle && isCardView;

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
          _buildTitleBar(),
          const Divider(height: 1, color: ColorPalette.borderSubtle),
          if (items.isEmpty)
            emptyState ?? const AdminEmptyState()
          else if (showCards)
            _buildCardGrid(context)
          else
            _buildTable(context),
          if (pagination != null) ...[
            const Divider(height: 1, color: ColorPalette.borderSubtle),
            pagination!,
          ],
        ],
      ),
    );
  }

  // ─── Thanh tiêu đề ────────────────────────────────────────────────────────
  Widget _buildTitleBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
      child: Wrap(
        spacing: 16,
        runSpacing: 12,
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
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
                      countLabel,
                      style: AppTypography.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: ColorPalette.primaryContainer,
                      ),
                    ),
                  ),
                ],
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle!,
                  style: AppTypography.inter(
                    fontSize: 12,
                    color: ColorPalette.textMuted,
                  ),
                ),
              ],
            ],
          ),
          Wrap(
            spacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              ...?headerActions,
              if (_canToggle) _buildViewToggle(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildViewToggle() {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: ColorPalette.webBgAdmin,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: ColorPalette.borderSubtle),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ViewModeButton(
            icon: Icons.table_rows_rounded,
            tooltip: 'Dạng bảng chi tiết',
            isSelected: !isCardView,
            onTap: () => onToggleView!(false),
          ),
          _ViewModeButton(
            icon: Icons.grid_view_rounded,
            tooltip: 'Dạng thẻ lưới trực quan',
            isSelected: isCardView,
            onTap: () => onToggleView!(true),
          ),
        ],
      ),
    );
  }

  // ─── Bảng ─────────────────────────────────────────────────────────────────
  Widget _buildTable(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = math.max(minTableWidth, constraints.maxWidth);
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: width,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeaderRow(),
                for (var i = 0; i < items.length; i++)
                  _buildDataRow(context, items[i], i + 1 + indexOffset),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _wrapCell(AdminTableColumn<T> col, Widget child) {
    if (col.width != null) return SizedBox(width: col.width, child: child);
    return Expanded(flex: col.flex, child: child);
  }

  List<Widget> _withGap(List<Widget> cells) {
    final out = <Widget>[];
    for (var i = 0; i < cells.length; i++) {
      out.add(cells[i]);
      if (i < cells.length - 1) {
        final gap =
            (i == 0 && columns.first.width != null) ? 12.0 : columnSpacing;
        out.add(SizedBox(width: gap));
      }
    }
    return out;
  }

  Widget _buildHeaderRow() {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: ColorPalette.webBgAdmin.withValues(alpha: 0.8),
        border: const Border(
          bottom: BorderSide(color: ColorPalette.borderSubtle),
        ),
      ),
      child: Row(
        children: _withGap([
          for (final col in columns)
            _wrapCell(
              col,
              Text(
                col.label,
                textAlign: col.align,
                style: AppTypography.tableHeader,
              ),
            ),
        ]),
      ),
    );
  }

  Widget _buildDataRow(BuildContext context, T item, int index) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onRowTap == null ? null : () => onRowTap!(item),
        hoverColor: ColorPalette.webBgAdmin.withValues(alpha: 0.4),
        child: Container(
          height: rowHeight,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: ColorPalette.borderSubtle, width: 0.5),
            ),
          ),
          child: Row(
            children: _withGap([
              for (final col in columns)
                _wrapCell(col, col.cellBuilder(context, item, index)),
            ]),
          ),
        ),
      ),
    );
  }

  // ─── Lưới thẻ ─────────────────────────────────────────────────────────────
  Widget _buildCardGrid(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final count = constraints.maxWidth > 1150
              ? 3
              : (constraints.maxWidth > 700 ? 2 : 1);
          const gap = 16.0;
          final cardWidth =
              (constraints.maxWidth - ((count - 1) * gap)) / count;
          return Wrap(
            spacing: gap,
            runSpacing: gap,
            children: [
              for (var i = 0; i < items.length; i++)
                SizedBox(
                  width: cardWidth,
                  child: cardBuilder!(context, items[i], i + 1 + indexOffset),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _ViewModeButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final bool isSelected;
  final VoidCallback onTap;

  const _ViewModeButton({
    required this.icon,
    required this.tooltip,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
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
}

