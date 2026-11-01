import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/ColorPalette.dart';
import '../../../pos/domain/entities/product_entity.dart';
import '../../../pos/presentation/bloc/pos_catalog_bloc.dart';
import '../../../pos/presentation/bloc/pos_catalog_state.dart';
import '../../domain/entities/damaged_expired_record_entity.dart';
import '../bloc/ai_expiry/ai_expiry_bloc.dart';
import '../bloc/ai_expiry/ai_expiry_event.dart';
import '../bloc/ai_expiry/ai_expiry_state.dart';
import '../../../../core/widgets/app_toast.dart';

class StaffDamageReportScreen extends StatefulWidget {
  const StaffDamageReportScreen({super.key});

  @override
  State<StaffDamageReportScreen> createState() => _StaffDamageReportScreenState();
}

class _StaffDamageReportScreenState extends State<StaffDamageReportScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Form State
  ProductEntity? _selectedProduct;
  String _reportType = 'DAMAGED'; // 'DAMAGED' or 'EXPIRED'
  int _quantity = 1;
  final TextEditingController _reasonController = TextEditingController();
  String? _selectedQuickReason;

  final List<String> _damagedQuickReasons = [
    'Rơi vỡ khi xếp kệ',
    'Rách bao bì / Chuột cắn',
    'Bị ẩm mốc / Hư hỏng',
    'Khách làm rơi vỡ tại quầy',
    'Móp méo biến dạng khi vận chuyển',
  ];

  final List<String> _expiredQuickReasons = [
    'Hết hạn sử dụng trên kệ',
    'Hàng cận date không kịp bán',
    'Phát hiện quá hạn khi kiểm tra ca',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Load existing pending records for Staff to view history
    context.read<AiExpiryBloc>().add(FetchPendingRecordsEvent());
  }

  @override
  void dispose() {
    _tabController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  void _resetForm() {
    setState(() {
      _selectedProduct = null;
      _quantity = 1;
      _reportType = 'DAMAGED';
      _reasonController.clear();
      _selectedQuickReason = null;
    });
  }

  void _submitReport() {
    if (_selectedProduct == null) {
      AppToast.error('Vui lòng chọn sản phẩm gặp sự cố.', context: context);
      return;
    }

    if (_quantity <= 0) {
      AppToast.error('Số lượng phải lớn hơn 0.', context: context);
      return;
    }

    if (_quantity > _selectedProduct!.stockQuantity) {
      AppToast.error(
        'Số lượng báo cáo ($_quantity) không được vượt quá tồn kho (${_selectedProduct!.stockQuantity}).',
        context: context,
      );
      return;
    }

    final reason = _reasonController.text.trim().isNotEmpty
        ? _reasonController.text.trim()
        : (_selectedQuickReason ?? 'Sự cố tại quầy');

    context.read<AiExpiryBloc>().add(
          SubmitStaffReportEvent(
            productId: _selectedProduct!.id,
            quantity: _quantity,
            reportType: _reportType,
            reason: reason,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF9F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: ColorPalette.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Báo Cáo Hàng Hỏng / Hết Hạn',
              style: TextStyle(
                color: ColorPalette.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 17,
              ),
            ),
            Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: ColorPalette.appetizingOrange,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                const Text(
                  'Nhân viên quầy • Gửi yêu cầu chờ Admin duyệt',
                  style: TextStyle(color: ColorPalette.textHint, fontSize: 11),
                ),
              ],
            ),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: ColorPalette.appetizingOrange,
          unselectedLabelColor: ColorPalette.textSecondary,
          indicatorColor: ColorPalette.appetizingOrange,
          indicatorWeight: 3,
          tabs: const [
            Tab(icon: Icon(Icons.edit_note_rounded), text: 'Lập Báo Cáo'),
            Tab(icon: Icon(Icons.history_rounded), text: 'Lịch Sử Sự Cố'),
          ],
        ),
      ),
      body: BlocConsumer<AiExpiryBloc, AiExpiryState>(
        listener: (context, state) {
          if (state is AiExpiryReportSuccess) {
            AppToast.success(state.message, context: context);
            _resetForm();
            _tabController.animateTo(1); // Chuyển sang xem lịch sử
          } else if (state is AiExpiryError) {
            AppToast.error(state.message, context: context);
          }
        },
        builder: (context, state) {
          final isSubmitting = state is AiExpiryReportSubmitting;

          return TabBarView(
            controller: _tabController,
            children: [
              _buildReportFormTab(isSubmitting),
              _buildHistoryTab(state),
            ],
          );
        },
      ),
    );
  }

  // ==========================================
  // TAB 1: FORM LẬP BÁO CÁO HÀNG HƯ HỎNG / HẾT HẠN
  // ==========================================
  Widget _buildReportFormTab(bool isSubmitting) {
    final quickReasons = _reportType == 'DAMAGED' ? _damagedQuickReasons : _expiredQuickReasons;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner Hướng dẫn
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3E0),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFFCC80)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded, color: ColorPalette.appetizingOrange, size: 22),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Báo cáo sau khi gửi sẽ ở trạng thái Chờ Duyệt. Quản lý cửa hàng sẽ kiểm tra và bấm Duyệt để hệ thống tự động trừ kho.',
                    style: TextStyle(fontSize: 12, color: Color(0xFF5D4037), height: 1.3),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 1. Chọn sản phẩm
          _buildSectionCard(
            title: '1. Chọn sản phẩm gặp sự cố',
            icon: Icons.inventory_2_outlined,
            child: _selectedProduct == null
                ? InkWell(
                    onTap: _showProductSelectionSheet,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.search, color: ColorPalette.appetizingOrange),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Nhấn vào đây để tìm & chọn sản phẩm...',
                              style: TextStyle(color: ColorPalette.textHint, fontSize: 14),
                            ),
                          ),
                          Icon(Icons.chevron_right, color: ColorPalette.textHint),
                        ],
                      ),
                    ),
                  )
                : _buildSelectedProductTile(),
          ),
          const SizedBox(height: 16),

          // 2. Phân loại sự cố (Damaged vs Expired)
          _buildSectionCard(
            title: '2. Phân loại sự cố',
            icon: Icons.category_outlined,
            child: Row(
              children: [
                Expanded(
                  child: _buildTypeOption(
                    type: 'DAMAGED',
                    label: 'Hàng Hư Hỏng',
                    subLabel: 'Rơi vỡ, rách bao bì, ẩm mốc',
                    icon: Icons.broken_image_outlined,
                    color: const Color(0xFFE65100),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTypeOption(
                    type: 'EXPIRED',
                    label: 'Hàng Hết Hạn',
                    subLabel: 'Quá date, cận date bỏ hủy',
                    icon: Icons.event_busy_outlined,
                    color: const Color(0xFFC62828),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 3. Số lượng hư hỏng
          _buildSectionCard(
            title: '3. Số lượng hư hại / tiêu hủy',
            icon: Icons.format_list_numbered_rounded,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: _quantity > 1 ? () => setState(() => _quantity--) : null,
                      icon: const Icon(Icons.remove_circle_outline, size: 36),
                      color: ColorPalette.appetizingOrange,
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Text(
                        '$_quantity',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: ColorPalette.textPrimary,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: (_selectedProduct != null && _quantity < _selectedProduct!.stockQuantity)
                          ? () => setState(() => _quantity++)
                          : (_selectedProduct == null ? () => setState(() => _quantity++) : null),
                      icon: const Icon(Icons.add_circle_outline, size: 36),
                      color: ColorPalette.appetizingOrange,
                    ),
                  ],
                ),
                if (_selectedProduct != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ActionChip(
                        label: const Text('+1'),
                        onPressed: _quantity + 1 <= _selectedProduct!.stockQuantity
                            ? () => setState(() => _quantity += 1)
                            : null,
                      ),
                      const SizedBox(width: 8),
                      ActionChip(
                        label: const Text('+5'),
                        onPressed: _quantity + 5 <= _selectedProduct!.stockQuantity
                            ? () => setState(() => _quantity += 5)
                            : null,
                      ),
                      const SizedBox(width: 8),
                      ActionChip(
                        label: Text('Tất cả (${_selectedProduct!.stockQuantity})'),
                        backgroundColor: Colors.orange.shade50,
                        onPressed: () => setState(() => _quantity = _selectedProduct!.stockQuantity),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 4. Lý do sự cố
          _buildSectionCard(
            title: '4. Lý do & Ghi chú',
            icon: Icons.chat_bubble_outline_rounded,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Chọn nhanh nguyên nhân:',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: ColorPalette.textSecondary),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: quickReasons.map((reason) {
                    final isSelected = _selectedQuickReason == reason;
                    return ChoiceChip(
                      label: Text(reason),
                      selected: isSelected,
                      selectedColor: ColorPalette.appetizingOrange.withOpacity(0.15),
                      labelStyle: TextStyle(
                        fontSize: 12,
                        color: isSelected ? ColorPalette.appetizingOrange : ColorPalette.textPrimary,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      onSelected: (selected) {
                        setState(() {
                          _selectedQuickReason = selected ? reason : null;
                          if (selected) {
                            _reasonController.text = reason;
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _reasonController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    hintText: 'Nhập chi tiết ghi chú thêm (nếu có)...',
                    hintStyle: const TextStyle(fontSize: 13, color: ColorPalette.textHint),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: ColorPalette.appetizingOrange),
                    ),
                    contentPadding: const EdgeInsets.all(12),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Submit CTA
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: isSubmitting ? null : _submitReport,
              icon: isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Icon(Icons.send_rounded, color: Colors.white),
              label: Text(
                isSubmitting ? 'ĐANG GỬI BÁO CÁO...' : 'GỬI BÁO CÁO SỰ CỐ',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorPalette.appetizingOrange,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 2,
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // ==========================================
  // TAB 2: LỊCH SỬ BÁO CÁO CỦA NHÂN VIÊN
  // ==========================================
  Widget _buildHistoryTab(AiExpiryState state) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<AiExpiryBloc>().add(FetchPendingRecordsEvent());
      },
      child: Builder(
        builder: (context) {
          if (state is AiExpiryLoading && state is! AiExpiryLoaded) {
            return const Center(child: CircularProgressIndicator(color: ColorPalette.appetizingOrange));
          }

          if (state is AiExpiryLoaded) {
            final records = state.records;
            if (records.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.inventory_rounded, size: 64, color: Colors.grey.shade300),
                    const SizedBox(height: 12),
                    const Text(
                      'Chưa có báo cáo sự cố nào.',
                      style: TextStyle(color: ColorPalette.textSecondary, fontSize: 16),
                    ),
                  ],
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: records.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final r = records[index];
                return _buildHistoryRecordCard(r);
              },
            );
          }

          return const Center(child: Text('Đang tải danh sách báo cáo...'));
        },
      ),
    );
  }

  Widget _buildHistoryRecordCard(DamagedExpiredRecordEntity record) {
    Color statusColor;
    String statusText;
    IconData statusIcon;

    switch (record.status.toUpperCase()) {
      case 'APPROVED':
        statusColor = const Color(0xFF2E7D32);
        statusText = 'ĐÃ DUYỆT TIÊU HỦY';
        statusIcon = Icons.check_circle_rounded;
        break;
      case 'REJECTED':
        statusColor = const Color(0xFFC62828);
        statusText = 'TỪ CHỐI';
        statusIcon = Icons.cancel_rounded;
        break;
      case 'PENDING':
      default:
        statusColor = const Color(0xFFE65100);
        statusText = 'CHỜ QUẢN LÝ DUYỆT';
        statusIcon = Icons.schedule_rounded;
        break;
    }

    final isDamaged = record.reportType.toUpperCase() == 'DAMAGED';
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Tên SP + Badge trạng thái
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isDamaged ? Colors.orange.shade50 : Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  isDamaged ? Icons.broken_image_rounded : Icons.event_busy_rounded,
                  color: isDamaged ? Colors.orange.shade800 : Colors.red.shade800,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      record.productName,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Mã phiếu: #${record.recordId} • ${dateFormat.format(record.createdAt)}',
                      style: const TextStyle(color: ColorPalette.textHint, fontSize: 11),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: statusColor.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(statusIcon, size: 12, color: statusColor),
                    const SizedBox(width: 4),
                    Text(
                      statusText,
                      style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 18),

          // Chi tiết số lượng và lý do
          Row(
            children: [
              _buildDetailChip(
                label: 'Số lượng:',
                value: '${record.quantity} ${record.unitName}',
                color: Colors.black87,
              ),
              const SizedBox(width: 12),
              _buildDetailChip(
                label: 'Loại sự cố:',
                value: isDamaged ? 'Hư hỏng' : 'Hết hạn',
                color: isDamaged ? Colors.orange.shade800 : Colors.red.shade800,
              ),
            ],
          ),
          if (record.reason != null && record.reason!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'Lý do: ${record.reason}',
                style: const TextStyle(fontSize: 12, color: ColorPalette.textSecondary, fontStyle: FontStyle.italic),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailChip({required String label, required String value, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(4),
      ),
      child: RichText(
        text: TextSpan(
          text: '$label ',
          style: const TextStyle(fontSize: 11, color: ColorPalette.textHint),
          children: [
            TextSpan(
              text: value,
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // HELPERS & MODAL CHỌN SẢN PHẨM
  // ==========================================
  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: ColorPalette.appetizingOrange),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: ColorPalette.textPrimary),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _buildTypeOption({
    required String type,
    required String label,
    required String subLabel,
    required IconData icon,
    required Color color,
  }) {
    final isSelected = _reportType == type;

    return InkWell(
      onTap: () {
        setState(() {
          _reportType = type;
          _selectedQuickReason = null;
          _reasonController.clear();
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.08) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: isSelected ? color : Colors.grey, size: 24),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: isSelected ? color : ColorPalette.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subLabel,
              style: const TextStyle(fontSize: 10, color: ColorPalette.textHint),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedProductTile() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.shade50.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ColorPalette.appetizingOrange.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 50,
              height: 50,
              color: Colors.grey.shade200,
              child: (_selectedProduct!.imageUrl != null && _selectedProduct!.imageUrl!.isNotEmpty)
                  ? Image.network(
                      _selectedProduct!.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(Icons.fastfood, color: Colors.grey),
                    )
                  : const Icon(Icons.fastfood, color: Colors.grey),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _selectedProduct!.name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 2),
                Text(
                  'Mã SP: ${_selectedProduct!.code} • Đơn vị: ${_selectedProduct!.unitName}',
                  style: const TextStyle(fontSize: 11, color: ColorPalette.textSecondary),
                ),
                const SizedBox(height: 2),
                Text(
                  'Tồn kho hiện có: ${_selectedProduct!.stockQuantity} ${_selectedProduct!.unitName}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: ColorPalette.appetizingOrange,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.swap_horiz_rounded, color: ColorPalette.appetizingOrange),
            tooltip: 'Đổi sản phẩm khác',
            onPressed: _showProductSelectionSheet,
          ),
        ],
      ),
    );
  }

  void _showProductSelectionSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        String query = '';
        return StatefulBuilder(
          builder: (context, setModalState) {
            final catalogState = context.watch<PosCatalogBloc>().state;
            List<ProductEntity> allProducts = [];
            if (catalogState is PosCatalogLoaded) {
              allProducts = catalogState.products;
            }

            final filtered = allProducts.where((p) {
              return query.isEmpty ||
                  p.name.toLowerCase().contains(query.toLowerCase()) ||
                  p.code.toLowerCase().contains(query.toLowerCase());
            }).toList();

            return Container(
              height: MediaQuery.of(context).size.height * 0.75,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Chọn Sản Phẩm Báo Cáo',
                          style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                  ),
                  // Search Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      autofocus: false,
                      decoration: InputDecoration(
                        hintText: 'Tìm theo tên hoặc mã món...',
                        prefixIcon: const Icon(Icons.search, size: 20),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                      ),
                      onChanged: (val) {
                        setModalState(() {
                          query = val;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  // List
                  Expanded(
                    child: filtered.isEmpty
                        ? const Center(child: Text('Không tìm thấy sản phẩm nào'))
                        : ListView.separated(
                            padding: const EdgeInsets.all(16),
                            itemCount: filtered.length,
                            separatorBuilder: (_, __) => const Divider(height: 1),
                            itemBuilder: (context, idx) {
                              final p = filtered[idx];
                              return ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: Container(
                                    width: 44,
                                    height: 44,
                                    color: Colors.grey.shade200,
                                    child: (p.imageUrl != null && p.imageUrl!.isNotEmpty)
                                        ? Image.network(
                                            p.imageUrl!,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) =>
                                                const Icon(Icons.fastfood, size: 20, color: Colors.grey),
                                          )
                                        : const Icon(Icons.fastfood, size: 20, color: Colors.grey),
                                  ),
                                ),
                                title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                subtitle: Text('Mã: ${p.code} • Tồn: ${p.stockQuantity} ${p.unitName}', style: const TextStyle(fontSize: 11)),
                                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
                                onTap: () {
                                  setState(() {
                                    _selectedProduct = p;
                                    _quantity = 1;
                                  });
                                  Navigator.pop(ctx);
                                },
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
