import 'package:flutter/material.dart';
import '../../../../core/widgets/admin/admin_widgets.dart';

/// Filter toolbar for staff management using shared [AdminFilterBar] & [AdminDropdownFilter]:
/// - Search input by name, username, phone
/// - Role dropdown filter (Tất cả vai trò, Admin, Staff)
/// - Status dropdown filter (Tất cả trạng thái, Hoạt động, Tạm khóa)
class StaffFilterBar extends StatelessWidget {
  final TextEditingController searchController;
  final String searchQuery;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onClearSearch;
  final String? selectedRole;
  final ValueChanged<String?> onRoleChanged;
  final bool? selectedStatus;
  final ValueChanged<bool?> onStatusChanged;

  const StaffFilterBar({
    super.key,
    required this.searchController,
    required this.searchQuery,
    required this.onSearchChanged,
    required this.onClearSearch,
    required this.selectedRole,
    required this.onRoleChanged,
    required this.selectedStatus,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    return AdminFilterBar(
      searchController: searchController,
      searchHint: 'Tìm theo họ tên, username, SĐT...',
      onSearchChanged: onSearchChanged,
      onClearSearch: onClearSearch,
      filters: [
        AdminDropdownFilter<String?>(
          value: selectedRole,
          items: const [
            DropdownMenuItem(value: null, child: Text('Tất cả vai trò')),
            DropdownMenuItem(value: 'ADMIN', child: Text('Quản trị viên (Admin)')),
            DropdownMenuItem(value: 'STAFF', child: Text('Nhân viên (Staff)')),
          ],
          onChanged: onRoleChanged,
        ),
        AdminDropdownFilter<bool?>(
          value: selectedStatus,
          items: const [
            DropdownMenuItem(value: null, child: Text('Tất cả trạng thái')),
            DropdownMenuItem(value: true, child: Text('Đang hoạt động')),
            DropdownMenuItem(value: false, child: Text('Tạm khóa')),
          ],
          onChanged: onStatusChanged,
        ),
      ],
    );
  }
}
