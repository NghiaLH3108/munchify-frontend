import 'package:flutter/material.dart';
import '../../../../core/widgets/admin/admin_widgets.dart';

class PromotionFilterBar extends StatelessWidget {
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final bool? selectedStatus;
  final ValueChanged<bool?> onStatusChanged;
  final String? selectedDiscountType;
  final ValueChanged<String?> onDiscountTypeChanged;
  final VoidCallback onReset;

  const PromotionFilterBar({
    super.key,
    required this.searchController,
    required this.onSearchChanged,
    required this.selectedStatus,
    required this.onStatusChanged,
    required this.selectedDiscountType,
    required this.onDiscountTypeChanged,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return AdminFilterBar(
      searchController: searchController,
      searchHint: 'Tìm theo mã hoặc tên khuyến mãi...',
      onSearchChanged: onSearchChanged,
      filters: [
        AdminDropdownFilter<bool?>(
          value: selectedStatus,
          items: const [
            DropdownMenuItem(value: null, child: Text('Tất cả trạng thái')),
            DropdownMenuItem(value: true, child: Text('Đang hoạt động')),
            DropdownMenuItem(value: false, child: Text('Đã tạm dừng')),
          ],
          onChanged: onStatusChanged,
        ),
        AdminDropdownFilter<String?>(
          value: selectedDiscountType,
          items: const [
            DropdownMenuItem(value: null, child: Text('Tất cả hình thức')),
            DropdownMenuItem(value: 'PERCENTAGE', child: Text('Giảm theo %')),
            DropdownMenuItem(value: 'FIXED_AMOUNT', child: Text('Giảm tiền mặt (₫)')),
          ],
          onChanged: onDiscountTypeChanged,
        ),
      ],
      trailingActions: [
        IconButton(
          onPressed: onReset,
          icon: const Icon(Icons.restart_alt_rounded, color: Color(0xFF64748B)),
          tooltip: 'Đặt lại bộ lọc',
        ),
      ],
    );
  }
}
