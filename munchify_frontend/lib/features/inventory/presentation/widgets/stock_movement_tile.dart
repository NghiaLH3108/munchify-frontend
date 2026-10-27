import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/stock_movement_entity.dart';

class StockMovementTile extends StatelessWidget {
  final StockMovementEntity movement;

  const StockMovementTile({super.key, required this.movement});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: _buildLeadingIcon(),
        title: Text(
          movement.productName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Loại: ${movement.movementType} | Người thực hiện: ${movement.staffName}'),
            Text(
              DateFormat('dd/MM/yyyy HH:mm').format(movement.createdAt),
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            if (movement.reason != null && movement.reason!.isNotEmpty)
              Text('Lý do: ${movement.reason}', style: const TextStyle(fontStyle: FontStyle.italic)),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${movement.quantity > 0 ? '+' : ''}${movement.quantity}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: movement.quantity > 0 ? Colors.green : Colors.red,
              ),
            ),
            Text(
              'Tồn: ${movement.newQuantity}',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeadingIcon() {
    IconData iconData;
    Color iconColor;

    switch (movement.movementType) {
      case 'IMPORT':
        iconData = Icons.add_box;
        iconColor = Colors.green;
        break;
      case 'SALE':
      case 'COMBO_SALE':
        iconData = Icons.shopping_cart_checkout;
        iconColor = Colors.red;
        break;
      case 'ADJUSTMENT':
        iconData = Icons.tune;
        iconColor = Colors.orange;
        break;
      case 'DAMAGE':
        iconData = Icons.broken_image;
        iconColor = Colors.grey;
        break;
      default:
        iconData = Icons.swap_horiz;
        iconColor = Colors.blue;
    }

    return CircleAvatar(
      backgroundColor: iconColor.withOpacity(0.2),
      child: Icon(iconData, color: iconColor),
    );
  }
}
