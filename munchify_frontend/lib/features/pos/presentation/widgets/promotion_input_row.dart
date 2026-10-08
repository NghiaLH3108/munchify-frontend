import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/ColorPalette.dart';
import '../bloc/cart_cubit.dart';
import '../bloc/cart_state.dart';

/// Row nhập mã khuyến mãi + nút "Áp dụng" / "Gỡ".
class PromotionInputRow extends StatefulWidget {
  const PromotionInputRow({Key? key}) : super(key: key);

  @override
  State<PromotionInputRow> createState() => _PromotionInputRowState();
}

class _PromotionInputRowState extends State<PromotionInputRow> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CartCubit, CartState>(
      listenWhen: (prev, curr) =>
          prev.appliedPromotion != curr.appliedPromotion ||
          prev.promotionError != curr.promotionError,
      listener: (context, state) {
        if (state.appliedPromotion != null) {
          // Điền code vào text field khi áp dụng thành công
          _controller.text = state.appliedPromotion!.promotionCode;
        }
      },
      builder: (context, state) {
        final isApplied = state.appliedPromotion != null;
        final isLoading = state.isApplyingPromotion;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // ── Text field ────────────────────────────────────────────
                Expanded(
                  child: TextField(
                    controller: _controller,
                    enabled: !isApplied && !isLoading,
                    textCapitalization: TextCapitalization.characters,
                    decoration: InputDecoration(
                      hintText: 'Nhập mã khuyến mãi...',
                      prefixIcon: const Icon(
                        Icons.local_offer_outlined,
                        color: ColorPalette.appetizingOrange,
                        size: 20,
                      ),
                      filled: true,
                      fillColor: isApplied
                          ? Colors.green.shade50
                          : Colors.grey.shade50,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: isApplied
                              ? Colors.green
                              : Colors.grey.shade200,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: isApplied
                              ? Colors.green.shade300
                              : Colors.grey.shade200,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                            color: ColorPalette.appetizingOrange),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                // ── Apply / Remove button ─────────────────────────────────
                if (isApplied)
                  IconButton(
                    onPressed: () {
                      _controller.clear();
                      context.read<CartCubit>().removePromotion();
                    },
                    icon: const Icon(Icons.cancel, color: Colors.red),
                    tooltip: 'Gỡ mã',
                  )
                else
                  ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () => context
                            .read<CartCubit>()
                            .applyPromotion(_controller.text),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorPalette.appetizingOrange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2),
                          )
                        : const Text('Áp dụng',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
              ],
            ),

            // ── Success / Error message ───────────────────────────────────
            if (isApplied) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.check_circle,
                      size: 14, color: Colors.green),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'Áp dụng: ${state.appliedPromotion!.promotionName}',
                      style: const TextStyle(
                          color: Colors.green,
                          fontSize: 12,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ] else if (state.promotionError != null) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.error_outline,
                      size: 14, color: ColorPalette.error),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      state.promotionError!,
                      style: const TextStyle(
                          color: ColorPalette.error, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ],
          ],
        );
      },
    );
  }
}
