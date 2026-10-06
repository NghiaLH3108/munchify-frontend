import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/product_entity.dart';
import '../bloc/product_admin_bloc.dart';
import '../bloc/product_admin_event.dart';
import 'product_form_dialog.dart';

class ProductDataTable extends StatelessWidget {
  final List<ProductEntity> products;

  const ProductDataTable({Key? key, required this.products}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListView.separated(
        itemCount: products.length + 1, // +1 for header
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          if (index == 0) {
            return _buildHeaderRow(context);
          }
          final product = products[index - 1];
          return _buildDataRow(context, product, currencyFormat);
        },
      ),
    );
  }

  Widget _buildHeaderRow(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
      child: Row(
        children: const [

          SizedBox(width: 80, child: Text('Hình ảnh', style: TextStyle(fontWeight: FontWeight.bold))),
          SizedBox(width: 100, child: Text('Mã SKU', style: TextStyle(fontWeight: FontWeight.bold))),
          Expanded(child: Text('Tên món / Sản phẩm', style: TextStyle(fontWeight: FontWeight.bold))),
          SizedBox(width: 120, child: Text('Danh mục', style: TextStyle(fontWeight: FontWeight.bold))),
          SizedBox(width: 120, child: Text('Đơn giá', textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.bold))),
          SizedBox(width: 120, child: Text('Tồn kho / Mức', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))),
          SizedBox(width: 100, child: Text('Trạng thái', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))),
          SizedBox(width: 100, child: Text('Thao tác', textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }

  Widget _buildDataRow(BuildContext context, ProductEntity product, NumberFormat currencyFormat) {

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [

          SizedBox(
            width: 80,
            child: Align(
              alignment: Alignment.centerLeft,
              child: SizedBox(
                width: 48,
                height: 48,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: product.imageUrl != null
                      ? Image.network(product.imageUrl!, fit: BoxFit.cover, errorBuilder: (_,__,___) => const Icon(Icons.fastfood))
                      : Container(color: Colors.grey[200], child: const Icon(Icons.fastfood)),
                ),
              ),
            ),
          ),
          SizedBox(width: 100, child: Text(product.sku)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text('ĐVT: ${product.unitName ?? 'N/A'}', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
              ],
            ),
          ),
          SizedBox(
            width: 120,
            child: Chip(
              label: Text(product.categoryName ?? 'Unknown', style: const TextStyle(fontSize: 12)),
              backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
            ),
          ),
          SizedBox(
            width: 120,
            child: Text(
              currencyFormat.format(product.price),
              textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.deepOrange),
            ),
          ),
          SizedBox(
            width: 120,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${product.stockQuantity} / ${product.minStockLevel}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 100,
            child: Center(
              child: Switch(
                value: product.isActive,
                onChanged: (value) {
                  context.read<ProductAdminBloc>().add(ToggleProductStatusEvent(product.id, value));
                },
                activeColor: Colors.orange,
              ),
            ),
          ),
          SizedBox(
            width: 100,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(icon: const Icon(Icons.edit, size: 20), onPressed: () {
                  ProductFormDialog.show(context, product: product);
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
