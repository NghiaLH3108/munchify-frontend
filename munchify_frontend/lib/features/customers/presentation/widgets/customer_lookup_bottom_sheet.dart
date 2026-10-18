import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/AppConstants.dart';
import '../../../../core/theme/ColorPalette.dart';
import '../../../../core/utils/Validators.dart';
import '../bloc/customer_bloc.dart';
import '../bloc/customer_event.dart';
import '../bloc/customer_state.dart';
import 'add_customer_bottom_sheet.dart';

class CustomerLookupBottomSheet extends StatefulWidget {
  const CustomerLookupBottomSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      showDragHandle: false,
      builder: (_) => BlocProvider.value(
        value: context.read<CustomerBloc>(),
        child: const CustomerLookupBottomSheet(),
      ),
    );
  }

  @override
  State<CustomerLookupBottomSheet> createState() =>
      _CustomerLookupBottomSheetState();
}

class _CustomerLookupBottomSheetState extends State<CustomerLookupBottomSheet> {
  final _phoneController = TextEditingController();
  Timer? _debounce;

  void _onPhoneChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(
      Duration(milliseconds: AppConstants.searchDebounceMs),
      () {
        if (value.trim().length >= 10) {
          context.read<CustomerBloc>().add(
            SearchCustomerByPhoneEvent(value.trim()),
          );
        }
      },
    );
  }

  void _onSearch() {
    final phone = _phoneController.text.trim();
    final error = Validators.validatePhoneNumber(phone);
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: ColorPalette.error),
      );
      return;
    }
    context.read<CustomerBloc>().add(SearchCustomerByPhoneEvent(phone));
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.only(bottom: bottomInset),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),

            // Title
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: ColorPalette.appetizingOrange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.person_search,
                    color: ColorPalette.appetizingOrange,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Tra cứu khách hàng',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: ColorPalette.warmDarkGrey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Phone input
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _phoneController,
                    onChanged: _onPhoneChanged,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(10),
                    ],
                    decoration: InputDecoration(
                      hintText: 'Nhập số điện thoại (VD: 0912345678)',
                      hintStyle: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 14,
                      ),
                      prefixIcon: const Icon(
                        Icons.phone,
                        color: ColorPalette.appetizingOrange,
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: ColorPalette.appetizingOrange,
                          width: 2,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _onSearch,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorPalette.appetizingOrange,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Icon(Icons.search),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Search result
            BlocConsumer<CustomerBloc, CustomerState>(
              listener: (context, state) {
                if (state is CustomerSelected || state is CustomerCreated) {
                  Navigator.of(context).pop();
                }
              },
              builder: (context, state) {
                if (state is CustomerSearching) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: CircularProgressIndicator(
                      color: ColorPalette.appetizingOrange,
                    ),
                  );
                }

                if (state is CustomerFound) {
                  return _buildCustomerCard(state.customer);
                }

                if (state is CustomerNotFound) {
                  return _buildNotFoundCard(state.phone);
                }

                if (state is CustomerError) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      state.message,
                      style: const TextStyle(color: ColorPalette.error),
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                // Initial
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Column(
                    children: [
                      Icon(
                        Icons.phone_android,
                        size: 48,
                        color: Colors.grey.shade300,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Nhập số điện thoại để tra cứu thông tin khách hàng',
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 13,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerCard(dynamic customer) {
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    final pointsValue = customer.loyaltyPoints * AppConstants.pointsToVndRate;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ColorPalette.success.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ColorPalette.success.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: ColorPalette.success.withValues(alpha: 0.15),
                child: const Icon(Icons.person, color: ColorPalette.success),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      customer.customerName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: ColorPalette.warmDarkGrey,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      customer.phone,
                      style: const TextStyle(
                        color: ColorPalette.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: ColorPalette.amber.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star, color: ColorPalette.amber, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '${customer.loyaltyPoints} điểm',
                      style: const TextStyle(
                        color: ColorPalette.warmDarkGrey,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Giá trị quy đổi: ${currencyFormat.format(pointsValue)}',
            style: const TextStyle(
              color: ColorPalette.textSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: () {
                context.read<CustomerBloc>().add(SelectCustomerEvent(customer));
              },
              icon: const Icon(Icons.check_circle_outline, size: 18),
              label: const Text('Chọn khách hàng này'),
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorPalette.success,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotFoundCard(String phone) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ColorPalette.amber.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ColorPalette.amber.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          const Icon(Icons.person_off, color: ColorPalette.amber, size: 40),
          const SizedBox(height: 8),
          Text(
            'Không tìm thấy khách hàng với SĐT "$phone"',
            style: const TextStyle(
              color: ColorPalette.warmDarkGrey,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                AddCustomerBottomSheet.show(context, initialPhone: phone);
              },
              icon: const Icon(Icons.person_add, size: 18),
              label: const Text('Thêm khách hàng mới'),
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorPalette.appetizingOrange,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
