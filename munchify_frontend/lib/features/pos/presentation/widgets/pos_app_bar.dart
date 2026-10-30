import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/ColorPalette.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../auth/presentation/screens/login_screen.dart';
import '../../../inventory/presentation/screens/staff_damage_report_screen.dart';
import '../../../admin/presentation/pages/admin_shell_screen.dart';

/// AppBar của màn hình POS Home: logo, trạng thái quầy, hiển thị thông tin thu ngân và đăng xuất.
class PosAppBar extends StatelessWidget implements PreferredSizeWidget {
  const PosAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  void _showLogoutConfirmDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Row(
          children: [
            Icon(Icons.logout_rounded, color: ColorPalette.error),
            SizedBox(width: 8),
            Text('Xác nhận đăng xuất', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text(
          'Bạn có chắc chắn muốn đăng xuất khỏi ca làm việc hiện tại không?',
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Hủy', style: TextStyle(color: ColorPalette.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<AuthBloc>().add(const LogoutRequestedEvent());
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorPalette.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );
  }

  String _getInitials(String fullName) {
    final words = fullName.trim().split(' ').where((w) => w.isNotEmpty).toList();
    if (words.isEmpty) return 'NV';
    if (words.length == 1) return words[0].substring(0, words[0].length >= 2 ? 2 : 1).toUpperCase();
    return '${words.first[0]}${words.last[0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: ColorPalette.surface,
      elevation: 0,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: ColorPalette.appetizingOrange,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.restaurant, color: ColorPalette.onPrimary),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Munchify POS',
                style: TextStyle(
                  color: ColorPalette.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: ColorPalette.success,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'Trực tuyến • Quầy thu ngân #01',
                    style: TextStyle(color: ColorPalette.textHint, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      actions: [
        // Nút truy cập giao diện App Staff Báo cáo hàng hỏng / hư / hết hạn
        IconButton(
          tooltip: 'Báo cáo hàng hỏng / hết hạn',
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3E0),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFFFCC80)),
            ),
            child: const Icon(
              Icons.report_problem_outlined,
              color: ColorPalette.appetizingOrange,
              size: 20,
            ),
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const StaffDamageReportScreen(),
              ),
            );
          },
        ),

        // User Cashier Profile & Logout Menu
        BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            String displayName = 'Thu ngân';
            String roleName = 'Nhân viên';
            String initials = 'TN';

            if (state is Authenticated) {
              displayName = state.user.fullName.isNotEmpty
                  ? state.user.fullName
                  : state.user.username;
              roleName = state.user.isAdmin ? 'Quản trị viên' : 'Thu ngân';
              initials = _getInitials(displayName);
            }

            return PopupMenuButton<String>(
              tooltip: 'Tài khoản thu ngân',
              offset: const Offset(0, 48),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              onSelected: (value) {
                if (value == 'admin_console') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AdminShellScreen(initialTab: 'reports'),
                    ),
                  );
                } else if (value == 'logout') {
                  _showLogoutConfirmDialog(context);
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem<String>(
                  enabled: false,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayName,
                        style: const TextStyle(
                          color: ColorPalette.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        roleName,
                        style: const TextStyle(
                          color: ColorPalette.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const PopupMenuDivider(),
                if (state is Authenticated && state.user.isAdmin) ...[
                  const PopupMenuItem<String>(
                    value: 'admin_console',
                    child: Row(
                      children: [
                        Icon(
                          Icons.admin_panel_settings_outlined,
                          color: ColorPalette.textPrimary,
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Trang Quản trị Admin',
                          style: TextStyle(
                            color: ColorPalette.textPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const PopupMenuDivider(),
                ],
                const PopupMenuItem<String>(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(Icons.logout_rounded, color: ColorPalette.error, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Đăng xuất ca làm',
                        style: TextStyle(
                          color: ColorPalette.error,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              child: Container(
                margin: const EdgeInsets.only(left: 4, right: 16, top: 10, bottom: 10),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 12,
                      backgroundColor: ColorPalette.appetizingOrange,
                      child: Text(
                        initials,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      displayName,
                      style: const TextStyle(
                        color: ColorPalette.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    const Icon(Icons.arrow_drop_down, color: ColorPalette.textPrimary),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
