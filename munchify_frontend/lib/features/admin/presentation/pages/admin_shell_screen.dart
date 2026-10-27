import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/ColorPalette.dart';
import '../../../../core/theme/AppTypography.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../auth/presentation/screens/login_screen.dart';
import '../../../staff/presentation/pages/staff_management_screen.dart';
import '../../../categories/presentation/screens/manage_categories_screen.dart';
import '../../../suppliers/presentation/screens/manage_suppliers_screen.dart';
import '../../../products/presentation/screens/product_management_screen.dart';
import '../widgets/analytics_dashboard_view.dart';
import '../../../inventory/presentation/screens/inventory_screen.dart';
import '../../../units/presentation/screens/manage_units_screen.dart';
import '../../../combos/presentation/screens/manage_combos_screen.dart';
import '../../../customers/presentation/screens/admin_customer_management_screen.dart';
import '../../../inventory/presentation/screens/low_stock_screen.dart';
import '../../../inventory/presentation/screens/ai_expiry_screen.dart';
import '../../../promotions/presentation/pages/promotion_management_screen.dart';
import '../../../orders/presentation/screens/admin_order_inquiry_screen.dart';
import '../../../main/presentation/screens/main_app_screen.dart';
import '../../../../core/services/signalr_service.dart';
import '../../../../core/widgets/app_toast.dart';

/// Admin Shell Screen that hosts the full Munchify POS Web Admin interface
/// matching the HTML mockup (Sidebar + Sticky Top Navbar + View Switcher).
class AdminShellScreen extends StatefulWidget {
  final String initialTab;
  const AdminShellScreen({super.key, this.initialTab = 'staff'});

  @override
  State<AdminShellScreen> createState() => _AdminShellScreenState();
}

