import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/ColorPalette.dart';
import '../../domain/entities/product_entity.dart';
import '../bloc/cart_cubit.dart';
import 'combo_detail_bottom_sheet.dart';

/// Card hiển thị combo trong carousel POS Home.
/// Layout 3 vùng cố định: Image (100px) → Content (co giãn) → Price (cố định dưới cùng)
class ComboGridItem extends StatelessWidget {
  final ProductEntity combo;
  final bool isHorizontal;

  const ComboGridItem({
    Key? key, 
    required this.combo,
    this.isHorizontal = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    final saving = combo.savingAmount;
    final isAvailable = combo.isComboAvailable;

    if (isHorizontal) {
      return _buildHorizontalCard(context, currency, saving, isAvailable);
    }

    return _buildVerticalCard(context, currency, saving, isAvailable);
  }

  Widget _buildHorizontalCard(
    BuildContext context, 
    NumberFormat currency, 
    double saving, 
    bool isAvailable
  ) {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          showDragHandle: false,
          backgroundColor: Colors.transparent,
          builder: (_) => ComboDetailBottomSheet(combo: combo),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isAvailable ? const Color(0xFFFFB74D) : Colors.grey.shade300,
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: isAvailable
                  ? Colors.orange.withOpacity(0.12)
                  : Colors.grey.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            // Left Image Banner
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(15)),
              child: Stack(
                children: [
                  Container(
                    width: 120,
                    height: double.infinity,
                    color: isAvailable ? Colors.orange.shade50 : Colors.grey.shade100,
                    child: combo.imageUrl != null && combo.imageUrl!.isNotEmpty
                        ? Image.network(
                            combo.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Center(
                              child: Icon(
                                Icons.fastfood,
                                size: 48,
                                color: isAvailable ? Colors.orange.shade300 : Colors.grey.shade400,
                              ),
                            ),
                          )
                        : Center(
                            child: Icon(
                              Icons.fastfood,
                              size: 48,
                              color: isAvailable ? Colors.orange.shade300 : Colors.grey.shade400,
                            ),
                          ),
                  ),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: ColorPalette.deepOrange,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        combo.code,
                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  if (!isAvailable)
                    Container(
                      width: 120,
                      color: Colors.black.withOpacity(0.35),
                      child: const Center(
                        child: Text(
                          'Hết hàng',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Right Information Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Badges
                        Row(
                          children: [
                            if (saving > 0)
                              Flexible(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: ColorPalette.amber,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.star, size: 10, color: Colors.white),
                                      const SizedBox(width: 2),
                                      Flexible(
                                        child: Text(
                                          'Tiết kiệm ${currency.format(saving)}',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            else
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Text(
                                  'Combo',
                                  style: TextStyle(color: Colors.grey, fontSize: 9, fontWeight: FontWeight.bold),
                                ),
                              ),
                            const SizedBox(width: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: Text(
                                '${combo.comboItems.length} SP',
                                style: const TextStyle(color: Colors.grey, fontSize: 9, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        // Combo Title
                        Text(
                          combo.name,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: ColorPalette.warmDarkGrey),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 1),
                        // Components subtext
                        Text(
                          combo.comboItems.map((c) => c.componentProductName).join(' + '),
                          style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                    // Price & Action Button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              currency.format(combo.price),
                              style: const TextStyle(
                                color: ColorPalette.error,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            if (combo.componentsTotalPrice > combo.price)
                              Text(
                                currency.format(combo.componentsTotalPrice),
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 10,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                          ],
                        ),
                        ElevatedButton.icon(
                          onPressed: isAvailable
                              ? () {
                                  context.read<CartCubit>().addItem(combo);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Đã thêm ${combo.name} vào giỏ'),
                                      duration: const Duration(seconds: 1),
                                      backgroundColor: ColorPalette.success,
                                    ),
                                  );
                                }
                              : null,
                          icon: const Icon(Icons.add, size: 16),
                          label: const Text('Chọn', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFBF360C),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            minimumSize: const Size(60, 32),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVerticalCard(
    BuildContext context, 
    NumberFormat currency, 
    double saving, 
    bool isAvailable
  ) {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          showDragHandle: false,
          backgroundColor: Colors.transparent,
          builder: (_) => ComboDetailBottomSheet(combo: combo),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isAvailable ? ColorPalette.amber : Colors.grey.shade300,
          ),
          boxShadow: [
            BoxShadow(
              color: isAvailable
                  ? Colors.orange.withOpacity(0.12)
                  : Colors.grey.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ═══════════ ZONE 1: Image — chiều cao cố định ═══════════
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Stack(
                children: [
                  Container(
                    height: 100,
                    width: double.infinity,
                    color: isAvailable ? Colors.orange.shade50 : Colors.grey.shade100,
                    child: Center(
                      child: Icon(
                        Icons.fastfood,
                        size: 48,
                        color: isAvailable ? Colors.orange.shade300 : Colors.grey.shade400,
                      ),
                    ),
                  ),
                  // Combo code badge
                  Positioned(
                    bottom: 6,
                    left: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: ColorPalette.deepOrange,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        combo.code,
                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  // Out of stock overlay
                  if (!isAvailable)
                    Container(
                      height: 100,
                      color: Colors.black.withOpacity(0.35),
                      child: const Center(
                        child: Text(
                          'Hết hàng',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // ═══════════ ZONE 2: Content — co giãn để fill ═══════════
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Badge row
                    Row(
                      children: [
                        if (saving > 0)
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                              decoration: BoxDecoration(
                                color: ColorPalette.amber,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.star, size: 10, color: Colors.white),
                                  const SizedBox(width: 2),
                                  Flexible(
                                    child: Text(
                                      'Tiết kiệm ${currency.format(saving)}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        else
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'Combo',
                              style: TextStyle(color: Colors.grey, fontSize: 9, fontWeight: FontWeight.bold),
                            ),
                          ),
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Text(
                            '${combo.comboItems.length} SP',
                            style: const TextStyle(color: Colors.grey, fontSize: 9, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 6),

                    // Combo name — tối đa 1 dòng
                    Text(
                      combo.name,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: ColorPalette.warmDarkGrey),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 2),

                    // Component names preview
                    Text(
                      combo.comboItems.map((c) => c.componentProductName).join(' + '),
                      style: TextStyle(color: Colors.grey.shade500, fontSize: 10),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),

            // ═══════════ ZONE 3: Price — cố định dưới cùng ═══════════
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        currency.format(combo.price),
                        style: const TextStyle(
                          color: ColorPalette.error,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      if (combo.componentsTotalPrice > combo.price)
                        Text(
                          currency.format(combo.componentsTotalPrice),
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 10,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                    ],
                  ),
                  // Touch target tối thiểu 48x48dp (AI Guide §6)
                  IconButton(
                    icon: const Icon(Icons.add, size: 20),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                    style: IconButton.styleFrom(
                      backgroundColor: ColorPalette.deepOrange,
                      foregroundColor: ColorPalette.onPrimary,
                      disabledBackgroundColor: Colors.grey.shade300,
                      disabledForegroundColor: ColorPalette.onPrimary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: isAvailable
                        ? () {
                            context.read<CartCubit>().addItem(combo);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Đã thêm ${combo.name} vào giỏ'),
                                duration: const Duration(seconds: 1),
                                backgroundColor: ColorPalette.success,
                              ),
                            );
                          }
                        : null,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
