import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/AppConstants.dart';
import '../../../../core/theme/ColorPalette.dart';
import '../../../customers/presentation/bloc/customer_bloc.dart';
import '../../../customers/presentation/bloc/customer_event.dart';
import '../../../customers/presentation/bloc/customer_state.dart';
import '../bloc/cart_cubit.dart';
import '../bloc/cart_state.dart';
import '../bloc/order_bloc.dart';
import '../bloc/order_event.dart';
import '../bloc/order_state.dart';
import '../widgets/payment_method_selector.dart';
import 'receipt_screen.dart';

/// Màn hình thanh toán – chọn phương thức, nhập tiền khách, xác nhận.
class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({Key? key}) : super(key: key);

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String _paymentMethod = AppConstants.paymentCash;
  final _cashController = TextEditingController();
  double _cashGiven = 0;

  @override
  void dispose() {
    _cashController.dispose();
    super.dispose();
  }

  double _getChange(double total) {
    return (_cashGiven - total).clamp(0.0, double.infinity);
  }

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

    return BlocListener<OrderBloc, OrderState>(
      listener: (context, state) {
        if (state is OrderCreated) {
          // Xóa giỏ và customer sau khi tạo đơn thành công
          context.read<CartCubit>().clearCart();
          context.read<CustomerBloc>().add(ClearSelectedCustomerEvent());
          // Navigate to receipt
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (_) => ReceiptScreen(order: state.order),
            ),
            (route) => route.isFirst,
          );
        } else if (state is OrderError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: ColorPalette.error,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: ColorPalette.background,
        appBar: AppBar(
          backgroundColor: Colors.white,
          foregroundColor: ColorPalette.textPrimary,
          elevation: 0,
          title: const Text(
            'Thanh toán',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ),
        body: BlocBuilder<CartCubit, CartState>(
          builder: (context, cartState) {
            return BlocBuilder<CustomerBloc, CustomerState>(
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

                return Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ── Order summary card ────────────────────────
                            _OrderSummaryCard(
                              cartState: cartState,
                              pointsDiscount: effectivePointsDiscount,
                              finalTotal: finalTotal,
                              currency: currency,
                            ),
                            const SizedBox(height: 20),

                            // ── Payment method ────────────────────────────
                            const Text(
                              'Phương thức thanh toán',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 12),
                            PaymentMethodSelector(
                              selectedMethod: _paymentMethod,
                              onChanged: (m) =>
                                  setState(() => _paymentMethod = m),
                            ),
                            const SizedBox(height: 20),

                            // ── Cash input (only for CASH) ─────────────
                            if (_paymentMethod == AppConstants.paymentCash) ...[
                              const Text(
                                'Tiền khách đưa',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 12),

                              // Quick cash buttons
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: AppConstants.quickCashAmounts
                                    .map((amount) => _QuickCashButton(
                                          amount: amount,
                                          currency: currency,
                                          onTap: () {
                                            setState(() {
                                              _cashGiven = amount.toDouble();
                                              _cashController.text =
                                                  amount.toString();
                                            });
                                          },
                                        ))
                                    .toList(),
                              ),
                              const SizedBox(height: 12),

                              TextField(
                                controller: _cashController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  hintText: 'Nhập số tiền...',
                                  prefixIcon: const Icon(
                                    Icons.payments_outlined,
                                    color: ColorPalette.cashColor,
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                        color: ColorPalette.border),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                        color: ColorPalette.border),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                        color: ColorPalette.appetizingOrange,
                                        width: 2),
                                  ),
                                ),
                                onChanged: (v) => setState(
                                    () => _cashGiven = double.tryParse(v) ?? 0),
                              ),
                              const SizedBox(height: 12),

                              // Change display
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: _cashGiven >= finalTotal
                                      ? Colors.green.shade50
                                      : Colors.red.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: _cashGiven >= finalTotal
                                        ? Colors.green.shade200
                                        : Colors.red.shade200,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      _cashGiven >= finalTotal
                                          ? 'Tiền thối lại'
                                          : 'Còn thiếu',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: _cashGiven >= finalTotal
                                            ? Colors.green.shade700
                                            : Colors.red.shade700,
                                      ),
                                    ),
                                    Text(
                                      currency.format(
                                          _cashGiven >= finalTotal
                                              ? _getChange(finalTotal)
                                              : finalTotal - _cashGiven),
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color: _cashGiven >= finalTotal
                                            ? Colors.green.shade700
                                            : Colors.red.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),

                    // ── Confirm button ─────────────────────────────────────
                    _ConfirmButton(
                      paymentMethod: _paymentMethod,
                      finalTotal: finalTotal,
                      cashGiven: _cashGiven,
                      cartState: cartState,
                      customerState: customerState,
                      currency: currency,
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}

