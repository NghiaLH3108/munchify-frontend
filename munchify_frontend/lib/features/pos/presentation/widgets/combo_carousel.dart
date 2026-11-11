import 'package:flutter/material.dart';
import '../../domain/entities/product_entity.dart';
import 'combo_grid_item.dart';

/// Danh sách card combo giàn đều theo chiều ngang (Wrap).
class ComboCarousel extends StatelessWidget {
  final List<ProductEntity> combos;

  const ComboCarousel({Key? key, required this.combos}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 650;
    
    // Trên mobile: mỗi combo card rộng gần bằng cả màn hình (trừ lề 32px), tạo cảm giác 1 card nằm ngang trọn vẹn
    final cardWidth = isMobile ? (screenWidth - 48).clamp(280.0, 420.0) : 340.0;
    final carouselHeight = isMobile ? 160.0 : 250.0;

    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 14),
      child: SizedBox(
        height: carouselHeight,
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          itemCount: combos.length,
          separatorBuilder: (_, __) => const SizedBox(width: 12),
          itemBuilder: (context, index) {
            return SizedBox(
              width: cardWidth,
              height: carouselHeight,
              child: ComboGridItem(
                combo: combos[index],
                isHorizontal: isMobile,
              ),
            );
          },
        ),
      ),
    );
  }
}
