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
          _buildDetailRow('Tồn kho hiện tại:', '$stockQuantity $unitName', isWarning: stockQuantity < 5),
          const SizedBox(height: 32),
          // Add to cart button
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: () {
                // TODO: Gọi BLoC thêm vào giỏ hàng
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE65100),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('THÊM VÀO GIỎ HÀNG', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 16), // safe area
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isWarning = false}) {
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
              color: isWarning ? Colors.orange.shade800 : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
