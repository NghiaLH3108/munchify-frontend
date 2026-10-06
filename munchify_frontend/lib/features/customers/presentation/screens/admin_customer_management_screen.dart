import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/ColorPalette.dart';
import '../../../../core/theme/AppTypography.dart';
import '../../domain/entities/customer_entity.dart';
import '../bloc/admin_customer_bloc.dart';
import '../bloc/admin_customer_event.dart';
import '../bloc/admin_customer_state.dart';
import '../widgets/customer_points_history_modal.dart';

class AdminCustomerManagementScreen extends StatefulWidget {
  const AdminCustomerManagementScreen({super.key});

  @override
  State<AdminCustomerManagementScreen> createState() => _AdminCustomerManagementScreenState();
}

class _AdminCustomerManagementScreenState extends State<AdminCustomerManagementScreen> {
  int _currentPage = 1;
  static const int _pageSize = 10;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadData() {
    context.read<AdminCustomerBloc>().add(
          LoadAdminCustomers(
            pageIndex: _currentPage,
            pageSize: _pageSize,
            searchKeyword: _searchQuery.isNotEmpty ? _searchQuery : null,
          ),
        );
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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error_outline_rounded, color: Colors.white, size: 18),
                  const SizedBox(width: 10),
                  Expanded(child: Text(state.message, style: const TextStyle(fontSize: 13))),
                ],
              ),
              backgroundColor: ColorPalette.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              margin: const EdgeInsets.all(16),
            ),
          );
        }
      },
      buildWhen: (previous, current) =>
          current is AdminCustomerLoading || current is AdminCustomersLoaded || current is AdminCustomerError,
      builder: (context, state) {
        if (state is AdminCustomerLoading) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 40,
                  height: 40,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    color: ColorPalette.appetizingOrange,
                  ),
                ),
                const SizedBox(height: 16),
                Text('Đang đồng bộ dữ liệu khách hàng...',
                    style: AppTypography.dashboardSubtitle),
              ],
            ),
          );
        } else if (state is AdminCustomersLoaded) {
          final customers = state.customersData.items;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildPageTitleBar(),
                const SizedBox(height: 24),
                _buildCustomerTableCard(customers, state.customersData.totalCount),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildPageTitleBar() {
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
                    'Khách hàng thân thiết',
                    style: AppTypography.plusJakarta(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: ColorPalette.onSurfaceDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Quản lý danh sách khách hàng và lịch sử tích/tiêu điểm.',
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
                  ElevatedButton.icon(
                    onPressed: _loadData,
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    label: const Text('Tải lại'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorPalette.surfaceWhite,
                      foregroundColor: ColorPalette.primaryContainer,
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: const BorderSide(color: ColorPalette.primaryContainer),
                      ),
                      textStyle: AppTypography.inter(fontSize: 13, fontWeight: FontWeight.w700),
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
          ),
          const SizedBox(height: 18),
          _buildFilterToolbar(),
        ],
      ),
    );
  }

  Widget _buildFilterToolbar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: ColorPalette.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ColorPalette.borderSubtle),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: SizedBox(
              height: 40,
              child: TextField(
                controller: _searchController,
                style: const TextStyle(fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'Tìm theo họ tên hoặc SĐT...',
                  hintStyle: const TextStyle(fontSize: 12, color: ColorPalette.textMuted),
                  prefixIcon: const Icon(Icons.search_rounded, size: 18, color: ColorPalette.textMuted),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.search_rounded, size: 16, color: ColorPalette.primaryContainer),
                    onPressed: () {
                      setState(() {
                        _searchQuery = _searchController.text.trim();
                        _currentPage = 1;
                      });
                      _loadData();
                    },
                  ),
                  filled: true,
                  fillColor: ColorPalette.webBgAdmin.withValues(alpha: 0.6),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
                onSubmitted: (val) {
                  setState(() {
                    _searchQuery = val.trim();
                    _currentPage = 1;
                  });
                  _loadData();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerTableCard(List<CustomerEntity> customers, int totalCount) {
    if (customers.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: ColorPalette.surfaceWhite,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: ColorPalette.borderSubtle),
        ),
        alignment: Alignment.center,
        child: Column(
          children: [
            Icon(Icons.people_outline_rounded, size: 48, color: ColorPalette.textMuted.withValues(alpha: 0.5)),
            const SizedBox(height: 16),
            const Text('Không tìm thấy khách hàng nào', style: TextStyle(fontSize: 14, color: ColorPalette.textMuted)),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: ColorPalette.surfaceWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ColorPalette.borderSubtle),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width - 48),
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(ColorPalette.webBgAdmin.withValues(alpha: 0.5)),
                dataRowMinHeight: 60,
                dataRowMaxHeight: 60,
                horizontalMargin: 24,
                columnSpacing: 24,
                columns: const [
                  DataColumn(label: Text('Khách hàng', style: TextStyle(fontWeight: FontWeight.w600))),
                  DataColumn(label: Text('Số điện thoại', style: TextStyle(fontWeight: FontWeight.w600))),
                  DataColumn(label: Text('Hạng thành viên', style: TextStyle(fontWeight: FontWeight.w600))),
                  DataColumn(label: Text('Điểm', style: TextStyle(fontWeight: FontWeight.w600))),
                  DataColumn(label: Text('Thao tác', style: TextStyle(fontWeight: FontWeight.w600))),
                ],
                rows: customers.map((c) {
                  return DataRow(
                    cells: [
                      DataCell(
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: ColorPalette.primaryContainer.withValues(alpha: 0.1),
                              child: Text(
                                c.customerName.isNotEmpty ? c.customerName[0].toUpperCase() : '?',
                                style: const TextStyle(
                                  color: ColorPalette.primaryContainer,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              c.customerName,
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                      DataCell(Text(c.phone)),
                      DataCell(
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: ColorPalette.secondary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Thành viên',
                            style: const TextStyle(
                              color: ColorPalette.secondary,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      DataCell(
                        Text(
                          '${c.loyaltyPoints} điểm',
                          style: const TextStyle(
                            color: ColorPalette.primaryContainer,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      DataCell(
                        OutlinedButton.icon(
                          onPressed: () => _openHistoryModal(context, c),
                          icon: const Icon(Icons.history_rounded, size: 14),
                          label: const Text('Lịch sử', style: TextStyle(fontSize: 12)),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: ColorPalette.primaryContainer,
                            side: const BorderSide(color: ColorPalette.borderSubtle),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                          ),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
          _buildPaginationBar(totalCount),
        ],
      ),
    );
  }

  Widget _buildPaginationBar(int totalCount) {
    final totalPages = (totalCount / _pageSize).ceil();
    if (totalPages <= 1) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: ColorPalette.borderSubtle)),
        color: ColorPalette.surfaceWhite,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Hiển thị trang $_currentPage / $totalPages (Tổng $totalCount)',
            style: const TextStyle(fontSize: 13, color: ColorPalette.textMuted),
          ),
          Row(
            children: [
              IconButton(
                onPressed: _currentPage > 1
                    ? () {
                        setState(() => _currentPage--);
                        _loadData();
                      }
                    : null,
                icon: const Icon(Icons.chevron_left_rounded),
              ),
              IconButton(
                onPressed: _currentPage < totalPages
                    ? () {
                        setState(() => _currentPage++);
                        _loadData();
                      }
                    : null,
                icon: const Icon(Icons.chevron_right_rounded),
              ),
            ],
          )
        ],
      ),
    );
  }
}
