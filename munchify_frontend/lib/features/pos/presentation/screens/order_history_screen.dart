import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/ColorPalette.dart';
import '../../domain/entities/order_entity.dart';
import '../bloc/order_bloc.dart';
import '../bloc/order_event.dart';
import '../bloc/order_state.dart';

/// Màn hình lịch sử đơn hàng – hiển thị danh sách đơn của ngày hôm nay.
class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  final _searchController = TextEditingController();
  List<OrderEntity> _filtered = [];
  List<OrderEntity> _all = [];

  @override
  void initState() {
    super.initState();
    context.read<OrderBloc>().add(const LoadOrdersEvent());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filter(String query) {
    setState(() {
      _filtered = _all
          .where(
            (o) =>
                o.orderCode.toLowerCase().contains(query.toLowerCase()) ||
                (o.customerName?.toLowerCase().contains(query.toLowerCase()) ??
                    false),
          )
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorPalette.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: ColorPalette.textPrimary,
        elevation: 0,
        title: const Text(
          'Lịch sử đơn hàng',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: ColorPalette.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () =>
                context.read<OrderBloc>().add(const LoadOrdersEvent()),
            icon: const Icon(Icons.refresh),
            tooltip: 'Làm mới',
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Search bar ──────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _searchController,
              onChanged: _filter,
              decoration: InputDecoration(
                hintText: 'Tìm theo mã đơn, tên khách...',
                prefixIcon: const Icon(
                  Icons.search,
                  color: ColorPalette.appetizingOrange,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: ColorPalette.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: ColorPalette.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: ColorPalette.appetizingOrange,
                    width: 2,
                  ),
                ),
              ),
            ),
          ),

          // ── Order list ──────────────────────────────────────────────────
          Expanded(
            child: BlocConsumer<OrderBloc, OrderState>(
              listener: (context, state) {
                if (state is OrdersLoaded) {
                  setState(() {
                    _all = state.orders;
                    _filtered = _all;
                    if (_searchController.text.isNotEmpty) {
                      _filter(_searchController.text);
                    }
                  });
                }
              },
              builder: (context, state) {
                if (state is OrderLoading) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: ColorPalette.appetizingOrange,
                    ),
                  );
                }
                if (state is OrderError) {
                  return _ErrorView(
                    message: state.message,
                    onRetry: () =>
                        context.read<OrderBloc>().add(const LoadOrdersEvent()),
                  );
                }
                if (_filtered.isEmpty) {
                  return _EmptyView();
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  itemCount: _filtered.length,
                  itemBuilder: (context, index) =>
                      _OrderCard(order: _filtered[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Order Card ──────────────────────────────────────────────────────────────
class _OrderCard extends StatelessWidget {
  final OrderEntity order;

  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    final timeFormat = DateFormat('HH:mm');
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: ColorPalette.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header row ────────────────────────────────────────────────
            Row(
              children: [
                const Icon(
                  Icons.receipt_long,
                  size: 16,
                  color: ColorPalette.appetizingOrange,
                ),
                const SizedBox(width: 6),
                Text(
                  order.orderCode,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: ColorPalette.textPrimary,
                  ),
                ),
                const Spacer(),
                _StatusBadge(status: order.orderStatus),
              ],
            ),

            const SizedBox(height: 6),

            // ── Date + customer ───────────────────────────────────────────
            Row(
              children: [
                Icon(Icons.access_time, size: 13, color: Colors.grey.shade400),
                const SizedBox(width: 4),
                Text(
                  '${timeFormat.format(order.createdAt)}  ${dateFormat.format(order.createdAt)}',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                ),
                if (order.customerName != null) ...[
                  const SizedBox(width: 12),
                  Icon(
                    Icons.person_outline,
                    size: 13,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    order.customerName!,
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                  ),
                ],
              ],
            ),

            const SizedBox(height: 8),
            const Divider(height: 1),
            const SizedBox(height: 8),

            // ── Items summary ─────────────────────────────────────────────
            Text(
              order.orderDetails.isNotEmpty
                  ? '${order.orderDetails.length} sản phẩm: ${order.orderDetails.map((d) => '${d.productName} (x${d.quantity})').join(', ')}'
                  : '${order.effectiveItemCount} sản phẩm',
              style: const TextStyle(
                color: ColorPalette.textSecondary,
                fontSize: 12,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 8),

            // ── Total + payment + points ──────────────────────────────────
            Row(
              children: [
                Text(
                  currency.format(order.totalAmount),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                    color: ColorPalette.error,
                  ),
                ),
                const SizedBox(width: 10),
                _PaymentBadge(method: order.payment.paymentMethod),
                const Spacer(),
                if (order.pointsEarned > 0)
                  Row(
                    children: [
                      const Icon(Icons.stars, size: 14, color: Colors.amber),
                      const SizedBox(width: 3),
                      Text(
                        '+${order.pointsEarned}',
                        style: const TextStyle(
                          color: Colors.amber,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    String label;
    switch (status) {
      case 'COMPLETED':
        bg = Colors.green.shade50;
        fg = Colors.green.shade700;
        label = 'Hoàn thành';
        break;
      case 'CANCELLED':
        bg = Colors.red.shade50;
        fg = Colors.red.shade700;
        label = 'Đã hủy';
        break;
      default:
        bg = Colors.orange.shade50;
        fg = Colors.orange.shade700;
        label = 'Chờ xử lý';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(color: fg, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _PaymentBadge extends StatelessWidget {
  final String method;
  const _PaymentBadge({required this.method});

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color color;
    switch (method) {
      case 'QR_CODE':
        icon = Icons.qr_code;
        color = ColorPalette.qrCodeColor;
        break;
      case 'BANK_TRANSFER':
        icon = Icons.account_balance;
        color = ColorPalette.bankTransferColor;
        break;
      default:
        icon = Icons.payments;
        color = ColorPalette.cashColor;
    }
    return Icon(icon, size: 16, color: color);
  }
}

class _EmptyView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 72,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            'Chưa có đơn hàng nào',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Đơn hàng sẽ xuất hiện sau khi thanh toán',
            style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.cloud_off, size: 60, color: Colors.grey),
          const SizedBox(height: 12),
          Text(
            message,
            style: const TextStyle(color: ColorPalette.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Thử lại'),
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorPalette.appetizingOrange,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
