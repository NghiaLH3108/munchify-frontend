import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/ColorPalette.dart';
import '../../../../core/theme/AppTypography.dart';
import '../../../../core/utils/CurrencyFormatter.dart';
import '../../domain/entities/customer_entity.dart';
import '../../domain/entities/customer_point_history_entity.dart';
import '../bloc/admin_customer_bloc.dart';
import '../bloc/admin_customer_event.dart';
import '../bloc/admin_customer_state.dart';

class CustomerPointsHistoryModal extends StatefulWidget {
  final CustomerEntity customer;

  const CustomerPointsHistoryModal({super.key, required this.customer});

  @override
  State<CustomerPointsHistoryModal> createState() => _CustomerPointsHistoryModalState();
}

class _CustomerPointsHistoryModalState extends State<CustomerPointsHistoryModal> {
  int _currentPage = 1;
  static const int _pageSize = 10;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  void _loadHistory() {
    context.read<AdminCustomerBloc>().add(
          LoadCustomerPointHistory(
            customerId: widget.customer.customerId,
            pageIndex: _currentPage,
            pageSize: _pageSize,
          ),
        );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts[0].isEmpty) return '?';
    if (parts.length == 1) return parts[0].substring(0, math.min(2, parts[0].length)).toUpperCase();
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: ColorPalette.surfaceWhite,
      child: Container(
        width: 820,
        height: 620,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Modal Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: ColorPalette.primaryFixed,
                      child: Text(
                        _getInitials(widget.customer.customerName),
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: ColorPalette.primaryContainer,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              widget.customer.customerName,
                              style: AppTypography.plusJakarta(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: ColorPalette.onSurfaceDark,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                              decoration: BoxDecoration(
                                color: ColorPalette.amber.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: ColorPalette.amber.withValues(alpha: 0.3)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.stars_rounded, size: 14, color: Color(0xFFD97706)),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${widget.customer.loyaltyPoints} điểm khả dụng',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFFD97706),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'SĐT: ${widget.customer.phone} • Mã KH: #${widget.customer.customerId}',
                          style: AppTypography.inter(fontSize: 12, color: ColorPalette.textMuted),
                        ),
                      ],
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded, color: ColorPalette.textMuted),
                  style: IconButton.styleFrom(
                    backgroundColor: ColorPalette.webBgAdmin,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(height: 1, color: ColorPalette.borderSubtle),
            const SizedBox(height: 16),

            // Content Area
            Expanded(
              child: BlocBuilder<AdminCustomerBloc, AdminCustomerState>(
                buildWhen: (previous, current) =>
                    current is CustomerPointHistoryLoading ||
                    current is CustomerPointHistoryLoaded ||
                    current is AdminCustomerError,
                builder: (context, state) {
                  if (state is CustomerPointHistoryLoading) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(
                            width: 36,
                            height: 36,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              color: ColorPalette.appetizingOrange,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text('Đang tải lịch sử điểm...', style: AppTypography.dashboardSubtitle),
                        ],
                      ),
                    );
                  } else if (state is CustomerPointHistoryLoaded) {
                    if (state.historyData.items.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.history_toggle_off_rounded,
                              size: 48,
                              color: ColorPalette.textMuted.withValues(alpha: 0.4),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Khách hàng chưa có lịch sử tích/tiêu điểm.',
                              style: AppTypography.inter(
                                fontSize: 14,
                                color: ColorPalette.textMuted,
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    return Column(
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            child: _buildHistoryTable(state.historyData.items),
                          ),
                        ),
                        _buildPagination(state.historyData.totalCount),
                      ],
                    );
                  } else if (state is AdminCustomerError) {
                    return Center(
                      child: Text('Lỗi tải lịch sử: ${state.message}',
                          style: const TextStyle(color: ColorPalette.error)),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryTable(List<CustomerPointHistoryEntity> items) {
    return Container(
      decoration: BoxDecoration(
        color: ColorPalette.surfaceWhite,
        border: Border.all(color: ColorPalette.borderSubtle),
        borderRadius: BorderRadius.circular(10),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Table Header
          Container(
            height: 42,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: ColorPalette.webBgAdmin.withValues(alpha: 0.8),
              border: const Border(bottom: BorderSide(color: ColorPalette.borderSubtle)),
            ),
            child: Row(
              children: const [
                Expanded(flex: 3, child: Text('MÃ ĐƠN HÀNG', style: AppTypography.tableHeader)),
                Expanded(flex: 3, child: Text('THỜI GIAN', style: AppTypography.tableHeader)),
                Expanded(flex: 3, child: Text('TỔNG TIỀN', style: AppTypography.tableHeader)),
                Expanded(flex: 2, child: Text('ĐIỂM TÍCH', style: AppTypography.tableHeader)),
                Expanded(flex: 2, child: Text('ĐIỂM TIÊU', style: AppTypography.tableHeader)),
              ],
            ),
          ),
          // Table Rows
          ...items.map((history) {
            final df = DateFormat('dd/MM/yyyy HH:mm');
            return Container(
              height: 52,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: ColorPalette.borderSubtle, width: 0.5)),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.receipt_outlined, size: 14, color: ColorPalette.textMuted),
                        const SizedBox(width: 6),
                        Text(
                          history.orderCode,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: ColorPalette.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      df.format(history.createdAt),
                      style: const TextStyle(fontSize: 12, color: ColorPalette.textMuted),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      CurrencyFormatter.format(history.totalAmount),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: ColorPalette.textPrimary,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: history.pointsEarned > 0
                        ? Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: ColorPalette.success.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.add_circle_outline_rounded,
                                    size: 12, color: ColorPalette.success),
                                const SizedBox(width: 4),
                                Text(
                                  '+${history.pointsEarned}',
                                  style: const TextStyle(
                                    color: ColorPalette.success,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : const Text('0', style: TextStyle(color: ColorPalette.textMuted, fontSize: 12)),
                  ),
                  Expanded(
                    flex: 2,
                    child: history.pointsRedeemed > 0
                        ? Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: ColorPalette.error.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.remove_circle_outline_rounded,
                                    size: 12, color: ColorPalette.error),
                                const SizedBox(width: 4),
                                Text(
                                  '-${history.pointsRedeemed}',
                                  style: const TextStyle(
                                    color: ColorPalette.error,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : const Text('0', style: TextStyle(color: ColorPalette.textMuted, fontSize: 12)),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildPagination(int totalCount) {
    final totalPages = (totalCount / _pageSize).ceil();
    if (totalPages <= 1) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Trang $_currentPage / $totalPages (Tổng $totalCount giao dịch)',
            style: const TextStyle(fontSize: 12, color: ColorPalette.textMuted),
          ),
          Row(
            children: [
              IconButton(
                onPressed: _currentPage > 1
                    ? () {
                        setState(() => _currentPage--);
                        _loadHistory();
                      }
                    : null,
                icon: const Icon(Icons.chevron_left_rounded, size: 20),
                style: IconButton.styleFrom(
                  backgroundColor: ColorPalette.webBgAdmin,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: ColorPalette.appetizingOrange,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '$_currentPage',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12),
                ),
              ),
              const SizedBox(width: 6),
              IconButton(
                onPressed: _currentPage < totalPages
                    ? () {
                        setState(() => _currentPage++);
                        _loadHistory();
                      }
                    : null,
                icon: const Icon(Icons.chevron_right_rounded, size: 20),
                style: IconButton.styleFrom(
                  backgroundColor: ColorPalette.webBgAdmin,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
