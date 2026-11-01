import 'package:flutter/material.dart';
import '../../theme/ColorPalette.dart';
import '../../theme/AppTypography.dart';

/// Reusable Admin Search & Filter Bar.
///
/// Features:
/// - Search input with search icon, clear button, and live change callback
/// - Custom filter slot ([filters]) accepting dropdowns, date pickers, pills, etc.
/// - Optional [trailingActions] (e.g. refresh button, export button, view mode switch)
/// - Responsive layout (Row on desktop, Wrap on narrow screens)
class AdminFilterBar extends StatelessWidget {
  final TextEditingController searchController;
  final String searchHint;
  final ValueChanged<String>? onSearchChanged;
  final VoidCallback? onClearSearch;
  final List<Widget>? filters;
  final List<Widget>? trailingActions;

  const AdminFilterBar({
    super.key,
    required this.searchController,
    this.searchHint = 'Tìm kiếm...',
    this.onSearchChanged,
    this.onClearSearch,
    this.filters,
    this.trailingActions,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFEDD5), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: ColorPalette.appetizingOrange.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 768;

          final searchInput = SizedBox(
            height: 40,
            child: TextField(
              controller: searchController,
              onChanged: onSearchChanged,
              style: AppTypography.inter(
                fontSize: 13,
                color: const Color(0xFF1E293B),
              ),
              decoration: InputDecoration(
                isDense: true,
                filled: true,
                fillColor: const Color(0xFFFFFBF8),
                hintText: searchHint,
                hintStyle: AppTypography.inter(
                  fontSize: 13,
                  color: const Color(0xFF94A3B8),
                ),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  size: 20,
                  color: ColorPalette.appetizingOrange,
                ),
                suffixIcon: searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 16),
                        color: const Color(0xFF94A3B8),
                        onPressed: () {
                          searchController.clear();
                          if (onClearSearch != null) {
                            onClearSearch!();
                          } else if (onSearchChanged != null) {
                            onSearchChanged!('');
                          }
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFFFFE0B2)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFFFFE0B2)),
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
          );

          if (isWide) {
            return Row(
              children: [
                Expanded(child: searchInput),
                if (filters != null && filters!.isNotEmpty) ...[
                  const SizedBox(width: 12),
                  ...filters!.map((f) => Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: f,
                      )),
                ],
                if (trailingActions != null && trailingActions!.isNotEmpty) ...[
                  const SizedBox(width: 12),
                  ...trailingActions!,
                ],
              ],
            );
          }

          // Narrow Screen Layout
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              searchInput,
              if ((filters != null && filters!.isNotEmpty) ||
                  (trailingActions != null && trailingActions!.isNotEmpty)) ...[
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    ...?filters,
                    ...?trailingActions,
                  ],
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}
