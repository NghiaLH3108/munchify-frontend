import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../bloc/stock_import_bloc.dart';
import '../bloc/stock_import_event.dart';
import '../bloc/stock_import_state.dart';
import '../../domain/entities/stock_import_entity.dart';
import '../widgets/create_import_modal.dart';
import '../widgets/import_detail_modal.dart';
import '../../../../../core/theme/ColorPalette.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  String _searchQuery = '';
  String _filterStatus = 'ALL';
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    context.read<StockImportBloc>().add(FetchStockImportsEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
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
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => BlocProvider.value(
                    value: context.read<StockImportBloc>(),
                    child: const CreateImportModal(),
                  ),
                );
              },
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
      body: BlocConsumer<StockImportBloc, StockImportState>(
        listener: (context, state) {
          if (state is StockImportActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.green),
            );
          } else if (state is StockImportError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
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
      ),
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

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 4 Summary Cards
          Row(
            children: [
              Expanded(child: _buildStatCard('Tổng phiếu nhập', totalImports.toString(), Icons.receipt_long, Colors.blue)),
              const SizedBox(width: 16),
              Expanded(child: _buildStatCard('Chờ duyệt nhập', pendingImports.toString(), Icons.pending_actions, Colors.orange)),
              const SizedBox(width: 16),
              Expanded(child: _buildStatCard('Hoàn thành', completedImports.toString(), Icons.check_circle_outline, Colors.green)),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'Tổng chi nhập hàng',
                  NumberFormat.currency(locale: 'vi_VN', symbol: 'đ').format(totalAmount),
                  Icons.attach_money,
                  Colors.purple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Search and Filter Bar
          Row(
            children: [
              Expanded(
                child: TextField(
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Tìm kiếm theo mã phiếu, nhà cung cấp...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              PopupMenuButton<String>(
                initialValue: _filterStatus,
                onSelected: (String status) {
                  setState(() {
                    _filterStatus = status;
                  });
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  const PopupMenuItem<String>(value: 'ALL', child: Text('Tất cả trạng thái')),
                  const PopupMenuItem<String>(value: 'DRAFT', child: Text('Chờ duyệt')),
                  const PopupMenuItem<String>(value: 'COMPLETED', child: Text('Hoàn thành')),
                  const PopupMenuItem<String>(value: 'CANCELLED', child: Text('Đã huỷ')),
                ],
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.filter_list, color: Colors.black87, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        _filterStatus == 'ALL' ? 'Lọc trạng thái' : 
                        _filterStatus == 'DRAFT' ? 'Chờ duyệt' : 
                        _filterStatus == 'COMPLETED' ? 'Hoàn thành' : 'Đã huỷ',
                        style: const TextStyle(color: Colors.black87)
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                onPressed: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate ?? DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (picked != null) {
                    setState(() {
                      _selectedDate = picked;
                    });
                  } else {
                    // If they dismiss, we clear the date filter
                    setState(() {
                      _selectedDate = null;
                    });
                  }
                },
                icon: const Icon(Icons.calendar_today, color: Colors.black87, size: 18),
                label: Text(
                  _selectedDate == null ? 'Chọn ngày' : DateFormat('dd/MM/yyyy').format(_selectedDate!), 
                  style: const TextStyle(color: Colors.black87)
                ),
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.white,
                  side: const BorderSide(color: Color(0xFFE5E7EB)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

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
              child: DataTable(
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
                rows: filteredImports.map((item) {
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
                                );
                              },
                              tooltip: 'Xem chi tiết',
                            ),
                          ],
                        )
                      ),
                    ]
                  );
                }).toList(),
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
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              )
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
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
