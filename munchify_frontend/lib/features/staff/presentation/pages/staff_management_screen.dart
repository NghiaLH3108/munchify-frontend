import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/AppTypography.dart';
import '../../../../core/theme/ColorPalette.dart';
import '../../../../core/widgets/admin/admin_widgets.dart';
import '../../domain/entities/staff_entity.dart';
import '../bloc/staff_bloc.dart';
import '../bloc/staff_event.dart';
import '../bloc/staff_state.dart';
import '../widgets/staff_data_table.dart';
import '../widgets/staff_filter_bar.dart';
import '../widgets/staff_form_dialog.dart';
import '../widgets/staff_metric_cards.dart';
import '../../../../core/widgets/app_pagination_bar.dart';
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
    return BlocConsumer<StaffBloc, StaffState>(
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
        Widget? stateView;
        List<Widget> kpis = const [];
        Widget? table;

        if (state is StaffLoading) {
          stateView = const AdminLoadingView(
            message: 'Đang đồng bộ danh sách nhân viên...',
          );
        } else if (state is StaffError) {
          stateView = AdminErrorView(message: state.message, onRetry: _loadData);
        } else if (state is StaffListLoaded) {
          kpis = StaffMetricCards.cards(state.kpiItems);
          table = StaffDataTable(
            items: state.result.items,
            currentPage: _currentPage,
            pageSize: _pageSize,
            totalPages: state.result.totalPages,
            totalCount: state.result.totalCount,
            isRefreshing: state.isRefreshing,
            isCardView: _isCardView,
            onToggleViewMode: (val) => setState(() => _isCardView = val),
            onEditStaff: (staff) =>
                _openStaffDialog(context, staffToEdit: staff),
            onToggleStatus: (staff) {
              context.read<StaffBloc>().add(
                ToggleStaffStatusEvent(staff.userId),
              );
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
          );
        } else {
          stateView = const SizedBox.shrink();
        }

        return AdminListScaffold(
          embedInShell: widget.embedInShell,
          stickyHeader: AdminStickyHeader(
            breadcrumb: 'Nhân viên & Quyền',
            onRefresh: _loadData,
            userInitials: 'HM',
            userName: 'Hoàng Minh',
            userRole: 'Admin',
          ),
          header: _buildPageTitleBar(context),
          filterBar: StaffFilterBar(
            searchController: _searchController,
            searchQuery: _searchQuery,
            onSearchChanged: _onSearchChanged,
            onClearSearch: _onClearSearch,
            selectedRole: _selectedRole,
            onRoleChanged: _onRoleFilterChanged,
            selectedStatus: _selectedStatus,
            onStatusChanged: _onStatusFilterChanged,
          ),
          kpiCards: kpis,
          table: table,
          stateView: stateView,
        );
      },
    );
  }

  Widget _buildPageTitleBar(BuildContext context) {
    return AdminPageHeader(
      icon: Icons.badge_rounded,
      title: 'Quản lý Nhân sự & Phân quyền',
      subtitle: 'Phân quyền tài khoản, cấu hình thông tin nhân sự và giám sát trạng thái hoạt động.',
      addButtonText: 'Thêm Nhân Viên',
      onAddPressed: () => _openStaffDialog(context),
      extraActions: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.sync_rounded,
              size: 16,
              color: ColorPalette.tertiary,
            ),
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
      ],
    );
  }
}