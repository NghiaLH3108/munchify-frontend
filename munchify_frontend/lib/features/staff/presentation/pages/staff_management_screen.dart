import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/AppTypography.dart';
import '../../../../core/theme/ColorPalette.dart';
import '../../domain/entities/staff_entity.dart';
import '../bloc/staff_bloc.dart';
import '../bloc/staff_event.dart';
import '../bloc/staff_state.dart';
import '../widgets/staff_data_table.dart';
import '../widgets/staff_filter_bar.dart';
import '../widgets/staff_form_dialog.dart';
import '../widgets/staff_metric_cards.dart';
import '../../../../core/widgets/app_pagination_bar.dart';
import '../widgets/staff_pagination.dart';
import '../../../../core/widgets/app_toast.dart';

/// Orchestrator screen for Staff Management and Authorization:
/// Integrates KPI metric cards, search/filter bar, data table, and pagination.
class StaffManagementScreen extends StatefulWidget {
  final bool embedInShell;
  const StaffManagementScreen({super.key, this.embedInShell = false});

  @override
  State<StaffManagementScreen> createState() => _StaffManagementScreenState();
}

class _StaffManagementScreenState extends State<StaffManagementScreen> {
  int _currentPage = 1;
  static const int _pageSize = 10;
  String? _selectedRole;
  bool? _selectedStatus;
  String _searchQuery = '';
  bool _isCardView = false;
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _loadData() {
    context.read<StaffBloc>().add(
          LoadStaffList(
            page: _currentPage,
            pageSize: _pageSize,
            role: _selectedRole,
            isActive: _selectedStatus,
            searchKeyword: _searchQuery.isNotEmpty ? _searchQuery : null,
          ),
        );
  }

  void _onSearchChanged(String val) {
    _searchQuery = val.trim();
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 350), () {
      setState(() {
        _currentPage = 1;
      });
      _loadData();
    });
  }

  void _onClearSearch() {
    _searchController.clear();
    _debounceTimer?.cancel();
    setState(() {
      _searchQuery = '';
      _currentPage = 1;
    });
    _loadData();
  }

  void _onRoleFilterChanged(String? role) {
    setState(() {
      _selectedRole = role;
      _currentPage = 1;
    });
    _loadData();
  }

  void _onStatusFilterChanged(bool? status) {
    setState(() {
      _selectedStatus = status;
      _currentPage = 1;
    });
    _loadData();
  }

  void _openStaffDialog(BuildContext context, {StaffEntity? staffToEdit}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => BlocProvider.value(
        value: context.read<StaffBloc>(),
        child: StaffFormDialog(staffToEdit: staffToEdit),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bodyContent = BlocConsumer<StaffBloc, StaffState>(
      listener: (context, state) {
        if (state is StaffActionSuccess) {
          AppToast.success(state.message, context: context);
          _loadData();
        } else if (state is StaffError) {
          AppToast.error(state.message, context: context);
        }
      },
      buildWhen: (previous, current) =>
          current is StaffLoading ||
          current is StaffListLoaded ||
          current is StaffError,
      builder: (context, state) {
        if (state is StaffLoading) {
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
                Text('Đang đồng bộ danh sách nhân viên...',
                    style: AppTypography.dashboardSubtitle),
              ],
            ),
          );
        } else if (state is StaffError) {
          return _buildErrorState(state.message);
        } else if (state is StaffListLoaded) {
          final allItems = state.result.items;
          final kpiItems = state.kpiItems;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildPageTitleBar(context),
                const SizedBox(height: 18),
                StaffFilterBar(
                  searchController: _searchController,
                  searchQuery: _searchQuery,
                  onSearchChanged: _onSearchChanged,
                  onClearSearch: _onClearSearch,
                  selectedRole: _selectedRole,
                  onRoleChanged: _onRoleFilterChanged,
                  selectedStatus: _selectedStatus,
                  onStatusChanged: _onStatusFilterChanged,
                ),
                const SizedBox(height: 20),
                StaffMetricCards(staffList: kpiItems),
                const SizedBox(height: 24),
                if (state.isRefreshing)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 4),
                    child: LinearProgressIndicator(
                      minHeight: 2,
                      color: ColorPalette.appetizingOrange,
                      backgroundColor: Colors.transparent,
                    ),
                  ),
                StaffDataTable(
                  items: allItems,
                  currentPage: _currentPage,
                  pageSize: _pageSize,
                  totalPages: state.result.totalPages,
                  totalCount: state.result.totalCount,
                  isCardView: _isCardView,
                  onToggleViewMode: (val) =>
                      setState(() => _isCardView = val),
                  onEditStaff: (staff) =>
                      _openStaffDialog(context, staffToEdit: staff),
                  onToggleStatus: (staff) {
                    context
                        .read<StaffBloc>()
                        .add(ToggleStaffStatusEvent(staff.userId));
                  },
                  paginationWidget: AppPaginationBar(
                    currentPage: _currentPage,
                    totalPages: state.result.totalPages,
                    totalCount: state.result.totalCount,
                    itemLabel: 'nhân viên',
                    pageSize: _pageSize,
                    onPageChanged: (page) {
                      setState(() => _currentPage = page);
                      _loadData();
                    },
                  ),
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

  Widget _buildStickyHeader(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      decoration: const BoxDecoration(
        color: ColorPalette.surface,
        border: Border(bottom: BorderSide(color: ColorPalette.borderSubtle)),
        boxShadow: [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 4,
            offset: Offset(0, 1),
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
                child: const Icon(Icons.lunch_dining_rounded,
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
                    Text('Nhân viên & Quyền',
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
                      if (!isVeryNarrow) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color:
                                ColorPalette.success.withValues(alpha: 0.08),
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
                              backgroundColor:
                                  ColorPalette.surfaceContainerHigh,
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
                                          color:
                                              ColorPalette.appetizingOrange)),
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

  Widget _buildPageTitleBar(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 768;
        final titleWidget = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quản lý Nhân sự & Phân quyền',
              style: AppTypography.plusJakarta(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: ColorPalette.onSurfaceDark,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Phân quyền tài khoản, cấu hình thông tin nhân sự và giám sát trạng thái hoạt động.',
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
                  'Đồng bộ lúc 14:28:10',
                  style: AppTypography.inter(
                    fontSize: 12,
                    color: ColorPalette.textMuted,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 14),
            ElevatedButton.icon(
              onPressed: () => _openStaffDialog(context),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('+ Thêm Nhân Viên'),
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorPalette.primaryContainer,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                textStyle: AppTypography.inter(
                    fontSize: 13, fontWeight: FontWeight.w700),
              ),
            ),
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
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: ColorPalette.error.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.cloud_off_rounded,
                  color: ColorPalette.error, size: 44),
            ),
            const SizedBox(height: 16),
            Text('Không thể tải dữ liệu',
                style: AppTypography.dashboardHeadline),
            const SizedBox(height: 8),
            Text(message,
                style: AppTypography.dashboardSubtitle,
                textAlign: TextAlign.center),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _loadData,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Thử Lại'),
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorPalette.appetizingOrange,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
