import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/ColorPalette.dart';
import '../../../../core/theme/AppTypography.dart';
import '../../../../core/widgets/app_pagination_bar.dart';
import '../../domain/entities/customer_entity.dart';
import '../bloc/admin_customer_bloc.dart';
import '../bloc/admin_customer_event.dart';
import '../bloc/admin_customer_state.dart';
import '../widgets/customer_points_history_modal.dart';
import '../../../../core/widgets/app_toast.dart';

class AdminCustomerManagementScreen extends StatefulWidget {
  final bool embedInShell;
  const AdminCustomerManagementScreen({super.key, this.embedInShell = false});

  @override
  State<AdminCustomerManagementScreen> createState() =>
      _AdminCustomerManagementScreenState();
}

class _AdminCustomerManagementScreenState
    extends State<AdminCustomerManagementScreen> {
  int _currentPage = 1;
  static const int _pageSize = 10;
  String _searchQuery = '';
  bool? _selectedHasPoints; // null = all, true > 0, false == 0
  bool _isCardView = false;
  String _lastSyncedTime = 'Vừa cập nhật';

  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _updateSyncTime();
    _loadData();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _updateSyncTime() {
    final now = DateTime.now();
    _lastSyncedTime = DateFormat('HH:mm:ss').format(now);
  }

  void _loadData() {
    _updateSyncTime();
    context.read<AdminCustomerBloc>().add(
          LoadAdminCustomers(
            pageIndex: _currentPage,
            pageSize: _pageSize,
            searchKeyword: _searchQuery.isNotEmpty ? _searchQuery : null,
          ),
        );
  }

  void _onPointsFilterChanged(bool? hasPoints) {
    setState(() {
      _selectedHasPoints = hasPoints;
    });
  }

  String _getInitials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts[0].isEmpty) return '?';
    if (parts.length == 1) {
      return parts[0].substring(0, math.min(2, parts[0].length)).toUpperCase();
    }
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }

  void _openHistoryModal(BuildContext context, CustomerEntity customer) {
    showDialog(
      context: context,
      builder: (ctx) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: context.read<AdminCustomerBloc>()),
        ],
        child: CustomerPointsHistoryModal(customer: customer),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bodyContent = BlocConsumer<AdminCustomerBloc, AdminCustomerState>(
      listener: (context, state) {
        if (state is AdminCustomerError) {
          AppToast.error(state.message, context: context);
        }
      },
      buildWhen: (previous, current) =>
          current is AdminCustomerLoading ||
          current is AdminCustomersLoaded ||
          current is AdminCustomerError,
      builder: (context, state) {
        if (state is AdminCustomerLoading) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  width: 40,
                  height: 40,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    color: ColorPalette.appetizingOrange,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Đang đồng bộ danh sách khách hàng...',
                  style: AppTypography.dashboardSubtitle,
                ),
              ],
            ),
          );
        } else if (state is AdminCustomerError) {
          return _buildErrorState(state.message);
        } else if (state is AdminCustomersLoaded) {
          final allItems = state.customersData.items;
          final kpiItems = state.kpiCustomers ?? allItems;
          final kpiTotal = state.kpiTotalCount ?? state.customersData.totalCount;

          // Client-side filtering for points (Có điểm / Chưa có điểm)
          final filteredItems = allItems.where((customer) {
            if (_selectedHasPoints == true && customer.loyaltyPoints <= 0) {
              return false;
            }
            if (_selectedHasPoints == false && customer.loyaltyPoints > 0) {
              return false;
            }
            return true;
          }).toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildPageTitleBar(context),
                const SizedBox(height: 20),
                _buildKpiMetrics(kpiItems, kpiTotal),
                const SizedBox(height: 24),
                _buildCustomerTableCard(
                  context,
                  filteredItems,
                  state.customersData.totalPages,
                  state.customersData.totalCount,
                  isRefreshing: state.isRefreshing,
                ),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );

    if (widget.embedInShell) {
      return bodyContent;
    }

    return Scaffold(
      backgroundColor: ColorPalette.webBgAdmin,
      body: SafeArea(
        child: Column(
          children: [
            _buildStickyHeader(context),
            Expanded(child: bodyContent),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // STICKY HEADER (when opened standalone, matching admin shell header)
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildStickyHeader(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      decoration: BoxDecoration(
        color: ColorPalette.surface,
        border: const Border(bottom: BorderSide(color: ColorPalette.borderSubtle)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 950;
          final isVeryNarrow = constraints.maxWidth < 650;

          return Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: ColorPalette.appetizingOrange.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.loyalty_rounded,
                    color: ColorPalette.appetizingOrange, size: 22),
              ),
              const SizedBox(width: 12),
              const Text(
                'Munchify POS',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: ColorPalette.warmDarkGrey,
                ),
              ),
              if (!isNarrow) ...[
                const SizedBox(width: 10),
                Row(
                  children: [
                    const Icon(Icons.chevron_right_rounded,
                        size: 18, color: ColorPalette.textMuted),
                    const SizedBox(width: 4),
                    Text('Trang chủ',
                        style: AppTypography.labelSmall.copyWith(
                          color: ColorPalette.textMuted,
                          decoration: TextDecoration.none,
                        )),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 6),
                      child: Text('/',
                          style: TextStyle(
                              color: ColorPalette.textMuted, fontSize: 12)),
                    ),
                    Text('Khách hàng thân thiết',
                        style: AppTypography.labelSmall.copyWith(
                          color: ColorPalette.textPrimary,
                          fontWeight: FontWeight.w700,
                        )),
                  ],
                ),
              ],
              const Spacer(),
              Flexible(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  reverse: true,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!isNarrow) ...[
                        SizedBox(
                          width: 240,
                          height: 38,
                          child: TextField(
                            style: const TextStyle(fontSize: 13),
                            decoration: InputDecoration(
                              hintText: 'Tìm nhanh... (Ctrl+K)',
                              hintStyle: const TextStyle(
                                  fontSize: 12, color: ColorPalette.textMuted),
                              prefixIcon: const Icon(Icons.search_rounded,
                                  size: 18, color: ColorPalette.textMuted),
                              filled: true,
                              fillColor:
                                  ColorPalette.webBgAdmin.withValues(alpha: 0.7),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 8),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                    color: ColorPalette.borderSubtle),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                    color: ColorPalette.borderSubtle),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                    color: ColorPalette.appetizingOrange,
                                    width: 1.5),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                      if (!isVeryNarrow) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: ColorPalette.success.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 7,
                                height: 7,
                                decoration: const BoxDecoration(
                                    color: ColorPalette.success,
                                    shape: BoxShape.circle),
                              ),
                              const SizedBox(width: 6),
                              const Text('Online',
                                  style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: ColorPalette.success)),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                      ],
                      IconButton(
                        onPressed: _loadData,
                        icon: const Icon(Icons.refresh_rounded,
                            size: 20, color: ColorPalette.textMuted),
                        tooltip: 'Tải lại danh sách',
                        style: IconButton.styleFrom(
                          backgroundColor: ColorPalette.webBgAdmin,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          border: Border.all(color: ColorPalette.borderSubtle),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            const CircleAvatar(
                              radius: 14,
                              backgroundColor: ColorPalette.surfaceContainerHigh,
                              child: Text('HM',
                                  style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: ColorPalette.appetizingOrange)),
                            ),
                            if (!isVeryNarrow) ...[
                              const SizedBox(width: 8),
                              const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Hoàng Minh',
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: ColorPalette.textPrimary)),
                                  Text('Admin',
                                      style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w500,
                                          color: ColorPalette.appetizingOrange)),
                                ],
                              ),
                              const SizedBox(width: 6),
                              const Icon(Icons.keyboard_arrow_down_rounded,
                                  size: 16, color: ColorPalette.textMuted),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // PAGE TITLE BAR + ACTIONS + FILTERS
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildPageTitleBar(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 768;
              final titleWidget = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Quản lý Khách hàng & Tích điểm',
                    style: AppTypography.plusJakarta(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: ColorPalette.onSurfaceDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Xem danh sách khách hàng, điểm tích lũy hiện tại và lịch sử tích/đổi điểm qua từng đơn hàng.',
                    style: AppTypography.inter(
                      fontSize: 13,
                      color: ColorPalette.textMuted,
                    ),
                  ),
                ],
              );

              final actionsWidget = Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.sync_rounded,
                          size: 16, color: ColorPalette.tertiary),
                      const SizedBox(width: 6),
                      Text(
                        'Đồng bộ lúc $_lastSyncedTime',
                        style: AppTypography.inter(
                          fontSize: 12,
                          color: ColorPalette.textMuted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 14),
                ],
              );

              if (isWide) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(child: titleWidget),
                    const SizedBox(width: 16),
                    actionsWidget,
                  ],
                );
              } else {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    titleWidget,
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: actionsWidget,
                    ),
                  ],
                );
              }
            },
          ),
          const SizedBox(height: 18),
          _buildFilterToolbar(context),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // KPI METRIC CARDS (Cleaned: Strictly based on Customer DB fields)
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildKpiMetrics(List<CustomerEntity> customers, int totalCount) {
    final activeCount = customers.where((c) => c.loyaltyPoints > 0).length;
    final zeroPointCount = customers.where((c) => c.loyaltyPoints == 0).length;
    final totalPoints = customers.fold<int>(0, (sum, c) => sum + c.loyaltyPoints);

    final activePercentage = totalCount == 0
        ? 0
        : ((activeCount / (customers.isEmpty ? 1 : customers.length)) * 100).round();

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 1050
            ? 4
            : (constraints.maxWidth > 550 ? 2 : 1);
        const gap = 16.0;
        final cardWidth =
            (constraints.maxWidth - ((crossAxisCount - 1) * gap)) /
                crossAxisCount;

        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            _buildMetricCard(
              title: 'TỔNG KHÁCH HÀNG',
              value: totalCount.toString(),
              subtitle: 'Tất cả khách hàng hệ thống',
              icon: Icons.groups_rounded,
              iconColor: ColorPalette.primaryContainer,
              iconBg: ColorPalette.primaryFixed.withValues(alpha: 0.6),
              width: cardWidth,
              trendValue: '+$totalCount',
              trendPositive: true,
            ),
            _buildMetricCard(
              title: 'CÓ ĐIỂM TÍCH LŨY',
              value: activeCount.toString(),
              subtitle: '$activePercentage% khách đã tích lũy điểm',
              icon: Icons.verified_user_rounded,
              iconColor: ColorPalette.tertiary,
              iconBg: ColorPalette.tertiary.withValues(alpha: 0.1),
              width: cardWidth,
              trendValue: '+$activeCount',
              trendPositive: true,
            ),
            _buildMetricCard(
              title: 'TỔNG ĐIỂM HỆ THỐNG',
              value: NumberFormat('#,###').format(totalPoints),
              subtitle: 'Điểm thưởng khả dụng toàn hệ thống',
              icon: Icons.toll_rounded,
              iconColor: ColorPalette.adminPurple,
              iconBg: ColorPalette.adminPurple.withValues(alpha: 0.1),
              width: cardWidth,
            ),
            _buildMetricCard(
              title: 'CHƯA CÓ ĐIỂM',
              value: zeroPointCount.toString(),
              subtitle: 'Khách hàng chưa phát sinh điểm',
              icon: Icons.person_outline_rounded,
              iconColor: ColorPalette.textMuted,
              iconBg: ColorPalette.webBgAdmin,
              width: cardWidth,
            ),
          ],
        );
      },
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required double width,
    String? trendValue,
    bool trendPositive = true,
  }) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        color: ColorPalette.surfaceWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ColorPalette.borderSubtle),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTypography.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: ColorPalette.textMuted,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        value,
                        style: AppTypography.plusJakarta(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: ColorPalette.onSurfaceDark,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: iconColor, size: 22),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.only(top: 12),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: ColorPalette.borderSubtle)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      subtitle,
                      style: AppTypography.dashboardSubtitle.copyWith(fontSize: 11),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (trendValue != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: trendPositive
                            ? ColorPalette.success.withValues(alpha: 0.08)
                            : ColorPalette.error.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            trendPositive
                                ? Icons.trending_up_rounded
                                : Icons.trending_down_rounded,
                            size: 14,
                            color: trendPositive
                                ? ColorPalette.success
                                : ColorPalette.error,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            trendValue,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: trendPositive
                                  ? ColorPalette.success
                                  : ColorPalette.error,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // PILL FILTER TOOLBAR (Search input + Pills matching Staff Management)
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildFilterToolbar(BuildContext context) {
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
        controller: _searchController,
        onChanged: (val) {
          setState(() {});
          _debounce?.cancel();
          _debounce = Timer(const Duration(milliseconds: 350), () {
            if (!mounted) return;
            setState(() {
              _searchQuery = val.trim();
              _currentPage = 1;
            });
            _loadData();
          });
        },
        style: const TextStyle(fontSize: 13),
        decoration: InputDecoration(
          hintText: 'Tìm theo họ tên, SĐT...',
          hintStyle: const TextStyle(fontSize: 12, color: ColorPalette.textMuted),
          prefixIcon: const Icon(Icons.search_rounded,
              size: 18, color: ColorPalette.textMuted),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear_rounded, size: 16),
                  onPressed: () {
                    _debounce?.cancel();
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                      _currentPage = 1;
                    });
                    _loadData();
                  },
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
        _buildPillFilter(
          label: 'Tất cả',
          isActive: _selectedHasPoints == null,
          onTap: () => _onPointsFilterChanged(null),
        ),
        _buildPillFilter(
          label: 'Có điểm tích lũy',
          isActive: _selectedHasPoints == true,
          onTap: () => _onPointsFilterChanged(
              _selectedHasPoints == true ? null : true),
          activeColor: ColorPalette.success,
          icon: Icons.monetization_on_rounded,
        ),
        _buildPillFilter(
          label: 'Chưa có điểm (0đ)',
          isActive: _selectedHasPoints == false,
          onTap: () => _onPointsFilterChanged(
              _selectedHasPoints == false ? null : false),
          activeColor: ColorPalette.textMuted,
          icon: Icons.person_outline_rounded,
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

  // ═══════════════════════════════════════════════════════════════════════════
  // DATA TABLE / CARD CONTAINER
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildCustomerTableCard(
    BuildContext context,
    List<CustomerEntity> items,
    int totalPages,
    int totalCount, {
    bool isRefreshing = false,
  }) {
    if (items.isEmpty && !isRefreshing) {
      return _buildEmptyState();
    }

    return Container(
      decoration: BoxDecoration(
        color: ColorPalette.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ColorPalette.borderSubtle),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (isRefreshing)
            const LinearProgressIndicator(
              minHeight: 2,
              color: ColorPalette.appetizingOrange,
              backgroundColor: Colors.transparent,
            ),
          // Table Card Header Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
            child: Wrap(
              spacing: 16,
              runSpacing: 12,
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Danh sách khách hàng',
                          style: AppTypography.plusJakarta(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: ColorPalette.onSurfaceDark,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: ColorPalette.primaryFixed,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '$totalCount người',
                            style: AppTypography.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: ColorPalette.primaryContainer,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Hiển thị trang $_currentPage / ${totalPages == 0 ? 1 : totalPages} — thông tin liên hệ và lịch sử giao dịch điểm.',
                      style: AppTypography.inter(
                          fontSize: 12, color: ColorPalette.textMuted),
                    ),
                  ],
                ),
                Wrap(
                  spacing: 10,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    // View Mode Switcher: Table View vs Card Grid View
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: ColorPalette.webBgAdmin,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: ColorPalette.borderSubtle),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildViewModeButton(
                            icon: Icons.table_rows_rounded,
                            tooltip: 'Dạng bảng chi tiết',
                            isSelected: !_isCardView,
                            onTap: () => setState(() => _isCardView = false),
                          ),
                          _buildViewModeButton(
                            icon: Icons.grid_view_rounded,
                            tooltip: 'Dạng thẻ lưới trực quan',
                            isSelected: _isCardView,
                            onTap: () => setState(() => _isCardView = true),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: ColorPalette.borderSubtle),

          // Main Content: Either Proportional Flex Table OR Modern Card Grid
          if (items.isEmpty)
            _buildEmptyState()
          else if (!_isCardView)
            LayoutBuilder(
              builder: (context, constraints) {
                final effectiveWidth = math.max(880.0, constraints.maxWidth);
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: effectiveWidth,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildProportionalTableHeader(),
                        ...items.asMap().entries.map((e) {
                          final index =
                              e.key + 1 + ((_currentPage - 1) * _pageSize);
                          return _buildProportionalTableRow(
                              context, e.value, index);
                        }),
                      ],
                    ),
                  ),
                );
              },
            )
          else
            _buildCustomerCardGrid(context, items),

          // Pagination
          const Divider(height: 1, color: ColorPalette.borderSubtle),
          _buildPagination(totalPages, totalCount),
        ],
      ),
    );
  }

  // ─── Proportional Flex Table Header ─────────────────────────────────────────
  Widget _buildProportionalTableHeader() {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: ColorPalette.webBgAdmin.withValues(alpha: 0.8),
        border: const Border(bottom: BorderSide(color: ColorPalette.borderSubtle)),
      ),
      child: const Row(
        children: [
          SizedBox(width: 44, child: Text('#', style: AppTypography.tableHeader)),
          SizedBox(width: 12),
          Expanded(
              flex: 4,
              child: Text('KHÁCH HÀNG', style: AppTypography.tableHeader)),
          Expanded(
              flex: 3,
              child: Text('SỐ ĐIỆN THOẠI', style: AppTypography.tableHeader)),
          Expanded(
              flex: 3,
              child: Text('ĐIỂM TÍCH LŨY', style: AppTypography.tableHeader)),
          Expanded(
              flex: 3,
              child: Text('NGÀY THAM GIA', style: AppTypography.tableHeader)),
          SizedBox(
              width: 80,
              child: Text('THAO TÁC',
                  textAlign: TextAlign.right,
                  style: AppTypography.tableHeader)),
        ],
      ),
    );
  }

  // ─── Proportional Flex Table Row ────────────────────────────────────────────
  Widget _buildProportionalTableRow(
      BuildContext context, CustomerEntity customer, int index) {
    final df = DateFormat('dd/MM/yyyy');

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _openHistoryModal(context, customer),
        hoverColor: ColorPalette.webBgAdmin.withValues(alpha: 0.4),
        child: Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: const BoxDecoration(
            border: Border(
                bottom: BorderSide(color: ColorPalette.borderSubtle, width: 0.5)),
          ),
          child: Row(
            children: [
              // Index #
              SizedBox(
                width: 44,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF1F5F9),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '$index',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Customer Name + Avatar
              Expanded(
                flex: 4,
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 17,
                      backgroundColor:
                          ColorPalette.primaryFixed.withValues(alpha: 0.8),
                      child: Text(
                        _getInitials(customer.customerName),
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                          color: ColorPalette.primaryContainer,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            customer.customerName,
                            style: AppTypography.labelLarge.copyWith(fontSize: 13),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Mã KH: #${customer.customerId}',
                            style: AppTypography.dashboardSubtitle
                                .copyWith(fontSize: 11),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Phone Number
              Expanded(
                flex: 3,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.phone_outlined,
                        size: 14, color: ColorPalette.textMuted),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        customer.phone,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: ColorPalette.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),

              // Loyalty Points
              Expanded(
                flex: 3,
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: ColorPalette.primaryFixed.withValues(alpha: 0.5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.toll_rounded,
                        size: 14,
                        color: ColorPalette.primaryContainer,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${customer.loyaltyPoints} điểm',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: ColorPalette.appetizingOrange,
                      ),
                    ),
                  ],
                ),
              ),

              // Join Date
              Expanded(
                flex: 3,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.calendar_today_outlined,
                        size: 13, color: ColorPalette.textMuted),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        df.format(customer.createdAt),
                        style: const TextStyle(
                            fontSize: 12, color: ColorPalette.textMuted),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),

              // Action button (History icon)
              SizedBox(
                width: 80,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    icon: const Icon(Icons.history_rounded, size: 18),
                    color: ColorPalette.appetizingOrange,
                    tooltip: 'Lịch sử tích điểm',
                    style: IconButton.styleFrom(
                      backgroundColor:
                          ColorPalette.appetizingOrange.withValues(alpha: 0.08),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      minimumSize: const Size(34, 34),
                    ),
                    onPressed: () => _openHistoryModal(context, customer),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── View Mode Switcher Button ──────────────────────────────────────────────
  Widget _buildViewModeButton({
    required IconData icon,
    required String tooltip,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? ColorPalette.surface : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 3,
                      offset: const Offset(0, 1),
                    ),
                  ]
                : null,
          ),
          child: Icon(
            icon,
            size: 16,
            color: isSelected
                ? ColorPalette.appetizingOrange
                : ColorPalette.textMuted,
          ),
        ),
      ),
    );
  }

  // ─── Modern Card Grid View (Alternative Layout) ─────────────────────────────
  Widget _buildCustomerCardGrid(
      BuildContext context, List<CustomerEntity> items) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final crossAxisCount = constraints.maxWidth > 1150
              ? 3
              : (constraints.maxWidth > 700 ? 2 : 1);
          const gap = 16.0;
          final cardWidth =
              (constraints.maxWidth - ((crossAxisCount - 1) * gap)) /
                  crossAxisCount;

          return Wrap(
            spacing: gap,
            runSpacing: gap,
            children: items.asMap().entries.map((e) {
              final index = e.key + 1 + ((_currentPage - 1) * _pageSize);
              return SizedBox(
                width: cardWidth,
                child: _buildCustomerCard(context, e.value, index),
              );
            }).toList(),
          );
        },
      ),
    );
  }

  Widget _buildCustomerCard(
      BuildContext context, CustomerEntity customer, int index) {
    final df = DateFormat('dd/MM/yyyy');

    return Container(
      decoration: BoxDecoration(
        color: ColorPalette.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ColorPalette.borderSubtle),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor:
                    ColorPalette.primaryFixed.withValues(alpha: 0.8),
                child: Text(
                  _getInitials(customer.customerName),
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: ColorPalette.primaryContainer,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      customer.customerName,
                      style: AppTypography.labelLarge.copyWith(fontSize: 14),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Mã KH: #${customer.customerId}',
                      style: AppTypography.dashboardSubtitle.copyWith(fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: ColorPalette.borderSubtle),
          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.phone_outlined,
                      size: 14, color: ColorPalette.textMuted),
                  const SizedBox(width: 6),
                  Text(customer.phone,
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: ColorPalette.textPrimary)),
                ],
              ),
              Row(
                children: [
                  const Icon(Icons.toll_rounded,
                      size: 14, color: ColorPalette.appetizingOrange),
                  const SizedBox(width: 4),
                  Text(
                    '${customer.loyaltyPoints} điểm',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: ColorPalette.appetizingOrange,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.calendar_today_outlined,
                  size: 12, color: ColorPalette.textMuted),
              const SizedBox(width: 6),
              Text(
                'Tham gia: ${df.format(customer.createdAt)}',
                style: const TextStyle(fontSize: 11, color: ColorPalette.textMuted),
              ),
            ],
          ),
          const SizedBox(height: 14),
          OutlinedButton.icon(
            onPressed: () => _openHistoryModal(context, customer),
            icon: const Icon(Icons.history_rounded, size: 15),
            label: const Text('Xem lịch sử tích điểm'),
            style: OutlinedButton.styleFrom(
              foregroundColor: ColorPalette.appetizingOrange,
              side: BorderSide(
                  color: ColorPalette.appetizingOrange.withValues(alpha: 0.4)),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              minimumSize: const Size(double.infinity, 36),
              textStyle:
                  const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // PAGINATION
  // ===========================================================================
  Widget _buildPagination(int totalPages, int totalCount) {
    return AppPaginationBar(
      currentPage: _currentPage,
      totalPages: totalPages == 0 ? 1 : totalPages,
      totalCount: totalCount,
      itemLabel: 'khách hàng',
      pageSize: _pageSize,
      onPageChanged: (page) {
        setState(() => _currentPage = page);
        _loadData();
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // EMPTY & ERROR STATES
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(48),
      decoration: BoxDecoration(
        color: ColorPalette.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ColorPalette.borderSubtle),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: ColorPalette.primaryFixed.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.people_outline_rounded,
                size: 40, color: ColorPalette.appetizingOrange),
          ),
          const SizedBox(height: 16),
          Text(
            'Không tìm thấy khách hàng nào',
            style: AppTypography.plusJakarta(
                fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            'Thử thay đổi từ khóa tìm kiếm hoặc các bộ lọc đang chọn.',
            style: AppTypography.dashboardSubtitle,
          ),
          const SizedBox(height: 20),
          OutlinedButton.icon(
            onPressed: () {
              _debounce?.cancel();
              _searchController.clear();
              setState(() {
                _searchQuery = '';
                _selectedHasPoints = null;
                _currentPage = 1;
              });
              _loadData();
            },
            icon: const Icon(Icons.filter_alt_off_rounded, size: 16),
            label: const Text('Xóa bộ lọc'),
            style: OutlinedButton.styleFrom(
              foregroundColor: ColorPalette.appetizingOrange,
              side: const BorderSide(color: ColorPalette.appetizingOrange),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        margin: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: ColorPalette.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: ColorPalette.borderSubtle),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: ColorPalette.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.error_outline_rounded,
                  size: 36, color: ColorPalette.error),
            ),
            const SizedBox(height: 16),
            Text(
              'Không thể tải dữ liệu khách hàng',
              style: AppTypography.plusJakarta(
                  fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              style: AppTypography.dashboardSubtitle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _loadData,
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('Thử lại'),
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorPalette.appetizingOrange,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
