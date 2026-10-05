import 'package:flutter/material.dart';
import '../../../../core/theme/ColorPalette.dart';

/// Tiêu đề section "Combo Ưu Đãi" kèm số lượng combo.
class ComboSectionHeader extends StatelessWidget {
  final int count;

  const ComboSectionHeader({Key? key, required this.count}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: ColorPalette.amber,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.stars, color: ColorPalette.onPrimary, size: 16),
              ),
              const SizedBox(width: 8),
              const Text(
                'Combo Ưu Đãi',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: ColorPalette.warmDarkGrey,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: ColorPalette.amber.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$count combo',
                  style: const TextStyle(
                    color: ColorPalette.appetizingOrange,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const Text(
            'Tiết kiệm hơn khi mua combo',
            style: TextStyle(color: ColorPalette.textHint, fontSize: 11),
          ),
        ],
      ),
    );
  }
}
