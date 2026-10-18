import 'package:flutter/material.dart';
import '../../../../core/theme/ColorPalette.dart';

class PromotionFilterBar extends StatelessWidget {
  final TextEditingController searchController;
  final VoidCallback onSearch;
  final VoidCallback onClear;
  final bool hasSearchQuery;

  const PromotionFilterBar({
    super.key,
    required this.searchController,
    required this.onSearch,
    required this.onClear,
    required this.hasSearchQuery,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 600;
          final searchWidget = SizedBox(
            height: 40,
            child: TextField(
              controller: searchController,
              onSubmitted: (_) => onSearch(),
              style: const TextStyle(fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Tìm theo mã hoặc tên khuyến mãi...',
                hintStyle: const TextStyle(fontSize: 12, color: ColorPalette.textMuted),
                prefixIcon: const Icon(Icons.search_rounded,
                    size: 18, color: ColorPalette.textMuted),
                suffixIcon: hasSearchQuery
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 16),
                        onPressed: onClear,
                      )
                    : null,
                filled: true,
                fillColor: ColorPalette.webBgAdmin,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: ColorPalette.borderSubtle),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: ColorPalette.borderSubtle),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                    color: ColorPalette.primaryContainer,
                    width: 1.5,
                  ),
                ),
              ),
            ),
          );

          if (isWide) {
            return Row(
              children: [
                Expanded(flex: 3, child: searchWidget),
                const Spacer(flex: 2),
              ],
            );
          } else {
            return searchWidget;
          }
        },
      ),
    );
  }
}
