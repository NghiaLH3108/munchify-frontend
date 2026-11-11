import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/ColorPalette.dart';
import '../../../../core/theme/AppTypography.dart';
import '../../../../core/widgets/admin/admin_widgets.dart';
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

  static final DateFormat _df = DateFormat('dd/MM/yyyy');

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

  void _onSearchChanged(String val) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      if (!mounted) return;
      setState(() {
        _searchQuery = val.trim();
        _currentPage = 1;
      });
      _loadData();
    });
  }

  void _clearFilters() {
    _debounce?.cancel();
    _searchController.clear();
    setState(() {
      _searchQuery = '';
      _selectedHasPoints = null;
      _currentPage = 1;
    });
    _loadData();
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
    return BlocConsumer<AdminCustomerBloc, AdminCustomerState>(
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
        Widget? stateView;
        List<Widget> kpis = const [];
        Widget? table;

        if (state is AdminCustomerLoading) {
          stateView = const AdminLoadingView(
            message: 'Đang đồng bộ danh sách khách hàng...',
          );
        } else if (state is AdminCustomerError) {
          stateView = AdminErrorView(message: state.message, onRetry: _loadData);
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

          kpis = _buildKpiCards(kpiItems, kpiTotal);
          table = _buildTable(
            filteredItems,
            state.customersData.totalPages,
            state.customersData.totalCount,
            state.isRefreshing,
          );
        } else {
          stateView = const SizedBox.shrink();
        }

        return AdminListScaffold(
          embedInShell: widget.embedInShell,
          stickyHeader: AdminStickyHeader(
            breadcrumb: 'Khách hàng thân thiết',
            onRefresh: _loadData,
            onQuickSearch: _onSearchChanged,
            userInitials: 'HM',
            userName: 'Hoàng Minh',
            userRole: 'Admin',
          ),
          header: AdminPageHeader(
            icon: Icons.groups_rounded,
            title: 'Quản lý Khách hàng & Tích điểm',
            subtitle:
                'Xem danh sách khách hàng, điểm tích lũy hiện tại và lịch sử tích/đổi điểm qua từng đơn hàng.',
            extraActions: [
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
            ],
          ),
          filterBar: _buildFilterToolbar(),
          kpiCards: kpis,
          table: table,
          stateView: stateView,
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // KPI METRIC CARDS
  // ═══════════════════════════════════════════════════════════════════════════
  List<Widget> _buildKpiCards(List<CustomerEntity> customers, int totalCount) {
    final activeCount = customers.where((c) => c.loyaltyPoints > 0).length;
    final zeroPointCount = customers.where((c) => c.loyaltyPoints == 0).length;

    final activePercentage = totalCount == 0
        ? 0
        : ((activeCount / (customers.isEmpty ? 1 : customers.length)) * 100)
            .round();

    return [
      AdminKpiCard(
        title: 'TỔNG KHÁCH HÀNG',
        value: totalCount.toString(),
        subtitle: 'Tất cả khách hàng hệ thống',
        icon: Icons.groups_rounded,
        iconColor: ColorPalette.primaryContainer,
        iconBg: ColorPalette.primaryFixed.withValues(alpha: 0.6),
        showTrendIcon: true,
        trendPositive: true,
      ),
      AdminKpiCard(
        title: 'CÓ ĐIỂM TÍCH LŨY',
        value: activeCount.toString(),
        subtitle: '$activePercentage% khách đã tích lũy điểm',
        icon: Icons.verified_user_rounded,
        iconColor: ColorPalette.tertiary,
        iconBg: ColorPalette.tertiary.withValues(alpha: 0.1),
        showTrendIcon: true,
        trendPositive: true,
      ),
      AdminKpiCard(
        title: 'CHƯA CÓ ĐIỂM',
        value: zeroPointCount.toString(),
        subtitle: 'Khách hàng chưa phát sinh điểm',
        icon: Icons.person_outline_rounded,
        iconColor: ColorPalette.textMuted,
        iconBg: ColorPalette.webBgAdmin,
      ),
    ];
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // FILTER TOOLBAR
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildFilterToolbar() {
    return AdminFilterBar(
      searchController: _searchController,
      searchHint: 'Tìm theo họ tên, SĐT...',
      onSearchChanged: (val) {
        setState(() {});
        _onSearchChanged(val);
      },
      onClearSearch: () {
        _debounce?.cancel();
        setState(() {
          _searchQuery = '';
          _currentPage = 1;
        });
        _loadData();
      },
      filters: [
        AdminDropdownFilter<bool?>(
          value: _selectedHasPoints,
          items: const [
            DropdownMenuItem(value: null, child: Text('Tất cả khách hàng')),
            DropdownMenuItem(value: true, child: Text('Có điểm tích lũy')),
            DropdownMenuItem(value: false, child: Text('Chưa có điểm (0đ)')),
          ],
          onChanged: _onPointsFilterChanged,
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // DATA TABLE (template dùng chung)
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildTable(
    List<CustomerEntity> items,
    int totalPages,
    int totalCount,
    bool isRefreshing,
  ) {
    final pages = totalPages == 0 ? 1 : totalPages;
    return AdminDataTable<CustomerEntity>(
      title: 'Danh sách khách hàng',
      countLabel: '$totalCount người',
      subtitle:
          'Hiển thị trang $_currentPage / $pages — thông tin liên hệ và lịch sử giao dịch điểm.',
      items: items,
      indexOffset: (_currentPage - 1) * _pageSize,
      minTableWidth: 880,
      isRefreshing: isRefreshing,
      onRowTap: (c) => _openHistoryModal(context, c),
      isCardView: _isCardView,
      onToggleView: (v) => setState(() => _isCardView = v),
      cardBuilder: (context, c, _) => _buildCustomerCard(context, c),
      emptyState: AdminEmptyState(
        icon: Icons.people_outline_rounded,
        title: 'Không tìm thấy khách hàng nào',
        subtitle: 'Thử thay đổi từ khóa tìm kiếm hoặc các bộ lọc đang chọn.',
        action: OutlinedButton.icon(
          onPressed: _clearFilters,
          icon: const Icon(Icons.filter_alt_off_rounded, size: 16),
          label: const Text('Xóa bộ lọc'),
          style: OutlinedButton.styleFrom(
            foregroundColor: ColorPalette.appetizingOrange,
            side: const BorderSide(color: ColorPalette.appetizingOrange),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ),
      columns: [
        AdminTableColumn.index<CustomerEntity>(),
        AdminTableColumn(
          label: 'KHÁCH HÀNG',
          flex: 4,
          cellBuilder: (_, customer, _) => Row(
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
                      style:
                          AppTypography.dashboardSubtitle.copyWith(fontSize: 11),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        AdminTableColumn(
          label: 'SỐ ĐIỆN THOẠI',
          flex: 3,
          cellBuilder: (_, customer, _) => Row(
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
        AdminTableColumn(
          label: 'ĐIỂM TÍCH LŨY',
          flex: 3,
          cellBuilder: (_, customer, _) => Row(
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
        AdminTableColumn(
          label: 'NGÀY THAM GIA',
          flex: 3,
          cellBuilder: (_, customer, _) => Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.calendar_today_outlined,
                  size: 13, color: ColorPalette.textMuted),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  _df.format(customer.createdAt),
                  style: const TextStyle(
                      fontSize: 12, color: ColorPalette.textMuted),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        AdminTableColumn(
          label: 'THAO TÁC',
          width: 80,
          align: TextAlign.right,
          cellBuilder: (ctx, customer, _) => Align(
            alignment: Alignment.centerRight,
            child: AdminRowActionButton(
              icon: Icons.history_rounded,
              color: ColorPalette.appetizingOrange,
              tooltip: 'Lịch sử tích điểm',
              onPressed: () => _openHistoryModal(ctx, customer),
            ),
          ),
        ),
      ],
      pagination: AppPaginationBar(
        currentPage: _currentPage,
        totalPages: pages,
        totalCount: totalCount,
        itemLabel: 'khách hàng',
        pageSize: _pageSize,
        onPageChanged: (page) {
          setState(() => _currentPage = page);
          _loadData();
        },
      ),
    );
  }

  Widget _buildCustomerCard(BuildContext context, CustomerEntity customer) {
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
                      style:
                          AppTypography.dashboardSubtitle.copyWith(fontSize: 12),
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
                'Tham gia: ${_df.format(customer.createdAt)}',
                style:
                    const TextStyle(fontSize: 11, color: ColorPalette.textMuted),
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
              shape:
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              minimumSize: const Size(double.infinity, 36),
              textStyle:
                  const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
