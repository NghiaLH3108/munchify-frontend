import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/ColorPalette.dart';
import '../bloc/pos_catalog_bloc.dart';
import '../bloc/pos_catalog_event.dart';
import '../bloc/pos_catalog_state.dart';

/// Thanh chip danh mục cuộn ngang (kèm lựa chọn "Tất cả").
class CategoryTabs extends StatelessWidget {
  final PosCatalogLoaded state;

  const CategoryTabs({Key? key, required this.state}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final categories = state.categories;

    return SizedBox(
      height: 48,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length + 1, // +1 for "All"
        itemBuilder: (context, index) {
          final isAllOption = index == 0;
          final category = isAllOption ? null : categories[index - 1];
          final isSelected = isAllOption
              ? state.selectedCategoryId == null
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
