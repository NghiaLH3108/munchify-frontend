import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/ColorPalette.dart';
import '../../../customers/presentation/bloc/customer_bloc.dart';
import '../../../customers/presentation/bloc/customer_state.dart';
import '../../../customers/presentation/widgets/add_customer_bottom_sheet.dart';
import '../../../customers/presentation/widgets/customer_lookup_bottom_sheet.dart';
import '../../../customers/presentation/widgets/customer_loyalty_card.dart';

/// Hàng tra cứu nhanh khách hàng (SĐT tích điểm) + nút thêm khách mới.
class CustomerQuickRow extends StatelessWidget {
  const CustomerQuickRow({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CustomerBloc, CustomerState>(
      buildWhen: (prev, curr) =>
          curr is CustomerSelected ||
          curr is CustomerInitial ||
          curr is CustomerCreated,
      builder: (context, state) {
        if (state is CustomerSelected) {
          return const CustomerLoyaltyCard();
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => CustomerLookupBottomSheet.show(context),
                  child: Container(
                    constraints: const BoxConstraints(minHeight: 48),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.phone,
                            size: 16, color: ColorPalette.appetizingOrange),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Nhập SĐT khách (Tích điểm)...',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                color: ColorPalette.textHint, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: () => AddCustomerBottomSheet.show(context),
                icon: const Icon(Icons.person_add, size: 16),
                label: const Text('Thêm khách'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(48, 48),
                  backgroundColor: ColorPalette.amberButton,
                  foregroundColor: ColorPalette.onPrimary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  elevation: 0,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