// ─── Order Summary Card ─────────────────────────────────────────────────────
class _OrderSummaryCard extends StatelessWidget {
  final CartState cartState;
  final double pointsDiscount;
  final double finalTotal;
  final NumberFormat currency;

  const _OrderSummaryCard({
    required this.cartState,
    required this.pointsDiscount,
    required this.finalTotal,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ColorPalette.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tóm tắt đơn hàng',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const Divider(height: 16),
          ...cartState.items.map((item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        '${item.productName} × ${item.quantity}',
                        style: const TextStyle(fontSize: 13),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      currency.format(item.totalPrice),
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              )),
          const Divider(height: 16),
          _Row('Tạm tính', currency.format(cartState.subtotal)),
          if (cartState.discountAmount > 0)
            _Row(
              'Khuyến mãi',
              '- ${currency.format(cartState.discountAmount)}',
              valueColor: Colors.green,
            ),
          if (pointsDiscount > 0)
            _Row(
              'Điểm tích lũy',
              '- ${currency.format(pointsDiscount)}',
              valueColor: Colors.green,
            ),
          const SizedBox(height: 4),
          _Row(
            'Tổng thanh toán',
            currency.format(finalTotal),
            isBold: true,
            valueColor: ColorPalette.error,
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final bool isBold;

  const _Row(this.label, this.value,
      {this.valueColor, this.isBold = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: isBold ? 15 : 13,
                  fontWeight:
                      isBold ? FontWeight.bold : FontWeight.normal,
                  color: isBold
                      ? ColorPalette.textPrimary
                      : ColorPalette.textSecondary)),
          Text(value,
              style: TextStyle(
                  fontSize: isBold ? 16 : 13,
                  fontWeight: FontWeight.bold,
                  color: valueColor ??
                      (isBold
                          ? ColorPalette.textPrimary
                          : ColorPalette.textPrimary))),
        ],
      ),
    );
  }
}

// ─── Quick Cash Button ──────────────────────────────────────────────────────
class _QuickCashButton extends StatelessWidget {
  final int amount;
  final NumberFormat currency;
  final VoidCallback onTap;

  const _QuickCashButton(
      {required this.amount, required this.currency, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        foregroundColor: ColorPalette.cashColor,
        side: const BorderSide(color: ColorPalette.cashColor),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      ),
      child: Text(
        currency.format(amount),
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
      ),
    );
  }
}

// ─── Confirm Button ─────────────────────────────────────────────────────────
class _ConfirmButton extends StatelessWidget {
  final String paymentMethod;
  final double finalTotal;
  final double cashGiven;
  final CartState cartState;
  final CustomerState customerState;
  final NumberFormat currency;

  const _ConfirmButton({
    required this.paymentMethod,
    required this.finalTotal,
    required this.cashGiven,
    required this.cartState,
    required this.customerState,
    required this.currency,
  });

  bool get _canConfirm {
    if (paymentMethod == AppConstants.paymentCash) {
      return cashGiven >= finalTotal;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OrderBloc, OrderState>(
      builder: (context, state) {
        final isLoading = state is OrderLoading;

        return Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          color: Colors.white,
          child: SafeArea(
            top: false,
            child: SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: (_canConfirm && !isLoading)
                    ? () => _confirm(context)
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorPalette.appetizingOrange,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey.shade300,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2.5),
                      )
                    : Text(
                        'Xác nhận thanh toán · ${currency.format(finalTotal)}',
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _confirm(BuildContext context) {
    final customer = customerState is CustomerSelected
        ? (customerState as CustomerSelected).customer
        : null;
    final pointsToRedeem = customerState is CustomerSelected
        ? (customerState as CustomerSelected).pointsToRedeem
        : 0;

    final amountAfterVoucher =
        (cartState.subtotal - cartState.discountAmount).clamp(0.0, double.infinity);
    final maxPointsNeeded =
        (amountAfterVoucher / AppConstants.pointsToVndRate).ceil();
    final actualPointsToSend =
        pointsToRedeem > maxPointsNeeded ? maxPointsNeeded : pointsToRedeem;

    context.read<OrderBloc>().add(CreateOrderEvent(
          customerId: customer?.customerId,
          promotionCode: cartState.appliedPromotion?.promotionCode,
          paymentMethod: paymentMethod,
          pointsToRedeem: actualPointsToSend,
          items: cartState.items
              .map((i) => {'productId': i.productId, 'quantity': i.quantity})
              .toList(),
        ));
  }
}
