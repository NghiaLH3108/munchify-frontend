import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/ColorPalette.dart';
import '../../../customers/presentation/bloc/customer_bloc.dart';
import '../../../customers/presentation/bloc/customer_state.dart';
import '../bloc/cart_cubit.dart';
import '../bloc/cart_state.dart';
import '../screens/cart_screen.dart';

/// Bottom bar hiển thị số lượng, tổng tiền và nút mở CartScreen.
/// Đọc từ [CartCubit] thay vì hardcode.
class CartSummaryBottomBar extends StatelessWidget {
  const CartSummaryBottomBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

    return BlocBuilder<CartCubit, CartState>(
      builder: (context, cartState) {
        // Ẩn hoàn toàn khi giỏ trống
        if (cartState.isEmpty) return const SizedBox.shrink();

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                offset: const Offset(0, -4),
                blurRadius: 12,
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Row(
              children: [
                // ── Cart icon + badge ─────────────────────────────────────
                GestureDetector(
                  onTap: () => _openCart(context),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.shopping_cart_outlined,
                          color: ColorPalette.appetizingOrange,
                        ),
                      ),
                      Positioned(
                        top: -6,
                        right: -6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: ColorPalette.deepOrange,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${cartState.itemCount}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 16),

                // ── Total + customer ──────────────────────────────────────
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        currency.format(cartState.totalAmount),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: ColorPalette.textPrimary,
                        ),
                      ),
                      BlocBuilder<CustomerBloc, CustomerState>(
                        builder: (context, customerState) {
                          if (customerState is CustomerSelected) {
                            return Row(
                              children: [
                                const Icon(Icons.verified_user_outlined,
                                    size: 12, color: Colors.green),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    '${customerState.customer.customerName} · ${customerState.customer.loyaltyPoints} điểm',
                                    style: const TextStyle(
                                        color: Colors.grey, fontSize: 12),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            );
                          }
                          return const Text(
                            'Khách lẻ',
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                // ── Open Cart button ──────────────────────────────────────
                ElevatedButton(
                  onPressed: () => _openCart(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorPalette.appetizingOrange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: const Row(
                    children: [
                      Text(
                        'Giỏ\nhàng',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      SizedBox(width: 6),
                      Icon(Icons.arrow_forward, size: 18),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _openCart(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CartScreen()),
    );
  }
}
