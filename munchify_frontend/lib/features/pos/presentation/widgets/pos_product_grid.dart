import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/ColorPalette.dart';
import '../../domain/entities/product_entity.dart';
import '../bloc/cart_cubit.dart';
import 'product_grid_item.dart';

/// Lưới sản phẩm đơn 2 cột (sliver). Hiển thị thông báo khi rỗng.
class PosProductGrid extends StatelessWidget {
  final List<ProductEntity> products;

  const PosProductGrid({Key? key, required this.products}) : super(key: key);

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

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.90,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final product = products[index];

            return ProductGridItem(
              productCode: product.code,
              productName: product.name,
              unitName: product.unitName,
              stockQuantity: product.stockQuantity,
              price: product.price,
              imageUrl: product.imageUrl ?? '',
              onAddToCart: product.stockQuantity > 0
                  ? () => context.read<CartCubit>().addItem(product)
                  : null,
            );
          },
          childCount: products.length,
        ),
      ),
    );
  }
}
