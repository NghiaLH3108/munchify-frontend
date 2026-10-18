import 'package:flutter/material.dart';
import '../../../../core/theme/ColorPalette.dart';

/// Filter toolbar for staff management:
/// - Search input by name, username, phone
/// - Role pills (Tất cả, Admin, Staff)
/// - Status pills (Hoạt động, Tạm khóa)
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: ColorPalette.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ColorPalette.borderSubtle),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 880;
          return isWide
              ? Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: _buildSearchInputField(),
                    ),
                    const SizedBox(width: 16),
                    _buildPillFilters(),
                  ],
                )
              : Wrap(
                  spacing: 12,
                  runSpacing: 10,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: _buildSearchInputField(),
                    ),
                    _buildPillFilters(),
                  ],
                );
        },
      ),
    );
  }

  Widget _buildSearchInputField() {
    return SizedBox(
      height: 40,
      child: TextField(
        controller: searchController,
        onChanged: onSearchChanged,
        style: const TextStyle(fontSize: 13),
        decoration: InputDecoration(
          hintText: 'Tìm theo họ tên, username, SĐT...',
          hintStyle: const TextStyle(fontSize: 12, color: ColorPalette.textMuted),
          prefixIcon:
              const Icon(Icons.search_rounded, size: 18, color: ColorPalette.textMuted),
          suffixIcon: searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear_rounded, size: 16),
                  onPressed: onClearSearch,
                )
              : null,
          filled: true,
          fillColor: ColorPalette.webBgAdmin.withValues(alpha: 0.6),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(
                color: ColorPalette.appetizingOrange, width: 1.5),
          ),
        ),
      ),
    );
  }

  Widget _buildPillFilters() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        // Role pills
        _buildPillFilter(
          label: 'Tất cả',
          isActive: selectedRole == null && selectedStatus == null,
          onTap: () {
            onRoleChanged(null);
            onStatusChanged(null);
          },
        ),
        _buildPillFilter(
          label: 'Admin',
          isActive: selectedRole == 'ADMIN',
          onTap: () =>
              onRoleChanged(selectedRole == 'ADMIN' ? null : 'ADMIN'),
          icon: Icons.shield_rounded,
        ),
        _buildPillFilter(
          label: 'Staff',
          isActive: selectedRole == 'STAFF',
          onTap: () =>
              onRoleChanged(selectedRole == 'STAFF' ? null : 'STAFF'),
          icon: Icons.badge_rounded,
        ),
        Container(width: 1, height: 24, color: ColorPalette.borderSubtle),
        _buildPillFilter(
          label: 'Hoạt động',
          isActive: selectedStatus == true,
          onTap: () =>
              onStatusChanged(selectedStatus == true ? null : true),
          activeColor: ColorPalette.success,
        ),
        _buildPillFilter(
          label: 'Tạm khóa',
          isActive: selectedStatus == false,
          onTap: () =>
              onStatusChanged(selectedStatus == false ? null : false),
          activeColor: ColorPalette.error,
        ),
      ],
    );
  }

  Widget _buildPillFilter({
    required String label,
    required bool isActive,
    required VoidCallback onTap,
    IconData? icon,
    Color? activeColor,
  }) {
    final color = activeColor ?? ColorPalette.appetizingOrange;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isActive ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? color : ColorPalette.borderSubtle,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon,
                  size: 14,
                  color: isActive ? Colors.white : ColorPalette.textMuted),
              const SizedBox(width: 5),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isActive ? Colors.white : ColorPalette.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
