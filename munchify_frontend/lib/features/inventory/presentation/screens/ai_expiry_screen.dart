import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/ai_expiry/ai_expiry_bloc.dart';
import '../bloc/ai_expiry/ai_expiry_event.dart';
import '../bloc/ai_expiry/ai_expiry_state.dart';
import 'widgets/ai_insight_dialog.dart';
import '../../domain/entities/damaged_expired_record_entity.dart';
import '../../../../core/widgets/app_pagination_bar.dart';
import '../../domain/entities/ai_expiry_summary_entity.dart';
import '../../../../core/services/signalr_service.dart';
import '../../../../core/widgets/app_toast.dart';

class AiExpiryScreen extends StatefulWidget {
  final bool embedInShell;
  const AiExpiryScreen({Key? key, this.embedInShell = false}) : super(key: key);

  @override
  _AiExpiryScreenState createState() => _AiExpiryScreenState();
}

class _AiExpiryScreenState extends State<AiExpiryScreen> {
  String _searchQuery = '';
  String _filterStatus = 'ALL'; // 'ALL', 'PENDING', 'APPROVED', 'REJECTED'
  int _currentPage = 1;
  static const int _pageSize = 10;

  @override
  void initState() {
    super.initState();
    // Lần gọi đầu tiên khi vừa mở màn hình
    context.read<AiExpiryBloc>().add(FetchPendingRecordsEvent());
    
    // Tích hợp SignalR: Lắng nghe sự kiện phát hiện hàng cận/quá hạn từ Server theo thời gian thực
    signalRService.onExpiryAlert(_onSignalRAlert);
  }

  void _onSignalRAlert(String message) {
    if (mounted) {
      // Tự động làm mới danh sách dữ liệu ngay lập tức
      context.read<AiExpiryBloc>().add(FetchPendingRecordsEvent());

      AppToast.warning(
        '[SignalR Realtime] $message',
        context: context,
        duration: const Duration(seconds: 4),
      );
    }
  }

  @override
  void dispose() {
    signalRService.removeExpiryAlertListener(_onSignalRAlert);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF9F5), // surface
      appBar: widget.embedInShell ? null : _buildAppBar(),
      body: BlocConsumer<AiExpiryBloc, AiExpiryState>(
        listener: (context, state) {
          if (state is AiExpiryApproveSuccess) {
            AppToast.success('Đã duyệt tiêu hủy & cập nhật trừ kho thành công!', context: context);
          } else if (state is AiExpiryError) {
            AppToast.error(state.message, context: context);
          }
        },
        builder: (context, state) {
          AiExpirySummaryEntity? summary;
          List<DamagedExpiredRecordEntity> records = [];
          if (state is AiExpiryLoaded) {
            summary = state.summary;
            records = state.records.where((r) {
              // Lọc theo search
              final matchSearch = _searchQuery.isEmpty || 
                  r.productName.toLowerCase().contains(_searchQuery) || 
                  r.productId.toString().contains(_searchQuery);
              
              // Lọc theo trạng thái
              final matchStatus = _filterStatus == 'ALL' || r.status.toUpperCase() == _filterStatus;

              return matchSearch && matchStatus;
            }).toList();
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

      ],
    );
  }

  Widget _buildSummaryMetrics(AiExpirySummaryEntity summary) {
    return Row(
      children: [
        Expanded(
          child: _buildMetricCard(
            title: 'Tổng số cảnh báo đang chờ xử lý',
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
            title: 'Ước tính thiệt hại tài chính',
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
            title: 'Đã tự động giải quyết trong tháng này',
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
    final totalCount = records.length;
    final totalPages = (totalCount / _pageSize).ceil().clamp(1, 999);
    if (_currentPage > totalPages) _currentPage = totalPages;
    final startIndex = (_currentPage - 1) * _pageSize;
    final endIndex = (startIndex + _pageSize).clamp(0, totalCount);
    final paginatedRecords = totalCount > 0 ? records.sublist(startIndex, endIndex) : <DamagedExpiredRecordEntity>[];

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
                    _buildFilterBtn('Tất cả kho', Icons.store, false),
                  ],
                ),
                // Tab lọc trạng thái
                Container(
                  height: 40,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE4E2DE)),
                  ),
                  child: Row(
                    children: [
                      _buildStatusTab('Tất cả', 'ALL'),
                      _buildStatusTab('Chờ duyệt (Pending)', 'PENDING'),
                      _buildStatusTab('Đã trừ kho (Approved)', 'APPROVED'),
                    ],
                  ),
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
              itemCount: paginatedRecords.length,
              separatorBuilder: (context, index) => const Divider(height: 1, color: Color(0xFFE4E2DE)),
              itemBuilder: (context, index) {
                final record = paginatedRecords[index];
                return _buildTableRow(record);
              },
            ),
          // Footer
          AppPaginationBar(
            currentPage: _currentPage,
            totalPages: totalPages,
            totalCount: totalCount,
            itemLabel: 'lô cần quyết định',
            startIndex: totalCount > 0 ? startIndex + 1 : 0,
            endIndex: endIndex,
            onPageChanged: (page) => setState(() => _currentPage = page),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusTab(String title, String status) {
    final isSelected = _filterStatus == status;
    return InkWell(
      onTap: () {
        setState(() {
          _filterStatus = status;
        });
      },
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFA43700) : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? Colors.white : const Color(0xFF5A4138),
          ),
        ),
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
              child: _buildRecordStatusBadge(record.status),
            ),
          ),
          // Actions
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerRight,
              child: record.status == 'APPROVED'
                  ? Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDEF7EC),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFF31C48D).withOpacity(0.3)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_circle, size: 16, color: Color(0xFF03543F)),
                          SizedBox(width: 6),
                          Text(
                            'Đã duyệt hủy kho',
                            style: TextStyle(
                              color: Color(0xFF03543F),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ElevatedButton.icon(
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
                      label: const Text('AI phân tích', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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

  Widget _buildRecordStatusBadge(String status) {
    Color bgColor;
    Color dotColor;
    Color textColor;
    String label;

    switch (status.toUpperCase()) {
      case 'APPROVED':
        bgColor = const Color(0xFFDEF7EC);
        dotColor = const Color(0xFF31C48D);
        textColor = const Color(0xFF03543F);
        label = 'Đã trừ kho';
        break;
      case 'REJECTED':
        bgColor = const Color(0xFFFDE8E8);
        dotColor = const Color(0xFFF98080);
        textColor = const Color(0xFF9B1C1C);
        label = 'Đã hủy';
        break;
      case 'PENDING':
      default:
        bgColor = const Color(0xFFFEB300).withOpacity(0.3);
        dotColor = const Color(0xFF7E5700);
        textColor = const Color(0xFF6A4800);
        label = 'Chờ duyệt';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(16)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 8, height: 8, decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: textColor)),
        ],
      ),
    );
  }
}
