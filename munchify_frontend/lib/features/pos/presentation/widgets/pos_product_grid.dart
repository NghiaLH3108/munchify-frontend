import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/ColorPalette.dart';
import '../../domain/entities/product_entity.dart';
import '../bloc/cart_cubit.dart';
import 'product_detail_bottom_sheet.dart';
import 'product_grid_item.dart';

/// Lưới sản phẩm đơn 2 cột (sliver). Hiển thị thông báo khi rỗng.
class PosProductGrid extends StatelessWidget {
  final List<ProductEntity> products;

  const PosProductGrid({super.key, required this.products});

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      return const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Center(
            child: Text(
              'Không tìm thấy sản phẩm nào',
              style: TextStyle(color: ColorPalette.textHint),
            ),
          ),
        ),
      );
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth >= 1200
        ? 5
        : (screenWidth >= 800 ? 4 : (screenWidth >= 600 ? 3 : 2));
    final childAspectRatio = screenWidth < 600 ? 0.85 : 0.9;

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: childAspectRatio,
        ),
        delegate: SliverChildBuilderDelegate((context, index) {
          final product = products[index];
          final cartCubit = context.read<CartCubit>();

          return ProductGridItem(
            productCode: product.code,
            productName: product.name,
            unitName: product.unitName,
            stockQuantity: product.stockQuantity,
            price: product.price,
            imageUrl: product.imageUrl ?? '',
            // Nút "+" → thêm ngay vào giỏ không qua sheet
            onAddToCart: product.stockQuantity > 0
                ? () => cartCubit.addItem(product)
                : null,
            // Tap vào card → mở detail sheet; nếu user bấm "Thêm" trong sheet → addItem
            onTapCard: () async {
              final added = await showModalBottomSheet<bool>(
                context: context,
                showDragHandle: false,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => ProductDetailBottomSheet(
                  productName: product.name,
                  productCode: product.code,
                  price: product.price,
                  stockQuantity: product.stockQuantity,
                  unitName: product.unitName,
                  imageUrl: product.imageUrl ?? '',
                ),
              );
              if (added == true) {
                cartCubit.addItem(product);
              }
            },
          );
        }, childCount: products.length),
      ),
    );
  }
}
