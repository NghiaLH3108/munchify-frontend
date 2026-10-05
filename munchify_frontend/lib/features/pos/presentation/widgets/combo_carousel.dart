import 'package:flutter/material.dart';
import '../../domain/entities/product_entity.dart';
import 'combo_grid_item.dart';

/// Danh sách card combo giàn đều theo chiều ngang (Wrap).
class ComboCarousel extends StatelessWidget {
  final List<ProductEntity> combos;

  const ComboCarousel({Key? key, required this.combos}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final availableWidth = constraints.maxWidth;
          final count = combos.length;
          const spacing = 12.0;
          // Tính chiều rộng mỗi card để giàn đều, tối thiểu 180px
          final cardWidth = ((availableWidth - (spacing * (count - 1))) / count)
              .clamp(180.0, 300.0);

          return Wrap(
            spacing: spacing,
            runSpacing: spacing,
            children: combos.map((combo) {
              return SizedBox(
                width: cardWidth,
                height: 260,
                child: ComboGridItem(combo: combo),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
