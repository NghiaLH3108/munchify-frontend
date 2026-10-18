import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ProductDetailBottomSheet extends StatelessWidget {
  final String productName;
  final String productCode;
  final double price;
  final int stockQuantity;
  final String unitName;
  final String imageUrl;

  const ProductDetailBottomSheet({
    Key? key,
    required this.productName,
    required this.productCode,
    required this.price,
    required this.stockQuantity,
    required this.unitName,
    required this.imageUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Image & Basic Info
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 100,
                  height: 100,
                  color: Colors.grey.shade100,
                  child: imageUrl.isNotEmpty
                      ? Image.network(imageUrl, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.fastfood, size: 40, color: Colors.grey))
                      : const Icon(Icons.fastfood, size: 40, color: Colors.grey),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        productCode,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      productName,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      currencyFormat.format(price),
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFFC62828)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),
          // Details
          const Text('Thông tin chi tiết', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _buildDetailRow('Đơn vị bán:', unitName),
          _buildDetailRow(
            'Tồn kho hiện tại:',
            stockQuantity <= 0 ? 'Hết hàng (0)' : '$stockQuantity $unitName',
            isWarning: stockQuantity <= 5,
            isError: stockQuantity <= 0,
          ),
          const SizedBox(height: 32),
          // Add to cart button
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton.icon(
              onPressed: stockQuantity <= 0
                  ? null
                  : () => Navigator.pop(context, true),
              icon: Icon(
                stockQuantity <= 0 ? Icons.remove_shopping_cart_outlined : Icons.add_shopping_cart_rounded,
                color: Colors.white,
              ),
              label: Text(
                stockQuantity <= 0 ? 'SẢN PHẨM ĐÃ HẾT HÀNG' : 'THÊM VÀO GIỎ HÀNG',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: stockQuantity <= 0 ? Colors.grey.shade400 : const Color(0xFFE65100),
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey.shade300,
                disabledForegroundColor: Colors.grey.shade500,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const SizedBox(height: 16), // safe area
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isWarning = false, bool isError = false}) {
    Color valueColor = Colors.black87;
    if (isError) {
      valueColor = const Color(0xFFC62828);
    } else if (isWarning) {
      valueColor = Colors.orange.shade800;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 15)),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}
