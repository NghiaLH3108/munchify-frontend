import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/ColorPalette.dart';
import '../bloc/pos_catalog_bloc.dart';
import '../bloc/pos_catalog_state.dart';
import 'unit_filter_bottom_sheet.dart';

/// Hàng thông tin: số sản phẩm đang hiển thị + nút bộ lọc đơn vị.
class CatalogInfoRow extends StatelessWidget {
  final PosCatalogLoaded state;

  const CatalogInfoRow({Key? key, required this.state}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final displayedCount = state.displayedProducts.length;
    final hasUnitFilter = state.selectedUnitName != null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          RichText(
            text: TextSpan(
              style: const TextStyle(color: Colors.black54, fontSize: 13),
              children: [
                const TextSpan(text: 'Hiển thị '),
                TextSpan(
                  text: '$displayedCount sản phẩm',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: ColorPalette.textPrimary),
                ),
                const TextSpan(text: ' thực đơn'),
              ],
            ),
          ),
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => UnitFilterBottomSheet.show(
              context,
              bloc: context.read<PosCatalogBloc>(),
              state: state,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 48, minWidth: 48),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.filter_list,
                    size: 16,
                    color: hasUnitFilter ? ColorPalette.onPrimary : ColorPalette.appetizingOrange,
                  ),
                  const SizedBox(width: 4),
                  Container(
                    padding: hasUnitFilter ? const EdgeInsets.symmetric(horizontal: 8, vertical: 4) : null,
                    decoration: hasUnitFilter
                        ? BoxDecoration(
                            color: ColorPalette.appetizingOrange,
                            borderRadius: BorderRadius.circular(12),
                          )
                        : null,
                    child: Text(
                      hasUnitFilter ? state.selectedUnitName! : 'Bộ lọc nhanh',
                      style: TextStyle(
                        color: hasUnitFilter ? ColorPalette.onPrimary : ColorPalette.appetizingOrange,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
