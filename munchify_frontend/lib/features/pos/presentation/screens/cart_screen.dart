import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/ColorPalette.dart';
import '../../../customers/presentation/bloc/customer_bloc.dart';
import '../../../customers/presentation/bloc/customer_event.dart';
import '../../../customers/presentation/bloc/customer_state.dart';
import '../../../customers/presentation/widgets/customer_lookup_bottom_sheet.dart';
import '../bloc/cart_cubit.dart';
import '../bloc/cart_state.dart';
import '../widgets/cart_item_tile.dart';
import '../widgets/promotion_input_row.dart';
import 'checkout_screen.dart';

/// Màn hình giỏ hàng.
///
/// Layout dọc:
///   - Trên: danh sách [CartItemTile] (scrollable)
///   - Dưới: khối nổi tổng hợp (promotion, điểm, subtotal → total, CTA)
class CartScreen extends StatelessWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorPalette.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: ColorPalette.textPrimary,
        elevation: 0,
        title: BlocBuilder<CartCubit, CartState>(
          builder: (context, state) => Text(
            'Giỏ hàng (${state.itemCount})',
            style: const TextStyle(
                fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ),
        actions: [
          BlocBuilder<CartCubit, CartState>(
            builder: (context, state) {
              if (state.isEmpty) return const SizedBox.shrink();
              return TextButton.icon(
                onPressed: () => _showClearConfirm(context),
                icon: const Icon(Icons.delete_sweep_outlined, size: 18),
                label: const Text('Xóa hết'),
                style: TextButton.styleFrom(foregroundColor: ColorPalette.error),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<CartCubit, CartState>(
        builder: (context, cartState) {
          if (cartState.isEmpty) {
            return _EmptyCart();
          }
          return Column(
            children: [
              // ── Item list (scrollable) ────────────────────────────────────
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.only(top: 12, bottom: 8),
                  itemCount: cartState.items.length,
                  itemBuilder: (context, index) {
                    return CartItemTile(item: cartState.items[index]);
                  },
                ),
              ),

              // ── Summary panel (floating bottom block) ────────────────────
              _SummaryPanel(cartState: cartState),
            ],
          );
        },
      ),
    );
  }

  void _showClearConfirm(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Xóa giỏ hàng?'),
        content:
            const Text('Tất cả sản phẩm sẽ bị xóa khỏi giỏ hàng.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<CartCubit>().clearCart();
              context.read<CustomerBloc>().add(ClearSelectedCustomerEvent());
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorPalette.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Xóa hết'),
          ),
        ],
      ),
    );
  }
}

// ─── Empty state ────────────────────────────────────────────────────────────
class _EmptyCart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined,
              size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'Giỏ hàng trống',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade500),
          ),
          const SizedBox(height: 8),
          Text(
            'Thêm sản phẩm từ màn hình bán hàng',
            style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back),
            label: const Text('Quay lại'),
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

// ─── Summary panel ──────────────────────────────────────────────────────────
class _SummaryPanel extends StatelessWidget {
  final CartState cartState;

  const _SummaryPanel({required this.cartState});

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            offset: const Offset(0, -4),
            blurRadius: 16,
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // ── Customer quick select ─────────────────────────────────
              _CustomerRow(),

              const SizedBox(height: 12),

              // ── Promotion code input ──────────────────────────────────
              const PromotionInputRow(),

              const SizedBox(height: 14),
              const Divider(),
              const SizedBox(height: 6),

              // ── Totals ────────────────────────────────────────────────
              _TotalRow(
                label: 'Tạm tính',
                value: currency.format(cartState.subtotal),
              ),
              if (cartState.discountAmount > 0) ...[
                const SizedBox(height: 4),
                _TotalRow(
                  label: 'Giảm giá (${cartState.appliedPromotion?.promotionCode ?? ''})',
                  value: '- ${currency.format(cartState.discountAmount)}',
                  valueColor: Colors.green,
                ),
              ],

              // Points discount from customer
              BlocBuilder<CustomerBloc, CustomerState>(
                builder: (context, customerState) {
                  if (customerState is CustomerSelected &&
                      customerState.discountFromPoints > 0) {
                    return Column(
                      children: [
                        const SizedBox(height: 4),
                        _TotalRow(
                          label:
                              'Điểm (${customerState.pointsToRedeem} điểm)',
                          value:
                              '- ${currency.format(customerState.discountFromPoints)}',
                          valueColor: Colors.green,
                        ),
                      ],
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),

              const SizedBox(height: 8),
              const Divider(thickness: 1.5),

              BlocBuilder<CustomerBloc, CustomerState>(
                builder: (context, customerState) {
                  final pointsDiscount =
                      customerState is CustomerSelected
                          ? customerState.discountFromPoints.toDouble()
                          : 0.0;
                  final amountAfterVoucher =
                      (cartState.subtotal - cartState.discountAmount)
                          .clamp(0.0, double.infinity);
                  final effectivePointsDiscount =
                      pointsDiscount.clamp(0.0, amountAfterVoucher);
                  final finalTotal =
                      amountAfterVoucher - effectivePointsDiscount;
                  return _TotalRow(
                    label: 'Tổng thanh toán',
                    value: currency.format(finalTotal),
                    isFinal: true,
                  );
                },
              ),

              const SizedBox(height: 14),

              // ── Checkout CTA ──────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const CheckoutScreen()),
                  ),
                  icon: const Icon(Icons.payment),
                  label: const Text(
                    'Thanh toán',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorPalette.appetizingOrange,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CustomerRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CustomerBloc, CustomerState>(
      builder: (context, state) {
        if (state is CustomerSelected) {
          return Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: Row(
              children: [
                const Icon(Icons.verified_user_outlined,
                    size: 16, color: Colors.green),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        state.customer.customerName,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                      Text(
                        '${state.customer.loyaltyPoints} điểm tích lũy',
                        style: TextStyle(
                            color: Colors.green.shade700, fontSize: 11),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () => context
                      .read<CustomerBloc>()
                      .add(ClearSelectedCustomerEvent()),
                  style: TextButton.styleFrom(
                      foregroundColor: Colors.red,
                      padding: EdgeInsets.zero),
                  child: const Text('Gỡ', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
          );
        }
        return OutlinedButton.icon(
          onPressed: () => showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            showDragHandle: false,
            backgroundColor: Colors.transparent,
            builder: (_) => BlocProvider.value(
              value: context.read<CustomerBloc>(),
              child: const CustomerLookupBottomSheet(),
            ),
          ),
          icon: const Icon(Icons.person_search_outlined, size: 18),
          label: const Text('Tìm khách hàng (tùy chọn)'),
          style: OutlinedButton.styleFrom(
            foregroundColor: ColorPalette.appetizingOrange,
            side: const BorderSide(color: ColorPalette.appetizingOrange),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
          ),
        );
      },
    );
  }
}

class _TotalRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final bool isFinal;

  const _TotalRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.isFinal = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isFinal ? 16 : 14,
            fontWeight:
                isFinal ? FontWeight.bold : FontWeight.normal,
            color: isFinal
                ? ColorPalette.textPrimary
                : ColorPalette.textSecondary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isFinal ? 18 : 14,
            fontWeight: FontWeight.bold,
            color: valueColor ??
                (isFinal ? ColorPalette.error : ColorPalette.textPrimary),
          ),
        ),
      ],
    );
  }
}
