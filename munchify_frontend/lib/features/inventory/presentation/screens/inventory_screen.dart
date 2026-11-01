import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../bloc/stock_import_bloc.dart';
import '../bloc/stock_import_event.dart';
import '../bloc/stock_import_state.dart';
import '../../domain/entities/stock_import_entity.dart';
import '../widgets/create_import_modal.dart';
import '../widgets/import_detail_modal.dart';
import '../../../../core/theme/ColorPalette.dart';
import '../../../../core/widgets/admin/admin_widgets.dart';
import '../../../../core/services/signalr_service.dart';
import '../../../../core/widgets/app_pagination_bar.dart';
import '../../../../core/widgets/app_toast.dart';

class InventoryScreen extends StatefulWidget {
  final bool embedInShell;
  
  const InventoryScreen({
    super.key,
    this.embedInShell = false,
  });

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _filterStatus = 'ALL';
  DateTime? _selectedDate;
  int _currentPage = 1;
  static const int _pageSize = 10;

  @override
  void initState() {
    super.initState();
    context.read<StockImportBloc>().add(FetchStockImportsEvent());

    // Tích hợp SignalR: Lắng nghe sự kiện cập nhật phiếu nhập kho từ Server theo thời gian thực
    signalRService.onStockImportUpdate(_onStockImportUpdate);
  }

