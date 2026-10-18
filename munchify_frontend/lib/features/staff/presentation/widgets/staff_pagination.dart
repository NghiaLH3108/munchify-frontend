import 'package:flutter/material.dart';
import '../../../../core/theme/AppTypography.dart';
import '../../../../core/theme/ColorPalette.dart';

/// Pagination controls for staff list:
/// - Text status (Current page / total pages / total staff count)
/// - Previous page button
/// - Active page indicator badge
/// - Next page button
class StaffPagination extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final int totalCount;
  final VoidCallback onPreviousPage;
  final VoidCallback onNextPage;

  const StaffPagination({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.totalCount,
    required this.onPreviousPage,
    required this.onNextPage,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
      child: Wrap(
        spacing: 12,
        runSpacing: 10,
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(
            'Hiển thị trang $currentPage / $totalPages (Tổng $totalCount nhân viên)',
            style: AppTypography.dashboardSubtitle,
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildPaginationButton(
                icon: Icons.chevron_left_rounded,
                label: 'Trước',
                enabled: currentPage > 1,
                onTap: onPreviousPage,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: ColorPalette.appetizingOrange,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$currentPage',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              _buildPaginationButton(
                icon: Icons.chevron_right_rounded,
                label: 'Sau',
                enabled: currentPage < totalPages,
                onTap: onNextPage,
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
              Icon(
                icon,
                size: 16,
                color: enabled ? ColorPalette.textPrimary : ColorPalette.textMuted,
              ),
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
              Icon(
                icon,
                size: 16,
                color: enabled ? ColorPalette.textPrimary : ColorPalette.textMuted,
              ),
          ],
        ),
      ),
    );
  }
}
