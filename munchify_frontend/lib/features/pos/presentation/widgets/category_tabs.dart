import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/ColorPalette.dart';
import '../bloc/pos_catalog_bloc.dart';
import '../bloc/pos_catalog_event.dart';
import '../bloc/pos_catalog_state.dart';

/// Thanh chip danh mục cuộn ngang (kèm lựa chọn "Tất cả").
class CategoryTabs extends StatelessWidget {
  final PosCatalogLoaded state;

  const CategoryTabs({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final categories = state.categories;

    return SizedBox(
      height: 48,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length + 2, // +1 for "All", +1 for "⚠️ Sắp hết"
        itemBuilder: (context, index) {
          // Vị trí 0: Chip lọc "⚠️ Sắp hết / Hết hàng"
          if (index == 0) {
            final isLowStockActive = state.isLowStockFilter;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                avatar: Icon(
                  Icons.warning_amber_rounded,
                  size: 16,
                  color: isLowStockActive ? Colors.white : Colors.orange.shade800,
                ),
                label: const Text('Sắp hết'),
                selected: isLowStockActive,
                onSelected: (_) {
                  context.read<PosCatalogBloc>().add(ToggleLowStockFilterEvent());
                },
                selectedColor: const Color(0xFFE65100),
                backgroundColor: Colors.orange.shade50,
                labelStyle: TextStyle(
                  color: isLowStockActive ? Colors.white : Colors.orange.shade900,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: isLowStockActive ? const Color(0xFFE65100) : Colors.orange.shade300,
                  ),
                ),
              ),
            );
          }

          final categoryIndex = index - 1;
          final isAllOption = categoryIndex == 0;
          final category = isAllOption ? null : categories[categoryIndex - 1];
          final isSelected = isAllOption
              ? (state.selectedCategoryId == null && !state.isLowStockFilter)
              : state.selectedCategoryId == category?.id;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(isAllOption ? 'Tất cả' : category!.name),
              selected: isSelected,
              onSelected: (selected) {
                context.read<PosCatalogBloc>().add(
                      FilterByCategoryEvent(isAllOption ? null : category?.id),
                    );
              },
              selectedColor: ColorPalette.appetizingOrange,
              backgroundColor: ColorPalette.surface,
              labelStyle: TextStyle(
                color: isSelected ? ColorPalette.onPrimary : Colors.black87,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected ? ColorPalette.appetizingOrange : Colors.grey.shade300,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