  void _onStockImportUpdate(String message) {
    if (mounted) {
      // Tự động làm mới danh sách phiếu nhập kho
      context.read<StockImportBloc>().add(FetchStockImportsEvent());

      AppToast.info(
        '[SignalR Realtime] $message',
        context: context,
        duration: const Duration(seconds: 4),
      );
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    signalRService.removeStockImportUpdateListener(_onStockImportUpdate);
    super.dispose();
  }

  void _openCreateModal() {
    showDialog(
      context: context,
      builder: (ctx) => BlocProvider.value(
        value: context.read<StockImportBloc>(),
        child: const CreateImportModal(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bodyContent = BlocConsumer<StockImportBloc, StockImportState>(
      listener: (context, state) {
        if (state is StockImportActionSuccess) {
          AppToast.success(state.message, context: context);
        } else if (state is StockImportError) {
          AppToast.error(state.message, context: context);
        }
      },
      builder: (context, state) {
        if (state is StockImportLoading || state is StockImportInitial) {
          return const Center(child: CircularProgressIndicator(color: ColorPalette.appetizingOrange));
        } else if (state is StockImportsLoaded) {
          return _buildContent(state.imports);
        }
        return const Center(child: Text("Có lỗi xảy ra hoặc chưa có dữ liệu"));
      },
    );

    if (widget.embedInShell) {
      return Scaffold(
        backgroundColor: ColorPalette.webBgAdmin,
        body: bodyContent,
      );
    }

    return Scaffold(
      backgroundColor: ColorPalette.webBgAdmin,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Danh sách Phiếu Nhập Kho',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton.icon(
              onPressed: _openCreateModal,
              icon: const Icon(Icons.add),
              label: const Text('Tạo phiếu nhập mới'),
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorPalette.appetizingOrange,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          )
        ],
      ),
      body: bodyContent,
    );
  }

  Widget _buildContent(List<StockImportEntity> imports) {
    // Calculate stats (always based on total data)
    int totalImports = imports.length;
    int pendingImports = imports.where((e) => e.status == 'DRAFT').length;
    int completedImports = imports.where((e) => e.status == 'COMPLETED').length;
    double totalAmount = imports.fold(0, (sum, item) => sum + item.totalAmount);

    // Apply filters
    List<StockImportEntity> filteredImports = imports.where((item) {
      // Search Query
      bool matchesSearch = true;
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        matchesSearch = item.importCode.toLowerCase().contains(query) || 
                        item.supplierName.toLowerCase().contains(query);
      }
      
      // Filter Status
      bool matchesStatus = true;
      if (_filterStatus != 'ALL') {
        matchesStatus = item.status.toUpperCase() == _filterStatus;
      }

      // Date Filter
      bool matchesDate = true;
      if (_selectedDate != null) {
        matchesDate = item.importDate.year == _selectedDate!.year &&
                      item.importDate.month == _selectedDate!.month &&
                      item.importDate.day == _selectedDate!.day;
      }
      
      return matchesSearch && matchesStatus && matchesDate;
    }).toList();

    final totalCount = filteredImports.length;
    final totalPages = (totalCount / _pageSize).ceil().clamp(1, 999);
    if (_currentPage > totalPages) _currentPage = totalPages;
    final startIndex = (_currentPage - 1) * _pageSize;
    final endIndex = (startIndex + _pageSize).clamp(0, totalCount);
    final paginatedImports = totalCount > 0 ? filteredImports.sublist(startIndex, endIndex) : <StockImportEntity>[];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Page Header (dùng AdminPageHeader chung)
          AdminPageHeader(
            icon: Icons.inventory_2_rounded,
            title: 'Quản lý Kho & Nhập Hàng',
            subtitle: 'Theo dõi phiếu nhập kho, kiểm duyệt lô hàng và quản lý chi phí nhập nguyên vật liệu',
            addButtonText: 'Tạo phiếu nhập',
            onAddPressed: _openCreateModal,
          ),
          const SizedBox(height: 20),

          // 2. Search and Filter Bar (dùng AdminFilterBar & AdminDropdownFilter chung)
          AdminFilterBar(
            searchController: _searchController,
            searchHint: 'Tìm kiếm theo mã phiếu, nhà cung cấp...',
            onSearchChanged: (val) => setState(() => _searchQuery = val),
            onClearSearch: () => setState(() => _searchQuery = ''),
            filters: [
              AdminDropdownFilter<String>(
                value: _filterStatus,
                items: const [
                  DropdownMenuItem(value: 'ALL', child: Text('Tất cả trạng thái')),
                  DropdownMenuItem(value: 'DRAFT', child: Text('Chờ duyệt')),
                  DropdownMenuItem(value: 'COMPLETED', child: Text('Hoàn thành')),
                  DropdownMenuItem(value: 'CANCELLED', child: Text('Đã huỷ')),
                ],
                onChanged: (status) => setState(() => _filterStatus = status ?? 'ALL'),
              ),
              OutlinedButton.icon(
                onPressed: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate ?? DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  setState(() => _selectedDate = picked);
                },
                icon: const Icon(Icons.calendar_today_rounded, color: ColorPalette.appetizingOrange, size: 16),
                label: Text(
                  _selectedDate == null ? 'Chọn ngày' : DateFormat('dd/MM/yyyy').format(_selectedDate!),
                  style: const TextStyle(color: Color(0xFF1E293B), fontSize: 13, fontWeight: FontWeight.w500),
                ),
                style: OutlinedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFFBF8),
                  side: const BorderSide(color: Color(0xFFFFE0B2)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  minimumSize: const Size(0, 40),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // 3. 4 Summary Cards (dùng AdminKpiCard chung)
          LayoutBuilder(
            builder: (context, constraints) {
              final count = constraints.maxWidth >= 1000 ? 4 : (constraints.maxWidth >= 600 ? 2 : 1);
              final cardWidth = (constraints.maxWidth - (count - 1) * 16) / count;
              return Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  AdminKpiCard(
                    width: cardWidth,
                    title: 'TỔNG PHIẾU NHẬP',
                    value: totalImports.toString(),
                    subtitle: 'Tất cả phiếu nhập kho',
                    icon: Icons.receipt_long_rounded,
                    iconColor: const Color(0xFFE65100),
                    iconBg: const Color(0xFFFFF7ED),
                  ),
                  AdminKpiCard(
                    width: cardWidth,
                    title: 'CHỜ DUYỆT NHẬP',
                    value: pendingImports.toString(),
                    valueColor: const Color(0xFFD97706),
                    subtitle: 'Phiếu đang chờ xử lý',
                    subTextColor: const Color(0xFFD97706),
                    icon: Icons.pending_actions_rounded,
                    iconColor: const Color(0xFFD97706),
                    iconBg: const Color(0xFFFFFBEB),
                  ),
                  AdminKpiCard(
                    width: cardWidth,
                    title: 'HOÀN THÀNH',
                    value: completedImports.toString(),
                    valueColor: const Color(0xFF059669),
                    subtitle: 'Đã nhập kho thành công',
                    subTextColor: const Color(0xFF059669),
                    showTrendIcon: true,
                    icon: Icons.check_circle_outline_rounded,
                    iconColor: const Color(0xFF059669),
                    iconBg: const Color(0xFFECFDF5),
                  ),
                  AdminKpiCard(
                    width: cardWidth,
                    title: 'TỔNG CHI NHẬP HÀNG',
                    value: NumberFormat.currency(locale: 'vi_VN', symbol: 'đ').format(totalAmount),
                    subtitle: 'Tổng giá trị nhập hàng',
                    subTextColor: const Color(0xFF7C3AED),
                    icon: Icons.attach_money_rounded,
                    iconColor: const Color(0xFF7C3AED),
                    iconBg: const Color(0xFFF5F3FF),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 20),

          // Data Table
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E7EB)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                )
              ]
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  DataTable(
                headingRowColor: MaterialStateProperty.all(const Color(0xFFF9FAFB)),
                columns: const [
                  DataColumn(label: Text('Mã Phiếu', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Ngày Nhập', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Nhà Cung Cấp', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Mặt Hàng', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Tổng Tiền', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Trạng Thái', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Thao Tác', style: TextStyle(fontWeight: FontWeight.bold))),
                ],
                rows: paginatedImports.map((item) {
                  return DataRow(
                    cells: [
                      DataCell(Text(item.importCode, style: const TextStyle(fontWeight: FontWeight.w600))),
                      DataCell(Text(DateFormat('dd/MM/yyyy HH:mm').format(item.importDate))),
                      DataCell(Text(item.supplierName)),
                      DataCell(Text('${item.details.length} mặt hàng')),
                      DataCell(Text(
                        NumberFormat.currency(locale: 'vi_VN', symbol: 'đ').format(item.totalAmount),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      )),
                      DataCell(_buildStatusBadge(item.status)),
                      DataCell(
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove_red_eye_outlined, color: Colors.blue),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (ctx) => BlocProvider.value(
                                    value: context.read<StockImportBloc>(),
                                    child: ImportDetailModal(importEntity: item),
                                  ),
                                ],
                              )
                            ),
                          ],
                        )
                      ),
                    ]
                  );
                }).toList(),
              ),
              AppPaginationBar(
                currentPage: _currentPage,
                totalPages: totalPages,
                totalCount: totalCount,
                itemLabel: 'phiếu nhập',
                startIndex: totalCount > 0 ? startIndex + 1 : 0,
                endIndex: endIndex,
                onPageChanged: (page) => setState(() => _currentPage = page),
              ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          )
        ]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF6B7280),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bgColor;
    Color textColor;
    String text;

    switch (status.toUpperCase()) {
      case 'COMPLETED':
        bgColor = const Color(0xFFDEF7EC);
        textColor = const Color(0xFF03543F);
        text = 'Hoàn thành';
        break;
      case 'DRAFT':
        bgColor = const Color(0xFFFEF3C7);
        textColor = const Color(0xFF92400E);
        text = 'Chờ duyệt';
        break;
      case 'CANCELLED':
        bgColor = const Color(0xFFFDE8E8);
        textColor = const Color(0xFF9B1C1C);
        text = 'Đã huỷ';
        break;
      default:
        bgColor = const Color(0xFFE5E7EB);
        textColor = const Color(0xFF374151);
        text = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
