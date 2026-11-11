import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/ai_expiry/ai_expiry_bloc.dart';
import '../bloc/ai_expiry/ai_expiry_event.dart';
import '../bloc/ai_expiry/ai_expiry_state.dart';
import '../widgets/ai_insight_dialog.dart';
import '../../domain/entities/damaged_expired_record_entity.dart';
import '../../../../core/widgets/app_pagination_bar.dart';
import '../../domain/entities/ai_expiry_summary_entity.dart';
import '../../../../core/services/signalr_service.dart';
import '../../../../core/theme/ColorPalette.dart';
import '../../../../core/utils/CurrencyFormatter.dart';
import '../../../../core/widgets/admin/admin_widgets.dart';
import '../../../../core/widgets/app_toast.dart';

class AiExpiryScreen extends StatefulWidget {
  final bool embedInShell;
  const AiExpiryScreen({Key? key, this.embedInShell = false}) : super(key: key);

  @override
  _AiExpiryScreenState createState() => _AiExpiryScreenState();
}

class _AiExpiryScreenState extends State<AiExpiryScreen> {
  final TextEditingController _searchController = TextEditingController();
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
    _searchController.dispose();
    signalRService.removeExpiryAlertListener(_onSignalRAlert);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorPalette.webBgAdmin,
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
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(),
                const SizedBox(height: 20),
                _buildFilterBar(),
                const SizedBox(height: 20),
                if (summary != null) ...[
                  _buildSummaryMetrics(summary),
                  const SizedBox(height: 20),
                ],
                _buildDataTable(state, records),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return AdminPageHeader(
      icon: Icons.auto_awesome_rounded,
      title: 'AI Expiry Insights & Write-offs',
      subtitle: 'Giám sát cảnh báo cận date, tồn kho hết hạn và đề xuất chiến lược tối ưu hao hụt từ AI cho toàn chuỗi F&B.',
      extraActions: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFA43700).withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 6, height: 6, decoration: const BoxDecoration(color: Color(0xFFA43700), shape: BoxShape.circle)),
              const SizedBox(width: 6),
              const Text('AI REALTIME ACTIVE', style: TextStyle(color: Color(0xFFA43700), fontSize: 11, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFilterBar() {
    return AdminFilterBar(
      searchController: _searchController,
      searchHint: 'Tìm kiếm tên sản phẩm, mã lô...',
      onSearchChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
      onClearSearch: () => setState(() => _searchQuery = ''),
      filters: [
        AdminDropdownFilter<String>(
          value: _filterStatus,
          items: const [
            DropdownMenuItem(value: 'ALL', child: Text('Tất cả trạng thái')),
            DropdownMenuItem(value: 'PENDING', child: Text('Chờ duyệt (Pending)')),
            DropdownMenuItem(value: 'APPROVED', child: Text('Đã trừ kho (Approved)')),
          ],
          onChanged: (val) => setState(() => _filterStatus = val ?? 'ALL'),
        ),
      ],
    );
  }

  Widget _buildSummaryMetrics(AiExpirySummaryEntity summary) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 768;
        final cardWidth = isWide ? (constraints.maxWidth - 32) / 3 : constraints.maxWidth;

        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            AdminKpiCard(
              width: cardWidth,
              title: 'TỔNG SỐ CẢNH BÁO ĐANG CHỜ XỬ LÝ',
              value: '${summary.totalPendingAlerts} lô cảnh báo',
              subtitle: 'Cần kiểm tra & phê duyệt xử lý',
              subTextColor: const Color(0xFFBA1A1A),
              isWarning: summary.totalPendingAlerts > 0,
              icon: Icons.warning_rounded,
              iconColor: const Color(0xFFBA1A1A),
              iconBg: const Color(0xFFFFDAD6),
            ),
            AdminKpiCard(
              width: cardWidth,
              title: 'ƯỚC TÍNH THIỆT HẠI TÀI CHÍNH',
              value: CurrencyFormatter.format(summary.estFinancialLoss),
              subtitle: 'Giá trị hàng cận date & hư hỏng',
              subTextColor: const Color(0xFFD97706),
              showTrendIcon: true,
              trendPositive: false,
              icon: Icons.trending_up_rounded,
              iconColor: const Color(0xFF7E5700),
              iconBg: const Color(0xFFFEF3C7),
            ),
            AdminKpiCard(
              width: cardWidth,
              title: 'ĐÃ TỰ ĐỘNG GIẢI QUYẾT TRONG THÁNG NÀY',
              value: '${summary.autoResolvedThisMonth} lô đã xử lý',
              subtitle: 'Đã duyệt tiêu hủy & đồng bộ kho',
              subTextColor: const Color(0xFF059669),
              showTrendIcon: true,
              trendPositive: true,
              icon: Icons.task_alt_rounded,
              iconColor: const Color(0xFF005AB7),
              iconBg: const Color(0xFFD7E2FF),
            ),
          ],
        );
      },
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
                Text(
                  record.batchCode ??
                      (record.importDetailId != null
                          ? 'IMP-${record.importDetailId.toString().padLeft(3, '0')}'
                          : 'LÔ-P${record.productId.toString().padLeft(3, '0')}'),
                  style: const TextStyle(fontSize: 14, fontFamily: 'monospace', fontWeight: FontWeight.bold, color: Color(0xFF1B1C1A)),
                ),
                Text('Tạo ${_formatDate(record.createdAt)}', style: const TextStyle(fontSize: 11, color: Color(0xFF5A4138))),
              ],
            ),
          ),
          // Expiry Info
          Expanded(
            flex: 2,
            child: _buildConditionBadge(record),
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
                        showDialog<bool>(
                          context: context,
                          builder: (_) => AiInsightDialog(record: record),
                        ).then((approved) {
                          if (approved == true) {
                            context.read<AiExpiryBloc>().add(ApproveRecordEvent(record.recordId));
                          } else {
                            context.read<AiExpiryBloc>().add(FetchPendingRecordsEvent());
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

  Widget _buildConditionBadge(DamagedExpiredRecordEntity record) {
    final isDamaged = record.reportType.toUpperCase() == 'DAMAGED';
    if (isDamaged) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFFFEDD5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFFDBA74).withOpacity(0.5)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 6, height: 6, decoration: const BoxDecoration(color: Color(0xFFEA580C), shape: BoxShape.circle)),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                record.reason != null && record.reason!.isNotEmpty
                    ? 'Hỏng: ${record.reason}'
                    : 'Hàng hỏng / Bể vỡ',
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFC2410C)),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      );
    }

    // Cận date / Hết hạn (EXPIRED)
    final expiry = record.expiryDate;
    if (expiry != null) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final expDay = DateTime(expiry.year, expiry.month, expiry.day);
      final daysDiff = expDay.difference(today).inDays;

      if (daysDiff < 0) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFFFDAD6).withOpacity(0.8),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 6, height: 6, decoration: const BoxDecoration(color: Color(0xFFBA1A1A), shape: BoxShape.circle)),
              const SizedBox(width: 6),
              Text(
                'Quá hạn (${_formatDate(expiry)})',
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF93000A)),
              ),
            ],
          ),
        );
      } else if (daysDiff <= 3) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFFFDAD6).withOpacity(0.6),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 6, height: 6, decoration: const BoxDecoration(color: Color(0xFFBA1A1A), shape: BoxShape.circle)),
              const SizedBox(width: 6),
              Text(
                daysDiff == 0 ? 'Hết hạn hôm nay' : 'Khẩn cấp ($daysDiff ngày)',
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFBA1A1A)),
              ),
            ],
          ),
        );
      } else {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFFEF3C7),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 6, height: 6, decoration: const BoxDecoration(color: Color(0xFFD97706), shape: BoxShape.circle)),
              const SizedBox(width: 6),
              Text(
                'Cận date ($daysDiff ngày)',
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFB45309)),
              ),
            ],
          ),
        );
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: const Color(0xFFFFDAD6).withOpacity(0.6), borderRadius: BorderRadius.circular(16)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 6, height: 6, decoration: const BoxDecoration(color: Color(0xFFBA1A1A), shape: BoxShape.circle)),
          const SizedBox(width: 6),
          const Text('Cận date / Hết hạn', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF93000A))),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) =>
      '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
}
