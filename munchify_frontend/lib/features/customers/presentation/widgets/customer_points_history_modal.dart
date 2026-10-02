import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/ColorPalette.dart';
import '../../../../core/theme/AppTypography.dart';
import '../../../../core/utils/CurrencyFormatter.dart';
import '../../domain/entities/customer_entity.dart';
import '../../domain/entities/customer_point_history_entity.dart';
import '../bloc/admin_customer_bloc.dart';
import '../bloc/admin_customer_event.dart';
import '../bloc/admin_customer_state.dart';
import 'package:intl/intl.dart';

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

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 800,
        height: 600,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Lịch sử điểm: ${widget.customer.customerName}',
                      style: AppTypography.plusJakarta(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tổng điểm hiện tại: ${widget.customer.loyaltyPoints} điểm | SĐT: ${widget.customer.phone}',
                      style: AppTypography.inter(
                        fontSize: 13,
                        color: ColorPalette.textMuted,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Expanded(
              child: BlocBuilder<AdminCustomerBloc, AdminCustomerState>(
                buildWhen: (previous, current) =>
                    current is CustomerPointHistoryLoading ||
                    current is CustomerPointHistoryLoaded ||
                    current is AdminCustomerError,
                builder: (context, state) {
                  if (state is CustomerPointHistoryLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is CustomerPointHistoryLoaded) {
                    if (state.historyData.items.isEmpty) {
                      return Center(
                        child: Text(
                          'Khách hàng chưa có lịch sử tích/tiêu điểm.',
                          style: AppTypography.inter(color: ColorPalette.textMuted),
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
                    return Center(child: Text('Lỗi: ${state.message}', style: const TextStyle(color: Colors.red)));
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
        border: Border.all(color: ColorPalette.borderSubtle),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DataTable(
        headingRowColor: WidgetStateProperty.all(ColorPalette.webBgAdmin.withValues(alpha: 0.5)),
        columns: const [
          DataColumn(label: Text('Mã đơn hàng')),
          DataColumn(label: Text('Thời gian')),
          DataColumn(label: Text('Tổng tiền')),
          DataColumn(label: Text('Điểm tích')),
          DataColumn(label: Text('Điểm tiêu')),
        ],
        rows: items.map((history) {
          final df = DateFormat('dd/MM/yyyy HH:mm');
          return DataRow(
            cells: [
              DataCell(Text(history.orderCode, style: const TextStyle(fontWeight: FontWeight.w600))),
              DataCell(Text(df.format(history.createdAt))),
              DataCell(Text(CurrencyFormatter.format(history.totalAmount))),
              DataCell(
                Text(
                  '+${history.pointsEarned}',
                  style: const TextStyle(color: ColorPalette.success, fontWeight: FontWeight.w600),
                ),
              ),
              DataCell(
                Text(
                  history.pointsRedeemed > 0 ? '-${history.pointsRedeemed}' : '0',
                  style: TextStyle(
                    color: history.pointsRedeemed > 0 ? ColorPalette.dangerCrimson : ColorPalette.textMuted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPagination(int totalCount) {
    final totalPages = (totalCount / _pageSize).ceil();
    if (totalPages <= 1) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text('Trang $_currentPage / $totalPages'),
          const SizedBox(width: 16),
          IconButton(
            onPressed: _currentPage > 1
                ? () {
                    setState(() => _currentPage--);
                    _loadHistory();
                  }
                : null,
            icon: const Icon(Icons.chevron_left_rounded),
          ),
          IconButton(
            onPressed: _currentPage < totalPages
                ? () {
                    setState(() => _currentPage++);
                    _loadHistory();
                  }
                : null,
            icon: const Icon(Icons.chevron_right_rounded),
          ),
        ],
      ),
    );
  }
}
