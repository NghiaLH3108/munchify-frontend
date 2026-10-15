import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/low_stock/low_stock_bloc.dart';
import '../bloc/low_stock/low_stock_event.dart';
import '../bloc/low_stock/low_stock_state.dart';
import '../../domain/entities/forecast_item_entity.dart';
import '../../../../core/services/signalr_service.dart';

class LowStockScreen extends StatefulWidget {
  final bool embedInShell;
  const LowStockScreen({Key? key, this.embedInShell = false}) : super(key: key);

  @override
  _LowStockScreenState createState() => _LowStockScreenState();
}

class _LowStockScreenState extends State<LowStockScreen> {
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    context.read<LowStockBloc>().add(const FetchLowStockWarningEvent());
    
    // Tích hợp SignalR: Lắng nghe cảnh báo tồn kho sắp hết từ Server theo thời gian thực
    signalRService.onLowStockWarning(_onLowStockWarning);
  }

  void _onLowStockWarning(String message) {
    if (mounted) {
      // Tự động làm mới danh sách dữ liệu dự báo & cảnh báo
      context.read<LowStockBloc>().add(const FetchLowStockWarningEvent());

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: Colors.orangeAccent, size: 20),
              const SizedBox(width: 8),
              Expanded(child: Text('[SignalR Realtime] $message')),
            ],
          ),
          backgroundColor: const Color(0xFF1B1C1A),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  @override
  void dispose() {
    signalRService.removeLowStockWarningListener(_onLowStockWarning);
    super.dispose();
  }

  void _generateDraftImport(List<ForecastItemEntity> items) {
    if (items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không có sản phẩm nào cần nhập.')),
      );
      return;
    }

    // Chỉ lấy sản phẩm có suggestedImportQty > 0
    final actionableItems = items.where((i) => i.suggestedImportQty > 0).toList();
    if (actionableItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tất cả sản phẩm đều đã có phiếu nhập đang chờ xử lý.')),
      );
      return;
    }

    // Nhóm theo supplier
    final Map<String, List<ForecastItemEntity>> groupedBySupplier = {};
    for (final item in actionableItems) {
      final supplierKey = item.defaultSupplierId != null
          ? (item.defaultSupplierName ?? 'Nhà cung cấp #${item.defaultSupplierId}')
          : 'Chưa có nhà cung cấp mặc định';
      groupedBySupplier.putIfAbsent(supplierKey, () => []).add(item);
    }

    final now = DateTime.now();
    final timestamp = '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}'
        '${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}';

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(28.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF386A20).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.assignment_add, color: Color(0xFF386A20), size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Xác nhận tạo phiếu nhập nháp',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1B1C1A),
                          ),
                        ),
                        Text(
                          'Sẽ tạo ${groupedBySupplier.length} phiếu nhập cho ${actionableItems.length} sản phẩm',
                          style: const TextStyle(fontSize: 13, color: Color(0xFF7A7570)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Divider(color: Color(0xFFE2E2E2)),
              const SizedBox(height: 16),

              // Danh sách phiếu sẽ được tạo
              ...groupedBySupplier.entries.toList().asMap().entries.map((entry) {
                final idx = entry.key;
                final supplierName = entry.value.key;
                final supplierItems = entry.value.value;
                final supplierId = supplierItems.first.defaultSupplierId ?? 1;
                final draftCode = 'IMP-AUTO-$timestamp-$supplierId';

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F3EF),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E2E2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFF386A20),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'Phiếu ${idx + 1}',
                              style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              supplierName,
                              style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF1B1C1A), fontSize: 14),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.tag, size: 13, color: Color(0xFF7A7570)),
                          const SizedBox(width: 4),
                          Text(
                            'Mã đơn: $draftCode',
                            style: const TextStyle(fontSize: 12, color: Color(0xFF7A7570), fontFamily: 'monospace'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: supplierItems.map((item) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: const Color(0xFFE2E2E2)),
                          ),
                          child: Text(
                            '${item.productName} (+${item.suggestedImportQty.toInt()} ${item.unitName})',
                            style: const TextStyle(fontSize: 12, color: Color(0xFF1B1C1A)),
                          ),
                        )).toList(),
                      ),
                    ],
                  ),
                );
              }).toList(),

              const SizedBox(height: 8),
              // Note
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF8E1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFFFE082)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, size: 14, color: Color(0xFFD46B08)),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Các phiếu nhập sẽ ở trạng thái NHÁP. Bạn có thể chỉnh sửa giá và xác nhận sau.',
                        style: TextStyle(fontSize: 12, color: Color(0xFFD46B08)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    style: TextButton.styleFrom(foregroundColor: const Color(0xFF7A7570)),
                    child: const Text('Hủy'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      context.read<LowStockBloc>().add(GenerateDraftImportsEvent(actionableItems));
                    },
                    icon: const Icon(Icons.check_rounded, size: 18),
                    label: Text('Tạo ${groupedBySupplier.length} phiếu nhập'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF386A20),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF9F5), // surface
      appBar: widget.embedInShell ? null : _buildAppBar(),
      body: BlocConsumer<LowStockBloc, LowStockState>(
        listener: (context, state) {
          if (state is DraftImportGeneratedSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Đã tạo phiếu nhập nháp thành công!'),
                backgroundColor: Color(0xFF386A20), 
                behavior: SnackBarBehavior.floating,
              ),
            );
          } else if (state is LowStockError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: const Color(0xFFBA1A1A)),
            );
          } else if (state is DraftImportGeneratedError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: const Color(0xFFBA1A1A)),
            );
          }
        },
        builder: (context, state) {
          List<ForecastItemEntity> records = [];
          
          if (state is LowStockLoaded) {
            if (_searchQuery.isEmpty) {
              records = state.forecastItems;
            } else {
              records = state.forecastItems.where((r) => 
                r.productName.toLowerCase().contains(_searchQuery.toLowerCase()) || 
                r.productId.toString().contains(_searchQuery)
              ).toList();
            }
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(records),
                const SizedBox(height: 32),
                _buildDataTable(state, records),
              ],
            ),
          );
        },
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFFFBF9F5).withOpacity(0.9),
      elevation: 1,
      shadowColor: Colors.black.withOpacity(0.1),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFFFB4AB).withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.trending_down_rounded,
              color: Color(0xFFBA1A1A),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'AI Low Stock Warning',
                style: TextStyle(
                  color: Color(0xFF1B1C1A),
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
              ),
              Text(
                'Dự báo tồn kho & Đề xuất nhập hàng',
                style: TextStyle(
                  color: Color(0xFF5A4138),
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              const Icon(Icons.circle, size: 8, color: Color(0xFF386A20)),
              const SizedBox(width: 8),
              Text(
                'Auto-sync: 10s',
                style: TextStyle(color: const Color(0xFF1B1C1A).withOpacity(0.6), fontSize: 13),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(List<ForecastItemEntity> records) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            SizedBox(
              width: 320,
              child: TextField(
                onChanged: (value) => setState(() => _searchQuery = value),
                decoration: InputDecoration(
                  hintText: 'Tìm theo mã, tên món...',
                  hintStyle: const TextStyle(color: Color(0xFF7A7570)),
                  prefixIcon: const Icon(Icons.search, color: Color(0xFF7A7570)),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: const BorderSide(color: Color(0xFFE2E2E2)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: const BorderSide(color: Color(0xFFE2E2E2)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: const BorderSide(color: Color(0xFF386A20), width: 2),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFE2E2E2)),
              ),
              child: const Text('Rủi ro (Critical)'),
            ),
          ],
        ),
        ElevatedButton.icon(
          onPressed: () => _generateDraftImport(records),
          icon: const Icon(Icons.auto_awesome),
          label: const Text('1-Click Tạo Phiếu Nhập'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF386A20),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            elevation: 0,
          ),
        ),
      ],
    );
  }

  Widget _buildDataTable(LowStockState state, List<ForecastItemEntity> records) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E2E2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildTableHeader(),
          if (state is LowStockLoading && records.isEmpty)
            const Padding(
              padding: EdgeInsets.all(40),
              child: Center(
                child: CircularProgressIndicator(color: Color(0xFF386A20)),
              ),
            )
          else if (records.isEmpty)
            Padding(
              padding: const EdgeInsets.all(40),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.inventory_2_outlined, size: 48, color: const Color(0xFF7A7570).withOpacity(0.5)),
                    const SizedBox(height: 16),
                    Text(
                      'Tất cả hàng hóa đều an toàn. Không có cảnh báo nào!',
                      style: TextStyle(color: const Color(0xFF7A7570).withOpacity(0.8), fontSize: 16),
                    ),
                  ],
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: records.length,
              separatorBuilder: (context, index) => Divider(height: 1, color: const Color(0xFFE2E2E2).withOpacity(0.5)),
              itemBuilder: (context, index) {
                return _buildTableRow(records[index], index % 2 == 1);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: const BoxDecoration(
        color: Color(0xFFF5F3EF),
        borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
      ),
      child: Row(
        children: [
          const SizedBox(width: 80, child: Text('Mã HH', style: _headerStyle)),
          const Expanded(flex: 3, child: Text('Tên sản phẩm', style: _headerStyle)),
          const Expanded(flex: 2, child: Text('Kho hiện tại', style: _headerStyle)),
          const Expanded(flex: 2, child: Text('Tốc độ bán (30d)', style: _headerStyle)),
          const Expanded(flex: 2, child: Text('Dự kiến cạn kho', style: _headerStyle)),
          const Expanded(flex: 2, child: Text('AI Khuyên Nhập', style: _headerStyle)),
          const SizedBox(width: 100, child: Text('Mức độ', style: _headerStyle)),
        ],
      ),
    );
  }

  static const _headerStyle = TextStyle(
    color: Color(0xFF7A7570),
    fontSize: 13,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.2,
  );

  Widget _buildTableRow(ForecastItemEntity record, bool isEven) {
    bool isCritical = record.riskLevel == 'CRITICAL';
    bool isOrdered = record.riskLevel == 'ORDERED';
    
    return Container(
      color: isEven ? const Color(0xFFFBF9F5).withOpacity(0.5) : Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(
          children: [
            SizedBox(
              width: 80,
              child: Text(
                '#${record.productId}',
                style: const TextStyle(color: Color(0xFF7A7570), fontWeight: FontWeight.w500, fontSize: 13),
              ),
            ),
            Expanded(
              flex: 3,
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2E2E2).withOpacity(0.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.inventory_2, size: 16, color: Color(0xFF7A7570)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      record.productName,
                      style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF1B1C1A)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                '${record.stockQuantity} ${record.unitName}',
                style: const TextStyle(fontWeight: FontWeight.w500, color: Color(0xFF1B1C1A)),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                '${record.avgDailyUsage} /ngày',
                style: const TextStyle(fontWeight: FontWeight.w500, color: Color(0xFF1B1C1A)),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                record.daysRemaining > 100 ? 'Rất an toàn' : 'Còn ~${record.daysRemaining} ngày',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: isCritical ? const Color(0xFFBA1A1A) : const Color(0xFFD46B08),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: isOrdered
                  ? const Row(
                      children: [
                        Icon(Icons.check_circle, size: 14, color: Color(0xFF386A20)),
                        SizedBox(width: 6),
                        Text(
                          'Hàng đang về',
                          style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF386A20), fontSize: 13),
                        ),
                      ],
                    )
                  : Row(
                      children: [
                        const Icon(Icons.auto_awesome, size: 14, color: Color(0xFF386A20)),
                        const SizedBox(width: 6),
                        Text(
                          '+${record.suggestedImportQty} ${record.unitName}',
                          style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF386A20), fontSize: 15),
                        ),
                      ],
                    ),
            ),
            SizedBox(
              width: 100,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isCritical 
                      ? const Color(0xFFFFB4AB).withOpacity(0.2) 
                      : (isOrdered ? const Color(0xFFC4EED0).withOpacity(0.3) : const Color(0xFFFFE58F).withOpacity(0.2)),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isCritical 
                        ? const Color(0xFFFFB4AB) 
                        : (isOrdered ? const Color(0xFF386A20).withOpacity(0.3) : const Color(0xFFFFE58F))
                  ),
                ),
                child: Text(
                  record.riskLevel,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isCritical 
                        ? const Color(0xFFBA1A1A) 
                        : (isOrdered ? const Color(0xFF386A20) : const Color(0xFFD46B08)),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
