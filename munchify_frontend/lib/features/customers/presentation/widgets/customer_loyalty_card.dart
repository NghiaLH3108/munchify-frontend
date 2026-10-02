import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/AppConstants.dart';
import '../../../../core/theme/ColorPalette.dart';
import '../../domain/entities/customer_entity.dart';
import '../bloc/customer_bloc.dart';
import '../bloc/customer_event.dart';
import '../bloc/customer_state.dart';

/// Compact loyalty card shown on POS Home when a customer is selected.
/// Displays customer info, loyalty points, and redemption toggle.
class CustomerLoyaltyCard extends StatelessWidget {
  const CustomerLoyaltyCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CustomerBloc, CustomerState>(
      buildWhen: (prev, curr) => curr is CustomerSelected,
      builder: (context, state) {
        if (state is! CustomerSelected) {
          return const SizedBox.shrink();
        }

        final customer = state.customer;
        final currencyFormat =
            NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: ColorPalette.appetizingOrange.withOpacity(0.3),
            ),
            boxShadow: [
              BoxShadow(
                color: ColorPalette.appetizingOrange.withOpacity(0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Customer info row + close button
              Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor:
                        ColorPalette.appetizingOrange.withOpacity(0.12),
                    child: Text(
                      customer.customerName.isNotEmpty
                          ? customer.customerName[0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                        color: ColorPalette.appetizingOrange,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          customer.customerName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: ColorPalette.warmDarkGrey,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          customer.phone,
                          style: const TextStyle(
                            color: ColorPalette.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Loyalty badge
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: ColorPalette.amber.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star,
                            color: ColorPalette.amber, size: 14),
                        const SizedBox(width: 3),
                        Text(
                          '${customer.loyaltyPoints}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: ColorPalette.warmDarkGrey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 4),
                  // Close button
                  SizedBox(
                    width: AppConstants.minTouchTargetDp,
                    height: AppConstants.minTouchTargetDp,
                    child: IconButton(
                      onPressed: () {
                        context
                            .read<CustomerBloc>()
                            .add(const ClearSelectedCustomerEvent());
                      },
                      icon: const Icon(Icons.close, size: 18),
                      color: ColorPalette.textSecondary,
                      padding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),

              // Loyalty redemption section (only show if customer has points)
              if (customer.loyaltyPoints > 0) ...[
                const Divider(height: 20),
                _buildRedemptionSection(
                    context, state, customer, currencyFormat),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildRedemptionSection(
    BuildContext context,
    CustomerSelected state,
    CustomerEntity customer,
    NumberFormat currencyFormat,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Toggle row
        Row(
          children: [
            const Icon(Icons.redeem,
                color: ColorPalette.appetizingOrange, size: 18),
            const SizedBox(width: 6),
            const Text(
              'Dùng điểm thưởng',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: ColorPalette.warmDarkGrey,
              ),
            ),
            const Spacer(),
            SizedBox(
              height: 28,
              child: Switch.adaptive(
                value: state.isRedeeming,
                onChanged: (value) {
                  context
                      .read<CustomerBloc>()
                      .add(ToggleRedeemPointsEvent(value));
                },
                activeColor: ColorPalette.appetizingOrange,
              ),
            ),
          ],
        ),

        // Slider and discount preview (only show when toggled on)
        if (state.isRedeeming) ...[
          const SizedBox(height: 8),
          // Points slider
          Row(
            children: [
              const Text('0', style: TextStyle(fontSize: 11, color: ColorPalette.textSecondary)),
              Expanded(
                child: SliderTheme(
                  data: SliderThemeData(
                    activeTrackColor: ColorPalette.appetizingOrange,
                    inactiveTrackColor:
                        ColorPalette.appetizingOrange.withOpacity(0.15),
                    thumbColor: ColorPalette.appetizingOrange,
                    overlayColor:
                        ColorPalette.appetizingOrange.withOpacity(0.12),
                    trackHeight: 4,
                    thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 8),
                  ),
                  child: Slider(
                    value: state.pointsToRedeem.toDouble(),
                    min: 0,
                    max: customer.loyaltyPoints.toDouble(),
                    divisions: customer.loyaltyPoints > 0
                        ? customer.loyaltyPoints
                        : 1,
                    onChanged: (value) {
                      context.read<CustomerBloc>().add(
                            UpdateRedeemPointsEvent(value.round()),
                          );
                    },
                  ),
                ),
              ),
              Text(
                '${customer.loyaltyPoints}',
                style: const TextStyle(
                    fontSize: 11, color: ColorPalette.textSecondary),
              ),
            ],
          ),
          // Discount preview
          Container(
            width: double.infinity,
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: ColorPalette.success.withOpacity(0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Đổi ${state.pointsToRedeem} điểm',
                  style: const TextStyle(
                    fontSize: 13,
                    color: ColorPalette.warmDarkGrey,
                  ),
                ),
                Text(
                  '−${currencyFormat.format(state.discountFromPoints)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: ColorPalette.success,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