class _AdminShellScreenState extends State<AdminShellScreen> {
  late String _currentTab;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _showLogoutConfirmDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Row(
          children: [
            Icon(Icons.logout_rounded, color: ColorPalette.error),
            SizedBox(width: 8),
            Text(
              'Xác nhận đăng xuất',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: const Text(
          'Bạn có chắc chắn muốn đăng xuất khỏi trang Quản trị không?',
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text(
              'Hủy',
              style: TextStyle(color: ColorPalette.textSecondary),
            ),
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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );
  }

  String _getInitials(String fullName) {
    final words = fullName
        .trim()
        .split(' ')
        .where((w) => w.isNotEmpty)
        .toList();
    if (words.isEmpty) return 'HM';
    if (words.length == 1)
      return words[0].substring(0, words[0].length >= 2 ? 2 : 1).toUpperCase();
    return '${words.first[0]}${words.last[0]}'.toUpperCase();
  }

  @override
  void initState() {
    super.initState();
    _currentTab = widget.initialTab;
    signalRService.onLowStockWarning(_onAiAlertReceived);
    signalRService.onExpiryAlert(_onAiAlertReceived);
  }

  @override
  void dispose() {
    signalRService.removeLowStockWarningListener(_onAiAlertReceived);
    signalRService.removeExpiryAlertListener(_onAiAlertReceived);
    super.dispose();
  }

  void _onAiAlertReceived(String message) {
    if (mounted) {
      AppToast.warning(
        message,
        context: context,
        duration: const Duration(seconds: 5),
      );
    }
  }

  void _onTabSelected(String tabKey) {
    setState(() {
      _currentTab = tabKey;
    });
  }

  String get _currentTabTitle {
    switch (_currentTab) {
      case 'dashboard':
        return 'Báo cáo tổng quan';
      case 'orders':
        return 'Đơn hàng';
      case 'products':
        return 'Thực đơn & Sản phẩm';
      case 'menu':
        return 'Danh mục';
      case 'combos':
        return 'Combo sản phẩm';
      case 'suppliers':
        return 'Nhà cung cấp';
      case 'inventory':
        return 'Quản lý Kho & Nhập';
      case 'ai_low_stock':
        return 'AI Cảnh Báo Cạn Kho';
      case 'ai_expiry':
        return 'AI Hàng Hỏng/Hết Hạn';
      case 'loyalty':
        return 'Khách hàng thân thiết';
      case 'promotions':
        return 'Khuyến mãi';
      case 'units':
        return 'Đơn vị tính';
      case 'staff':
        return 'Nhân viên & Quyền';
      default:
        return 'Báo cáo tổng quan';
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 1000;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: ColorPalette.webBgAdmin,
      drawer: !isDesktop
          ? Drawer(
              backgroundColor: ColorPalette.inverseSurface,
              child: _buildSidebarContent(),
            )
          : null,
      body: SafeArea(
        child: Row(
          children: [
            // Fixed Left Sidebar for Desktop
            if (isDesktop) SizedBox(width: 256, child: _buildSidebarContent()),
            // Main Canvas Area
            Expanded(
              child: Column(
                children: [
                  _buildTopStickyHeader(context, isDesktop),
                  Expanded(child: _buildActiveView()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 1. LEFT NAVIGATION SIDEBAR
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildSidebarContent() {
    return Container(
      color: ColorPalette.inverseSurface,
      child: Column(
        children: [
          // Scrollable upper nav
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Brand Header
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8.0,
                      vertical: 8.0,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: ColorPalette.primaryContainer,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.lunch_dining_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'Munchify POS',
                                    style: AppTypography.plusJakarta(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: ColorPalette.surfaceWhite,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF4ADE80),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Admin Console',
                                style: AppTypography.inter(
                                  fontSize: 11,
                                  color: ColorPalette.surfaceDim,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Store Open Status Card
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: ColorPalette.borderSubtle.withValues(
                          alpha: 0.15,
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 7,
                              height: 7,
                              decoration: const BoxDecoration(
                                color: Color(0xFF34D399),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Đang mở',
                              style: AppTypography.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: ColorPalette.surfaceWhite,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          'Ca sáng: #CA01',
                          style: AppTypography.inter(
                            fontSize: 10,
                            color: ColorPalette.surfaceDim,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 26),
                  // Navigation Links
                  _buildSidebarItem(
                    key: 'dashboard',
                    icon: Icons.dashboard_rounded,
                    title: 'Báo cáo tổng quan',
                  ),
                  _buildSidebarItem(
                    key: 'orders',
                    icon: Icons.receipt_long_rounded,
                    title: 'Đơn hàng',
                    badgeColor: ColorPalette.primaryContainer,
                  ),
                  _buildSidebarItem(
                    key: 'products',
                    icon: Icons.fastfood_rounded,
                    title: 'Thực đơn & Sản phẩm',
                  ),
                  _buildSidebarItem(
                    key: 'menu',
                    icon: Icons.restaurant_menu_rounded,
                    title: 'Danh mục',
                  ),
                  _buildSidebarItem(
                    key: 'units',
                    icon: Icons.straighten_rounded,
                    title: 'Đơn vị tính',
                  ),
                  _buildSidebarItem(
                    key: 'combos',
                    icon: Icons.lunch_dining_rounded,
                    title: 'Combo sản phẩm',
                  ),
                  _buildSidebarItem(
                    key: 'suppliers',
                    icon: Icons.local_shipping_rounded,
                    title: 'Nhà cung cấp',
                  ),
                  _buildSidebarItem(
                    key: 'inventory',
                    icon: Icons.inventory_2_rounded,
                    title: 'Quản lý Kho & Nhập',
                  ),
                  _buildSidebarItem(
                    key: 'ai_low_stock',
                    icon: Icons.warning_amber_rounded,
                    title: 'AI Cảnh Báo Cạn Kho',
                    badgeColor: ColorPalette.dangerCrimson,
                  ),
                  _buildSidebarItem(
                    key: 'ai_expiry',
                    icon: Icons.auto_awesome_rounded,
                    title: 'AI Hàng Hỏng/Hết Hạn',
                    badgeColor: ColorPalette.dangerCrimson,
                  ),
                  _buildSidebarItem(
                    key: 'loyalty',
                    icon: Icons.loyalty_rounded,
                    title: 'Khách hàng thân thiết',
                  ),
                  _buildSidebarItem(
                    key: 'promotions',
                    icon: Icons.campaign_rounded,
                    title: 'Khuyến mãi',
                  ),
                  _buildSidebarItem(
                    key: 'staff',
                    icon: Icons.badge_rounded,
                    title: 'Nhân viên & Quyền',
                  ),
                ],
              ),
            ),
          ),
          // Sidebar Footer Group
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: ColorPalette.borderSubtle.withValues(alpha: 0.15),
                ),
              ),
            ),
            child: Column(
              children: [
                // Branch Switcher Card
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: ColorPalette.borderSubtle.withValues(alpha: 0.1),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.storefront_rounded,
                            size: 20,
                            color: ColorPalette.primaryLight,
                          ),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'CHI NHÁNH HIỆN TẠI',
                                style: AppTypography.inter(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  color: ColorPalette.surfaceDim,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              Text(
                                'Chi nhánh 1',
                                style: AppTypography.inter(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: ColorPalette.surfaceWhite,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const Icon(
                        Icons.unfold_more_rounded,
                        size: 16,
                        color: ColorPalette.surfaceDim,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                // Secondary Settings Links
                _buildSidebarFooterLink(
                  Icons.settings_outlined,
                  'Cài đặt cửa hàng',
                ),
                const SizedBox(height: 4),
                _buildSidebarFooterLink(
                  Icons.help_outline_rounded,
                  'Trợ giúp & HDSD',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarItem({
    required String key,
    required IconData icon,
    required String title,
    String? badge,
    Color? badgeColor,
    Color? badgeBorder,
  }) {
    final isSelected = _currentTab == key;

    return Padding(
      padding: const EdgeInsets.only(bottom: 3.0),
      child: InkWell(
        onTap: () {
          _onTabSelected(key);
          if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
            Navigator.of(context).pop();
          }
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? ColorPalette.primaryContainer
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected ? Colors.white : ColorPalette.surfaceDim,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: AppTypography.inter(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? Colors.white : ColorPalette.surfaceDim,
                  ),
                ),
              ),
              if (badge != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: badgeColor ?? ColorPalette.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                    border: badgeBorder != null
                        ? Border.all(color: badgeBorder)
                        : null,
                  ),
                  child: Text(
                    badge,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
              if (isSelected && badge == null) ...[
                Icon(
                  Icons.chevron_right_rounded,
                  size: 16,
                  color: Colors.white.withValues(alpha: 0.7),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSidebarFooterLink(IconData icon, String label) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Row(
          children: [
            Icon(icon, size: 16, color: ColorPalette.surfaceDim),
            const SizedBox(width: 10),
            Text(
              label,
              style: AppTypography.inter(
                fontSize: 12,
                color: ColorPalette.surfaceDim,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 2. TOP STICKY HEADER
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildTopStickyHeader(BuildContext context, bool isDesktop) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        color: ColorPalette.surfaceWhite,
        border: Border(bottom: BorderSide(color: ColorPalette.borderSubtle)),
        boxShadow: [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          // Drawer toggle button on tablet/mobile
          if (!isDesktop) ...[
            IconButton(
              icon: const Icon(
                Icons.menu_rounded,
                color: ColorPalette.onSurfaceDark,
              ),
              onPressed: () => _scaffoldKey.currentState?.openDrawer(),
            ),
            const SizedBox(width: 8),
          ],
          // Left Cluster: Breadcrumbs
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Trang chủ',
                style: AppTypography.inter(
                  fontSize: 12,
                  color: ColorPalette.textMuted,
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 6),
                child: Text(
                  '/',
                  style: TextStyle(
                    color: ColorPalette.borderSubtle,
                    fontSize: 13,
                  ),
                ),
              ),
              Text(
                _currentTabTitle,
                style: AppTypography.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: ColorPalette.onSurfaceDark,
                ),
              ),
            ],
          ),
          const Spacer(),
          // Right Cluster: Notifications & Profile
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Notification Bell with Red Badge
              Stack(
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.notifications_outlined,
                      size: 22,
                      color: ColorPalette.textMuted,
                    ),
                    tooltip: 'Thông báo',
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: const BoxDecoration(
                        color: ColorPalette.dangerCrimson,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        '2',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              // Admin Profile Avatar & Name with Logout Menu
              BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  String displayName = 'Hoàng Minh';
                  String initials = 'HM';

                  if (state is Authenticated) {
                    displayName = state.user.fullName.isNotEmpty
                        ? state.user.fullName
                        : state.user.username;
                    initials = _getInitials(displayName);
                  }

                  return PopupMenuButton<String>(
                    tooltip: 'Tài khoản quản trị',
                    offset: const Offset(0, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    onSelected: (value) {
                      if (value == 'pos') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const MainAppScreen(),
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
                                color: ColorPalette.onSurfaceDark,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              'Quản trị viên (Admin)',
                              style: TextStyle(
                                color: ColorPalette.primaryContainer,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const PopupMenuDivider(),
                      const PopupMenuItem<String>(
                        value: 'pos',
                        child: Row(
                          children: [
                            Icon(
                              Icons.storefront_rounded,
                              color: ColorPalette.onSurfaceDark,
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Đến Quầy bán hàng (POS)',
                              style: TextStyle(
                                color: ColorPalette.onSurfaceDark,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const PopupMenuDivider(),
                      const PopupMenuItem<String>(
                        value: 'logout',
                        child: Row(
                          children: [
                            Icon(
                              Icons.logout_rounded,
                              color: ColorPalette.error,
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Đăng xuất tài khoản',
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
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircleAvatar(
                            radius: 17,
                            backgroundColor: ColorPalette.surfaceContainerHigh,
                            child: Text(
                              initials,
                              style: AppTypography.plusJakarta(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: ColorPalette.primaryContainer,
                              ),
                            ),
                          ),
                          if (isDesktop) ...[
                            const SizedBox(width: 8),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  displayName,
                                  style: AppTypography.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: ColorPalette.onSurfaceDark,
                                  ),
                                ),
                                Text(
                                  'Quản trị viên (Admin)',
                                  style: AppTypography.inter(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                    color: ColorPalette.primaryContainer,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.keyboard_arrow_down_rounded,
                              size: 16,
                              color: ColorPalette.textMuted,
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 3. ACTIVE VIEW CONTAINER
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildActiveView() {
    switch (_currentTab) {
      case 'dashboard':
        return const AnalyticsDashboardView();
      case 'orders':
        return const AdminOrderInquiryScreen(embedInShell: true);
      case 'products':
        return const ProductManagementScreen();
      case 'menu':
        return const ManageCategoriesScreen(embedInShell: true);
      case 'units':
        return const ManageUnitsScreen(embedInShell: true);
      case 'suppliers':
        return const ManageSuppliersScreen(embedInShell: true);
      case 'staff':
        return const StaffManagementScreen(embedInShell: true);
      case 'combos':
        return const ManageCombosScreen(embedInShell: true);
      case 'inventory':
        return const InventoryScreen(embedInShell: true);
      case 'loyalty':
        return const AdminCustomerManagementScreen(embedInShell: true);
      case 'ai_low_stock':
        return const LowStockScreen(embedInShell: true);
      case 'ai_expiry':
        return const AiExpiryScreen(embedInShell: true);
      case 'promotions':
        return const PromotionManagementScreen(embedInShell: true);
      default:
        // Placeholder for other tabs with clean informative card
        return Center(
          child: Container(
            margin: const EdgeInsets.all(32),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: ColorPalette.surfaceWhite,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: ColorPalette.borderSubtle),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: ColorPalette.primaryFixed.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.construction_rounded,
                    size: 36,
                    color: ColorPalette.primaryContainer,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  _currentTabTitle,
                  style: AppTypography.plusJakarta(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Phân hệ này đang được hoàn thiện theo lộ trình sprint tiếp theo.',
                  style: AppTypography.inter(
                    fontSize: 13,
                    color: ColorPalette.textMuted,
                  ),
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  alignment: WrapAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () => _onTabSelected('dashboard'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorPalette.primaryContainer,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Quay lại Dashboard'),
                    ),
                    OutlinedButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const MainAppScreen(),
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Đến Quầy bán hàng (POS)'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
    }
  }
}
