import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/ColorPalette.dart';
import '../../../../injection_container.dart' as di;
import '../../domain/entities/catalog_promotion_entity.dart';
import '../../domain/usecases/get_active_promotions_usecase.dart';
import '../bloc/cart_cubit.dart';
import '../bloc/cart_state.dart';

/// Bottom sheet hiển thị danh sách các khuyến mãi đang có hiệu lực.
/// Cho phép nhân viên POS xem và chọn áp dụng trực tiếp cho đơn hàng.
class PromotionListBottomSheet extends StatefulWidget {
  const PromotionListBottomSheet({Key? key}) : super(key: key);

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: false,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<CartCubit>(),
        child: const PromotionListBottomSheet(),
      ),
    );
  }

  @override
  State<PromotionListBottomSheet> createState() =>
      _PromotionListBottomSheetState();
}

class _PromotionListBottomSheetState extends State<PromotionListBottomSheet> {
  late Future<List<CatalogPromotionEntity>> _promotionsFuture;

  @override
  void initState() {
    super.initState();
    _promotionsFuture = _loadPromotions();
  }

  Future<List<CatalogPromotionEntity>> _loadPromotions() async {
    final useCase = di.sl<GetActivePromotionsUseCase>();
    final result = await useCase.execute();
    return result.fold(
      (failure) => throw Exception(failure.message),
      (promotions) => promotions,
    );
  }

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    final maxHeight = MediaQuery.of(context).size.height * 0.75;

    return Container(
      constraints: BoxConstraints(maxHeight: maxHeight),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Handle bar ──────────────────────────────────────────────
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // ── Header ──────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 16, 12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: ColorPalette.appetizingOrange.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.confirmation_number_outlined,
                      color: ColorPalette.appetizingOrange,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Khuyến mãi có thể áp dụng',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: ColorPalette.warmDarkGrey,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Chọn mã giảm giá cho đơn hàng hiện tại',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.grey, size: 20),
                    tooltip: 'Đóng',
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // ── Content ─────────────────────────────────────────────────
            Flexible(
              child: FutureBuilder<List<CatalogPromotionEntity>>(
                future: _promotionsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.all(48.0),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: ColorPalette.appetizingOrange,
                        ),
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.error_outline,
                              color: ColorPalette.error, size: 40),
                          const SizedBox(height: 12),
                          Text(
                            'Lỗi tải khuyến mãi: ${snapshot.error}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: ColorPalette.error),
                          ),
                          const SizedBox(height: 12),
                          TextButton.icon(
                            onPressed: () {
                              setState(() {
                                _promotionsFuture = _loadPromotions();
                              });
                            },
                            icon: const Icon(Icons.refresh),
                            label: const Text('Thử lại'),
                          ),
                        ],
                      ),
                    );
                  }

                  final promotions = snapshot.data ?? [];
                  if (promotions.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(40.0),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.discount_outlined,
                                size: 48, color: Colors.grey),
                            SizedBox(height: 12),
                            Text(
                              'Hiện không có chương trình khuyến mãi nào',
                              style: TextStyle(
                                  color: Colors.grey, fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return BlocBuilder<CartCubit, CartState>(
                    builder: (context, cartState) {
                      final subtotal = cartState.subtotal;
                      final appliedCode =
                          cartState.appliedPromotion?.promotionCode;

                      return ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: promotions.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final promo = promotions[index];
                          final isApplied = appliedCode == promo.promotionCode;
                          final minOrder = promo.minimumOrderAmount ?? 0.0;
                          final isEligible = subtotal >= minOrder;
                          final missingAmount = minOrder - subtotal;

                          return _PromotionCard(
                            promo: promo,
                            currency: currency,
                            isApplied: isApplied,
                            isEligible: isEligible,
                            missingAmount: missingAmount,
                            onApply: () {
                              context
                                  .read<CartCubit>()
                                  .applyPromotion(promo.promotionCode);
                              Navigator.pop(context);
                            },
                            onRemove: () {
                              context.read<CartCubit>().removePromotion();
                            },
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PromotionCard extends StatelessWidget {
  final CatalogPromotionEntity promo;
  final NumberFormat currency;
  final bool isApplied;
  final bool isEligible;
  final double missingAmount;
  final VoidCallback onApply;
  final VoidCallback onRemove;

  const _PromotionCard({
    required this.promo,
    required this.currency,
    required this.isApplied,
    required this.isEligible,
    required this.missingAmount,
    required this.onApply,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isApplied
            ? Colors.green.shade50
            : (isEligible ? Colors.white : Colors.grey.shade50),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isApplied
              ? Colors.green
              : (isEligible ? Colors.orange.shade200 : Colors.grey.shade300),
          width: isApplied ? 1.5 : 1,
        ),
        boxShadow: isEligible && !isApplied
            ? [
                BoxShadow(
                  color: Colors.orange.withOpacity(0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Code Badge & Discount Value Label
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isApplied
                      ? Colors.green.shade100
                      : ColorPalette.appetizingOrange.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.local_offer,
                      size: 13,
                      color: isApplied
                          ? Colors.green.shade800
                          : ColorPalette.appetizingOrange,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      promo.promotionCode,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: isApplied
                            ? Colors.green.shade900
                            : ColorPalette.appetizingOrange,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isApplied ? Colors.green : ColorPalette.deepOrange,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  promo.discountLabel,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Promotion Name & Description
          Text(
            promo.promotionName,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: ColorPalette.warmDarkGrey,
            ),
          ),
          if (promo.description != null && promo.description!.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              promo.description!,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],

          const SizedBox(height: 8),
          const Divider(height: 1),
          const SizedBox(height: 8),

          // Bottom Info: Min Order + Expiry & Action Button
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (promo.minimumOrderAmount != null &&
                        promo.minimumOrderAmount! > 0)
                      Text(
                        'Đơn tối thiểu: ${currency.format(promo.minimumOrderAmount)}',
                        style: TextStyle(
                          fontSize: 11,
                          color: isEligible
                              ? Colors.grey.shade700
                              : ColorPalette.error,
                          fontWeight:
                              isEligible ? FontWeight.normal : FontWeight.w600,
                        ),
                      ),
                    Text(
                      'HSD: ${dateFormat.format(promo.endDate)}',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    if (!isEligible && missingAmount > 0)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          'Cần mua thêm ${currency.format(missingAmount)}',
                          style: const TextStyle(
                            fontSize: 10,
                            color: ColorPalette.error,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (isApplied)
                OutlinedButton(
                  onPressed: onRemove,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    minimumSize: const Size(60, 32),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Gỡ',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                )
              else
                ElevatedButton(
                  onPressed: isEligible ? onApply : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorPalette.appetizingOrange,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey.shade300,
                    disabledForegroundColor: Colors.grey.shade500,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    minimumSize: const Size(80, 32),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    isEligible ? 'Áp dụng' : 'Chưa đủ điều kiện',
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
