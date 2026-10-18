import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/ColorPalette.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/entities/combo_item_entity.dart';
import '../bloc/cart_cubit.dart';

/// Bottom sheet hiển thị chi tiết combo: danh sách thành phần + SavingAmount thực
class ComboDetailBottomSheet extends StatelessWidget {
  final ProductEntity combo;

  const ComboDetailBottomSheet({Key? key, required this.combo}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    final saving = combo.savingAmount;
    final componentTotal = combo.componentsTotalPrice;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: ColorPalette.amber,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.star, size: 12, color: Colors.white),
                      SizedBox(width: 4),
                      Text(
                        'COMBO ƯU ĐÃI',
                        style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  combo.code,
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            child: Text(
              combo.name,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: ColorPalette.warmDarkGrey),
            ),
          ),

          const SizedBox(height: 16),

          // Saving banner
          if (saving > 0)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [ColorPalette.appetizingOrange, ColorPalette.amberDark],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.savings_outlined, color: Colors.white, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Tiết kiệm khi mua combo',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                        Text(
                          currency.format(saving),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        currency.format(combo.price),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        currency.format(componentTotal),
                        style: const TextStyle(
                          color: Colors.white60,
                          fontSize: 12,
                          decoration: TextDecoration.lineThrough,
                          decorationColor: Colors.white60,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

          // Components header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
            child: Row(
              children: [
                const Icon(Icons.inventory_2_outlined, size: 16, color: ColorPalette.appetizingOrange),
                const SizedBox(width: 8),
                Text(
                  'Thành phần combo (${combo.comboItems.length} sản phẩm)',
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: ColorPalette.warmDarkGrey),
                ),
              ],
            ),
          ),

          // Components list
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: combo.comboItems.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final item = combo.comboItems[index];
              return _ComboComponentTile(item: item, currency: currency);
            },
          ),

          // Add to cart button
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: combo.isComboAvailable
                    ? () {
                        context.read<CartCubit>().addItem(combo);
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Đã thêm ${combo.name} vào giỏ'),
                            duration: const Duration(seconds: 1),
                            backgroundColor: ColorPalette.success,
                          ),
                        );
                      }
                    : null,
                icon: const Icon(Icons.add_shopping_cart),
                label: Text(
                  combo.isComboAvailable
                      ? 'Thêm vào giỏ hàng · ${currency.format(combo.price)}'
                      : 'Hết hàng',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: combo.isComboAvailable ? ColorPalette.appetizingOrange : Colors.grey,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ComboComponentTile extends StatelessWidget {
  final ComboItemEntity item;
  final NumberFormat currency;

  const _ComboComponentTile({required this.item, required this.currency});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          // Quantity badge
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: ColorPalette.amberTint,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: ColorPalette.amber),
            ),
            child: Center(
              child: Text(
                'x${item.quantity}',
                style: const TextStyle(
                  color: ColorPalette.appetizingOrange,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Name + unit + stock
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.componentProductName,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
                Row(
                  children: [
                    Text(
                      item.unitName,
                      style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(
                        color: item.hasEnoughStock ? Colors.green.shade50 : Colors.red.shade50,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: item.hasEnoughStock ? Colors.green.shade200 : Colors.red.shade200,
                        ),
                      ),
                      child: Text(
                        'Kho: ${item.componentStockQuantity}',
                        style: TextStyle(
                          color: item.hasEnoughStock ? Colors.green.shade700 : Colors.red.shade700,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Price per component
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                currency.format(item.unitPrice),
                style: const TextStyle(color: ColorPalette.warmDarkGrey, fontWeight: FontWeight.w500, fontSize: 13),
              ),
              if (item.quantity > 1)
                Text(
                  'Tổng: ${currency.format(item.totalPrice)}',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
