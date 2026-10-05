import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/ai_expiry/ai_expiry_bloc.dart';
import '../bloc/ai_expiry/ai_expiry_event.dart';
import '../bloc/ai_expiry/ai_expiry_state.dart';
import 'widgets/ai_insight_dialog.dart';
import '../../domain/entities/damaged_expired_record_entity.dart';
import '../../domain/entities/ai_expiry_summary_entity.dart';

class AiExpiryScreen extends StatefulWidget {
  const AiExpiryScreen({Key? key}) : super(key: key);

  @override
  _AiExpiryScreenState createState() => _AiExpiryScreenState();
}

class _AiExpiryScreenState extends State<AiExpiryScreen> {
  String _searchQuery = '';
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    // Lần gọi đầu tiên khi vừa mở màn hình
    context.read<AiExpiryBloc>().add(FetchPendingRecordsEvent());
    
    // Polling mỗi 10 giây để làm mới dữ liệu (Realtime)
    _pollingTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      context.read<AiExpiryBloc>().add(FetchPendingRecordsEvent());
    });
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF9F5), // surface
      appBar: _buildAppBar(),
      body: BlocConsumer<AiExpiryBloc, AiExpiryState>(
        listener: (context, state) {
          if (state is AiExpiryApproveSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Đã duyệt tiêu hủy & cập nhật trừ kho thành công!'),
                backgroundColor: Color(0xFFBA1A1A), // error color for delete action
                behavior: SnackBarBehavior.floating,
              ),
            );
          } else if (state is AiExpiryError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: const Color(0xFFBA1A1A)),
            );
          }
        },
        builder: (context, state) {
          AiExpirySummaryEntity? summary;
          List<DamagedExpiredRecordEntity> records = [];
          if (state is AiExpiryLoaded) {
            summary = state.summary;
            if (_searchQuery.isEmpty) {
              records = state.records;
            } else {
              records = state.records.where((r) => 
                r.productName.toLowerCase().contains(_searchQuery) || 
                r.productId.toString().contains(_searchQuery)
              ).toList();
            }
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 24),
                if (summary != null) _buildSummaryMetrics(summary),
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
          Text('Trang chủ', style: TextStyle(color: const Color(0xFF5A4138), fontSize: 12, fontWeight: FontWeight.w600)),
          const Icon(Icons.chevron_right, size: 16, color: Color(0xFFE3BFB2)),
          Text('Kho & Hàng hủy', style: TextStyle(color: const Color(0xFF5A4138), fontSize: 12, fontWeight: FontWeight.w600)),
          const Icon(Icons.chevron_right, size: 16, color: Color(0xFFE3BFB2)),
          Text('AI Expiry Insights & Write-offs', style: TextStyle(color: const Color(0xFFA43700), fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
      actions: [
        Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          width: 250,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE3BFB2).withOpacity(0.4)),
          ),
          child: const TextField(
            decoration: InputDecoration(
              hintText: 'Tìm kiếm món, kho, lô hàng...',
              hintStyle: TextStyle(fontSize: 12, color: Colors.grey),
              prefixIcon: Icon(Icons.search, size: 18, color: Color(0xFF8F7066)),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 11),
            ),
          ),
        ),
        const SizedBox(width: 16),
        const Icon(Icons.notifications, color: Color(0xFF5A4138)),
        const SizedBox(width: 16),
        Row(
          children: [
            CircleAvatar(backgroundColor: const Color(0xFFA43700), radius: 16, child: Icon(Icons.person, size: 18, color: Colors.white)),
            const SizedBox(width: 8),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('Admin Munchify', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1B1C1A))),
                Text('Quản lý hệ thống', style: TextStyle(fontSize: 11, color: Color(0xFF5A4138))),
              ],
            ),
            const SizedBox(width: 8),
            const Icon(Icons.expand_more, size: 18, color: Color(0xFF5A4138)),
          ],
        ),
        const SizedBox(width: 24),
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFA43700).withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(width: 6, height: 6, decoration: const BoxDecoration(color: Color(0xFFA43700), shape: BoxShape.circle)),
                  const SizedBox(width: 6),
                  const Text('AI REALTIME ACTIVE', style: TextStyle(color: Color(0xFFA43700), fontSize: 11, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 8),
            const Text('AI Expiry Insights & Write-offs', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: Color(0xFF1B1C1A))),
            const SizedBox(height: 4),
            const Text(
              'Giám sát cảnh báo cận date, tồn kho hết hạn và đề xuất chiến lược tối ưu hao hụt từ AI cho toàn chuỗi F&B.',
              style: TextStyle(color: Color(0xFF5A4138), fontSize: 14),
            ),
          ],
        ),
        Row(
          children: [
            // ElevatedButton.icon(
            //   onPressed: () {},
            //   icon: const Icon(Icons.file_download, size: 18, color: Color(0xFF5A4138)),
            //   label: const Text('Xuất báo cáo hao hụt', style: TextStyle(color: Color(0xFF1B1C1A))),
            //   style: ElevatedButton.styleFrom(
            //     backgroundColor: Colors.white,
            //     elevation: 1,
            //     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            //   ),
            // ),
            // const SizedBox(width: 12),
            // ElevatedButton.icon(
            //   onPressed: () {},
            //   icon: const Icon(Icons.done_all, size: 18, color: Colors.white),
            //   label: const Text('Duyệt nhanh tất cả (Batch Approve)', style: TextStyle(color: Colors.white)),
            //   style: ElevatedButton.styleFrom(
            //     backgroundColor: const Color(0xFFA43700),
            //     elevation: 2,
            //     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            //   ),
            // ),
          ],
        )
      ],
    );
  }

  Widget _buildSummaryMetrics(AiExpirySummaryEntity summary) {
    return Row(
      children: [
        Expanded(
          child: _buildMetricCard(
            title: 'Total Pending Alerts',
            value: '${summary.totalPendingAlerts} lô cảnh báo',
            icon: Icons.warning,
            iconColor: const Color(0xFFBA1A1A),
            iconBg: const Color(0xFFFFDAD6),
            bottomWidget: Row(
              children: [
                Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFFBA1A1A), shape: BoxShape.circle)),
                const SizedBox(width: 8),
                Text('${summary.urgentPendingAlerts} lô cần tiêu hủy khẩn cấp', style: const TextStyle(color: Color(0xFFBA1A1A), fontSize: 11, fontWeight: FontWeight.bold)),
                const Spacer(),
                const Text('Ưu tiên cao', style: TextStyle(color: Color(0xFF5A4138), fontSize: 12)),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildMetricCard(
            title: 'Est. Financial Loss',
            value: '\$${summary.estFinancialLoss.toStringAsFixed(2)}',
            icon: Icons.trending_up,
            iconColor: const Color(0xFF7E5700),
            iconBg: const Color(0xFFFEB300).withOpacity(0.4),
            bottomWidget: Row(
              children: [
                Icon(summary.lossTrendPercent >= 0 ? Icons.arrow_upward : Icons.arrow_downward, size: 16, color: const Color(0xFFA43700)),
                const SizedBox(width: 4),
                Text('${summary.lossTrendPercent >= 0 ? '+' : ''}${summary.lossTrendPercent}%', style: const TextStyle(color: Color(0xFFA43700), fontSize: 11, fontWeight: FontWeight.bold)),
                const SizedBox(width: 6),
                const Text('so với tuần trước', style: TextStyle(color: Color(0xFF5A4138), fontSize: 12)),
                const Spacer(),
                const Text('Q1/2026', style: TextStyle(color: Color(0xFF5A4138), fontSize: 11, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildMetricCard(
            title: 'Auto-resolved This Month',
            value: '${summary.autoResolvedThisMonth} lô đã xử lý',
            icon: Icons.task_alt,
            iconColor: const Color(0xFF005AB7),
            iconBg: const Color(0xFFD7E2FF),
            bottomWidget: Row(
              children: [
                const Icon(Icons.check_circle_outline, size: 16, color: Color(0xFF005AB7)),
                const SizedBox(width: 6),
                const Text('Đã trừ tồn kho tự động', style: TextStyle(color: Color(0xFF1B1C1A), fontSize: 11, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required Widget bottomWidget,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title.toUpperCase(), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF5A4138), letterSpacing: 0.5)),
                    const SizedBox(height: 4),
                    Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Color(0xFF1B1C1A))),
                  ],
                ),
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(12)),
                  child: Icon(icon, color: iconColor, size: 26),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: const BoxDecoration(
              color: Color(0xFFF5F3EF),
              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(12), bottomRight: Radius.circular(12)),
            ),
            child: bottomWidget,
          )
        ],
      ),
    );
  }

  Widget _buildDataTable(AiExpiryState state, List<DamagedExpiredRecordEntity> records) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          // Toolbar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F3EF).withOpacity(0.4),
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 280,
                      height: 40,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                      child: TextField(
                        decoration: const InputDecoration(
                          icon: Icon(Icons.search, size: 18, color: Color(0xFF8F7066)),
                          hintText: 'Tìm kiếm tên sản phẩm, mã lô...',
                          hintStyle: TextStyle(fontSize: 12, color: Colors.grey),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 12),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value.toLowerCase();
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    _buildFilterBtn('Tất cả kho (5 chi nhánh)', Icons.store, false),
                    const SizedBox(width: 12),
                    _buildFilterBtn('Hết hạn trong 7 ngày', Icons.date_range, true),
                  ],
                ),
              ],
            ),
          ),
          // Table header
          _buildTableHeader(),
          // Table contents
          if (state is AiExpiryLoading)
            const Padding(padding: EdgeInsets.all(40), child: Center(child: CircularProgressIndicator(color: Color(0xFFA43700))))
          else if (records.isEmpty)
            const Padding(padding: EdgeInsets.all(40), child: Center(child: Text('Không có dữ liệu cảnh báo.')))
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: records.length,
              separatorBuilder: (context, index) => const Divider(height: 1, color: Color(0xFFE4E2DE)),
              itemBuilder: (context, index) {
                final record = records[index];
                return _buildTableRow(record);
              },
            ),
          // Footer
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFFF5F3EF),
              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(12), bottomRight: Radius.circular(12)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Đang hiển thị 1 - ${records.length} trên tổng số ${records.length} lô cần quyết định', style: const TextStyle(fontSize: 12, color: Color(0xFF5A4138))),
                Row(
                  children: [
                    Container(width: 32, height: 32, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.chevron_left, size: 18, color: Colors.grey)),
                    const SizedBox(width: 4),
                    Container(width: 32, height: 32, decoration: BoxDecoration(color: const Color(0xFFA43700), borderRadius: BorderRadius.circular(8)), child: const Center(child: Text('1', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))),
                    const SizedBox(width: 4),
                    Container(width: 32, height: 32, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.chevron_right, size: 18, color: Color(0xFF5A4138))),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildFilterBtn(String text, IconData icon, bool isPrimary) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
      child: Row(
        children: [
          Icon(icon, size: 18, color: isPrimary ? const Color(0xFFA43700) : const Color(0xFF5A4138)),
          const SizedBox(width: 8),
          Text(text, style: TextStyle(fontSize: 12, fontWeight: isPrimary ? FontWeight.bold : FontWeight.normal, color: isPrimary ? const Color(0xFFA43700) : const Color(0xFF1B1C1A))),
        ],
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Color(0xFFFBF9F5),
        border: Border(bottom: BorderSide(color: Color(0xFFE4E2DE))),
      ),
      child: Row(
        children: [
          const SizedBox(width: 36), // For Checkbox
          Expanded(flex: 3, child: Text('TÊN SẢN PHẨM', style: _headerStyle)),
          Expanded(flex: 2, child: Text('MÃ LÔ / NGÀY TẠO', style: _headerStyle)),
          Expanded(flex: 2, child: Text('TÌNH TRẠNG', style: _headerStyle)),
          Expanded(flex: 1, child: Align(alignment: Alignment.centerRight, child: Text('S.LƯỢNG', style: _headerStyle))),
          Expanded(flex: 1, child: Center(child: Text('TRẠNG THÁI', style: _headerStyle))),
          Expanded(flex: 2, child: Align(alignment: Alignment.centerRight, child: Text('HÀNH ĐỘNG', style: _headerStyle))),
        ],
      ),
    );
  }

  static const _headerStyle = TextStyle(
    color: Color(0xFF8F7066),
    fontSize: 11,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.5,
  );

  Widget _buildTableRow(DamagedExpiredRecordEntity record) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          const Icon(Icons.check_box, color: Color(0xFFA43700), size: 20),
          const SizedBox(width: 16),
          // Product Info
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(color: const Color(0xFFEAE8E4), borderRadius: BorderRadius.circular(8)),
                  child: const Icon(Icons.inventory, color: Color(0xFFA43700)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(record.productName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1B1C1A))),
                      Row(
                        children: [
                          Text('#P${record.productId.toString().padLeft(3, '0')}', style: const TextStyle(fontSize: 11, fontFamily: 'monospace', color: Color(0xFF5A4138))),
                          const SizedBox(width: 8),
                          Container(width: 4, height: 4, decoration: const BoxDecoration(color: Color(0xFFE3BFB2), shape: BoxShape.circle)),
                          const SizedBox(width: 8),
                          const Text('Kho Tổng', style: TextStyle(fontSize: 11, color: Color(0xFF5A4138))),
                        ],
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
          // Batch Info
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('BATCH-${record.createdAt.year}-P${record.productId}', style: const TextStyle(fontSize: 14, fontFamily: 'monospace', fontWeight: FontWeight.w500, color: Color(0xFF1B1C1A))),
                Text('Tạo ${record.createdAt.day.toString().padLeft(2, '0')}/${record.createdAt.month.toString().padLeft(2, '0')}/${record.createdAt.year}', style: const TextStyle(fontSize: 11, color: Color(0xFF5A4138))),
              ],
            ),
          ),
          // Expiry Info
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: const Color(0xFFFFDAD6).withOpacity(0.6), borderRadius: BorderRadius.circular(16)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(width: 6, height: 6, decoration: const BoxDecoration(color: Color(0xFFBA1A1A), shape: BoxShape.circle)),
                  const SizedBox(width: 6),
                  const Text('Quá hạn / Hết đát', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF93000A))),
                ],
              ),
            ),
          ),
          // Quantity
          Expanded(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('${record.quantity} ${record.unitName}', style: const TextStyle(fontSize: 16, fontFamily: 'monospace', fontWeight: FontWeight.bold, color: Color(0xFFBA1A1A))),
              ],
            ),
          ),
          // Status
          Expanded(
            flex: 1,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: const Color(0xFFFEB300).withOpacity(0.3), borderRadius: BorderRadius.circular(16)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFF7E5700), shape: BoxShape.circle)),
                    const SizedBox(width: 6),
                    const Text('Pending', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF6A4800))),
                  ],
                ),
              ),
            ),
          ),
          // Actions
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => AiInsightDialog(record: record),
                  ).then((approved) {
                    if (approved == true) {
                      context.read<AiExpiryBloc>().add(ApproveRecordEvent(record.recordId));
                    }
                  });
                },
                icon: const Icon(Icons.auto_awesome, size: 16, color: Colors.white),
                label: const Text('✨ AI Insights', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFA43700),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
