import 'package:flutter/material.dart';

import '../../../../core/theme/ColorPalette.dart';
import '../../../../core/theme/AppTypography.dart';
import '../../../staff/presentation/pages/staff_management_screen.dart';
import '../../../categories/presentation/screens/manage_categories_screen.dart';
import '../../../products/presentation/screens/product_management_screen.dart';
import '../widgets/analytics_dashboard_view.dart';
import '../../../inventory/presentation/screens/inventory_screen.dart';
import '../../../units/presentation/screens/manage_units_screen.dart';
import '../../../combos/presentation/screens/manage_combos_screen.dart';
import '../../../customers/presentation/screens/admin_customer_management_screen.dart';
import '../../../inventory/presentation/screens/low_stock_screen.dart';
import '../../../inventory/presentation/screens/ai_expiry_screen.dart';
import '../../../reports/presentation/screens/reports_screen.dart';
import '../../../../core/services/signalr_service.dart';


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
  String _selectedDateRange = 'today';
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(child: Text(message)),
            ],
          ),
          backgroundColor: Colors.redAccent,
          duration: const Duration(seconds: 5),
          behavior: SnackBarBehavior.floating,
        ),
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
      case 'inventory':
        return 'Quản lý Kho & Nhập';
      case 'ai_low_stock':
        return 'AI Cảnh Báo Cạn Kho';
      case 'ai_expiry':
        return 'AI Hàng Hỏng/Hết Hạn';
      case 'cashbook':
        return 'Sổ quỹ & Biến động';
      case 'loyalty':
        return 'Khách hàng thân thiết';
      case 'promotions':
        return 'Khuyến mãi';
      case 'units':
        return 'Đơn vị tính';
      case 'staff':
        return 'Nhân viên & Quyền';
      case 'reports':
        return 'Báo cáo & Thống kê';
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
                  const SizedBox(height: 10),
                  // Quick POS Trigger CTA Button
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Chức năng Bán hàng tại quầy (POS) sẵn sàng mở.',
                            ),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                      icon: const Icon(Icons.point_of_sale_rounded, size: 20),
                      label: const Text('+ Tạo đơn POS'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorPalette.primaryContainer,
                        foregroundColor: Colors.white,
                        elevation: 1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        textStyle: AppTypography.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Navigation Links
                  _buildSidebarItem(
                    key: 'dashboard',
                    icon: Icons.dashboard_rounded,
                    title: 'Dashboard',
                  ),
                  _buildSidebarItem(
                    key: 'orders',
                    icon: Icons.receipt_long_rounded,
                    title: 'Đơn hàng',
                    badge: '12 mới',
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
                    key: 'inventory',
                    icon: Icons.inventory_2_rounded,
                    title: 'Quản lý Kho & Nhập',
                  ),
                  _buildSidebarItem(
                    key: 'ai_low_stock',
                    icon: Icons.warning_amber_rounded,
                    title: 'AI Cảnh Báo Cạn Kho',
                    badge: 'Mới',
                    badgeColor: ColorPalette.dangerCrimson,
                  ),
                  _buildSidebarItem(
                    key: 'ai_expiry',
                    icon: Icons.auto_awesome_rounded,
                    title: 'AI Hàng Hỏng/Hết Hạn',
                    badge: 'Mới',
                    badgeColor: ColorPalette.dangerCrimson,
                  ),
                  _buildSidebarItem(
                    key: 'cashbook',
                    icon: Icons.account_balance_wallet_rounded,
                    title: 'Sổ quỹ & Biến động',
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
                    badge: 'Đang chạy: 2',
                    badgeColor: const Color(0xFF663E00),
                    badgeBorder: const Color(0xFFFDA625),
                  ),
                  _buildSidebarItem(
                    key: 'staff',
                    icon: Icons.badge_rounded,
                    title: 'Nhân viên & Quyền',
                  ),
                  _buildSidebarItem(
                    key: 'reports',
                    icon: Icons.analytics_rounded,
                    title: 'Báo cáo & Thống kê',
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
                                'CN Quận 1 - Hồ Chí Minh',
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
          // Left Cluster: Breadcrumbs & Global Search
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
          const SizedBox(width: 20),
          // Global Search Bar
          if (isDesktop)
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 220),
              child: Container(
                height: 38,
                decoration: BoxDecoration(
                  color: ColorPalette.webBgAdmin.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: ColorPalette.borderSubtle),
                ),
                child: Row(
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Icon(
                        Icons.search_rounded,
                        size: 18,
                        color: ColorPalette.textMuted,
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        style: AppTypography.inter(
                          fontSize: 12,
                          color: ColorPalette.onSurfaceDark,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Tìm nhanh... (Ctrl+K)',
                          hintStyle: AppTypography.inter(
                            fontSize: 12,
                            color: ColorPalette.textMuted,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.only(bottom: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const Spacer(),
          // Right Cluster: Outlet Selector, Date Range, Export, Notifications, Profile
          Flexible(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              reverse: true,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isDesktop) ...[
                    // Outlet Chip
                    Container(
                      height: 36,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: ColorPalette.surfaceWhite,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: ColorPalette.borderSubtle),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.apartment_rounded,
                            size: 16,
                            color: ColorPalette.primaryContainer,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Tất cả chi nhánh',
                            style: AppTypography.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: ColorPalette.onSurfaceDark,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            size: 16,
                            color: ColorPalette.textMuted,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Date Range Selector Pill
                    Container(
                      height: 36,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: ColorPalette.surfaceWhite,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: ColorPalette.borderSubtle),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.calendar_today_rounded,
                            size: 13,
                            color: ColorPalette.secondary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '21/09/2026',
                            style: AppTypography.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: ColorPalette.onSurfaceDark,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            width: 1,
                            height: 14,
                            color: ColorPalette.borderSubtle,
                          ),
                          const SizedBox(width: 4),
                          _buildDateSubPill('today', 'Hôm nay'),
                          _buildDateSubPill('7days', '7 ngày'),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Export CTA
                    OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.ios_share_rounded,
                        size: 14,
                        color: ColorPalette.tertiary,
                      ),
                      label: const Text('Xuất Excel'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: ColorPalette.onSurfaceDark,
                        side: const BorderSide(
                          color: ColorPalette.borderSubtle,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        textStyle: AppTypography.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 1,
                      height: 20,
                      color: ColorPalette.borderSubtle,
                    ),
                    const SizedBox(width: 4),
                  ],
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
                  const SizedBox(width: 6),
                  // Admin Profile Avatar & Name
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 17,
                        backgroundColor: ColorPalette.surfaceContainerHigh,
                        child: Text(
                          'HM',
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
                              'Hoàng Minh',
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
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSubPill(String key, String label) {
    final isSelected = _selectedDateRange == key;
    return InkWell(
      onTap: () => setState(() => _selectedDateRange = key),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: isSelected ? ColorPalette.primaryFixed : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: AppTypography.inter(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected
                ? ColorPalette.primaryContainer
                : ColorPalette.textMuted,
          ),
        ),
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
      case 'products':
        return const ProductManagementScreen();
      case 'menu':
        return const ManageCategoriesScreen(embedInShell: true);
      case 'units':
        return const ManageUnitsScreen(embedInShell: true);
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
      case 'reports':
        return const ReportsScreen(embedInShell: true);
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
                ElevatedButton(
                  onPressed: () => _onTabSelected('staff'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorPalette.primaryContainer,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Quay lại Quản lý Nhân viên'),
                ),
              ],
            ),
          ),
        );
    }
  }
}
