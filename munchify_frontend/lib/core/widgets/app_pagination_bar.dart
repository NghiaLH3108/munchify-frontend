import 'package:flutter/material.dart';
import '../theme/AppTypography.dart';

/// ════════════════════════════════════════════════════════════════════════════
/// AppPaginationBar — Widget phân trang dùng chung cho toàn bộ danh sách
///
/// Chuẩn UI lấy từ UC10.1 Supplier List:
///   "Hiển thị 1 - 8 trong tổng số 25 nhà cung cấp"   [Trước] [1/3] [Sau]
///
/// Có 2 chế độ sử dụng:
///   1. Client-side paging (truyền startIndex + endIndex): dùng khi toàn bộ
///      data đã load về client và screen tự phân trang.
///   2. Server-side paging (truyền null cho startIndex/endIndex): widget sẽ
///      tự tính startIndex dựa trên currentPage × pageSize.
/// ════════════════════════════════════════════════════════════════════════════
class AppPaginationBar extends StatelessWidget {
  /// Trang hiện tại (1-based)
  final int currentPage;

  /// Tổng số trang
  final int totalPages;

  /// Tổng số bản ghi
  final int totalCount;

  /// Nhãn loại item, ví dụ: "nhà cung cấp", "nhân viên", "sản phẩm"
  final String itemLabel;

  /// Index bắt đầu của trang hiện tại (1-based, dùng cho client-side paging).
  /// Khi null, widget tự tính = (currentPage - 1) * pageSize + 1.
  final int? startIndex;

  /// Index kết thúc của trang hiện tại (1-based, dùng cho client-side paging).
  /// Khi null, widget tự tính = min(currentPage * pageSize, totalCount).
  final int? endIndex;

  /// Số item mỗi trang — chỉ cần khi startIndex/endIndex là null.
  final int pageSize;

  /// Callback khi nhấn "Trước"
  final VoidCallback? onPreviousPage;

  /// Callback khi nhấn "Sau"
  final VoidCallback? onNextPage;

  /// Callback khi trang thay đổi, nhận vào page mới (1-based).
  /// Nếu cung cấp, sẽ được gọi thay cho onPreviousPage/onNextPage.
  final ValueChanged<int>? onPageChanged;

  const AppPaginationBar({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.totalCount,
    this.itemLabel = 'mục',
    this.startIndex,
    this.endIndex,
    this.pageSize = 10,
    this.onPreviousPage,
    this.onNextPage,
    this.onPageChanged,
  });

  int get _displayTotalPages => totalPages < 1 ? 1 : totalPages;

  int get _displayStartIndex {
    if (startIndex != null) return totalCount > 0 ? startIndex! : 0;
    return totalCount > 0 ? (currentPage - 1) * pageSize + 1 : 0;
  }

  int get _displayEndIndex {
    if (endIndex != null) return endIndex!;
    final calc = currentPage * pageSize;
    return calc > totalCount ? totalCount : calc;
  }

  void _onPrev() {
    if (currentPage <= 1) return;
    if (onPageChanged != null) {
      onPageChanged!(currentPage - 1);
    } else {
      onPreviousPage?.call();
    }
  }

  void _onNext() {
    if (currentPage >= _displayTotalPages) return;
    if (onPageChanged != null) {
      onPageChanged!(currentPage + 1);
    } else {
      onNextPage?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final canPrev = currentPage > 1;
    final canNext = currentPage < _displayTotalPages;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFF1F5F9))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // ── Info text trái ────────────────────────────────────────────────
          Text(
            'Hiển thị ${_displayStartIndex > 0 ? _displayStartIndex : 0}'
            ' - $_displayEndIndex'
            ' trong tổng số $totalCount $itemLabel',
            style: AppTypography.inter(
              fontSize: 12,
              color: const Color(0xFF64748B),
            ),
          ),

          // ── Nút điều hướng phải ───────────────────────────────────────────
          Row(
            children: [
              _NavButton(
                label: 'Trước',
                enabled: canPrev,
                onTap: _onPrev,
              ),
              const SizedBox(width: 8),
              _PageBadge(
                currentPage: currentPage,
                totalPages: _displayTotalPages,
              ),
              const SizedBox(width: 8),
              _NavButton(
                label: 'Sau',
                enabled: canNext,
                onTap: _onNext,
                isNext: true,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Nút Trước / Sau ─────────────────────────────────────────────────────────
class _NavButton extends StatelessWidget {
  final String label;
  final bool enabled;
  final VoidCallback onTap;
  final bool isNext;

  const _NavButton({
    required this.label,
    required this.enabled,
    required this.onTap,
    this.isNext = false,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: enabled ? onTap : null,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        side: BorderSide(
          color: enabled ? const Color(0xFFE2E8F0) : const Color(0xFFF1F5F9),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        foregroundColor: enabled
            ? const Color(0xFF334155)
            : const Color(0xFFCBD5E1),
        disabledForegroundColor: const Color(0xFFCBD5E1),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: enabled ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
        ),
      ),
    );
  }
}

// ─── Badge trang hiện tại ────────────────────────────────────────────────────
class _PageBadge extends StatelessWidget {
  final int currentPage;
  final int totalPages;

  const _PageBadge({required this.currentPage, required this.totalPages});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFE65100),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$currentPage / $totalPages',
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }
}

