import 'package:flutter/material.dart';
import 'package:intl/intl.dart';


class ProductGridItem extends StatelessWidget {
  final String productCode;
  final String productName;
  final String unitName;
  final int stockQuantity;
  final double price;
  final String imageUrl;
  final VoidCallback? onAddToCart;
  /// Callback khi tap vào card (mở detail sheet). Nếu null, sẽ không có tác dụng.
  final VoidCallback? onTapCard;

  const ProductGridItem({
    super.key,
    required this.productCode,
    required this.productName,
    required this.unitName,
    required this.stockQuantity,
    required this.price,
    required this.imageUrl,
    this.onAddToCart,
    this.onTapCard,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    final isOutOfStock = stockQuantity <= 0;
    final isLowStock = !isOutOfStock && stockQuantity <= 5;
    
    return GestureDetector(
      onTap: isOutOfStock
          ? () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Sản phẩm "$productName" hiện đã hết hàng trong kho!'),
                  backgroundColor: const Color(0xFFC62828),
                  duration: const Duration(seconds: 2),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          : onTapCard,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: isOutOfStock ? 0.55 : 1.0,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isOutOfStock
                  ? Colors.red.shade200
                  : (isLowStock ? Colors.orange.shade200 : Colors.grey.shade200),
              width: (isOutOfStock || isLowStock) ? 1.2 : 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image and badges
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                    child: ColorFiltered(
                      colorFilter: isOutOfStock
                          ? const ColorFilter.mode(Colors.grey, BlendMode.saturation)
                          : const ColorFilter.mode(Colors.transparent, BlendMode.multiply),
                      child: Container(
                        height: 105,
                        width: double.infinity,
                        color: Colors.grey.shade200,
                        child: imageUrl.isNotEmpty
                            ? Image.network(
                                imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    const Icon(Icons.fastfood, size: 40, color: Colors.grey),
                              )
                            : const Icon(Icons.fastfood, size: 40, color: Colors.grey),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        productCode,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        unitName,
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  // Out of stock overlay badge on top of image
                  if (isOutOfStock)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.35),
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                        ),
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFC62828),
                              borderRadius: BorderRadius.circular(6),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.2),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            child: const Text(
                              'HẾT HÀNG',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            productName,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: isOutOfStock ? Colors.grey.shade600 : Colors.black87,
                              decoration: isOutOfStock ? TextDecoration.lineThrough : null,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          // Stock badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: isOutOfStock
                                  ? Colors.red.shade50
                                  : (isLowStock ? Colors.orange.shade50 : Colors.green.shade50),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: isOutOfStock
                                    ? Colors.red.shade300
                                    : (isLowStock ? Colors.orange.shade200 : Colors.green.shade200),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  isOutOfStock
                                      ? Icons.cancel_outlined
                                      : (isLowStock
                                          ? Icons.warning_amber_rounded
                                          : Icons.check_circle_outline),
                                  size: 11,
                                  color: isOutOfStock
                                      ? Colors.red.shade700
                                      : (isLowStock ? Colors.orange : Colors.green.shade700),
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  isOutOfStock
                                      ? 'Hết hàng (0)'
                                      : (isLowStock ? 'Sắp hết: $stockQuantity' : 'Còn $stockQuantity'),
                                  style: TextStyle(
                                    color: isOutOfStock
                                        ? Colors.red.shade700
                                        : (isLowStock
                                            ? Colors.orange.shade700
                                            : Colors.green.shade700),
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      
                      // Price and Add Button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              currencyFormat.format(price),
                              style: TextStyle(
                                color: isOutOfStock ? Colors.grey : const Color(0xFFC62828),
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: isOutOfStock
                                  ? Colors.grey.shade300
                                  : const Color(0xFFBF360C), // Deep Orange/Brown
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: IconButton(
                              icon: Icon(
                                isOutOfStock ? Icons.block : Icons.add,
                                color: isOutOfStock ? Colors.grey.shade500 : Colors.white,
                                size: 18,
                              ),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                              onPressed: isOutOfStock
                                  ? null
                                  : onAddToCart,
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
      ),
    );
  }
}
