import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/AppConstants.dart';
import '../../../../core/theme/ColorPalette.dart';
import '../../domain/entities/customer_entity.dart';
import '../bloc/customer_bloc.dart';
import '../bloc/customer_event.dart';
import '../bloc/customer_state.dart';
import 'add_customer_bottom_sheet.dart';
import '../../../../core/widgets/app_toast.dart';

class CustomerLookupBottomSheet extends StatefulWidget {
  const CustomerLookupBottomSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
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
    setState(() {});
    _debounce?.cancel();
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      context.read<CustomerBloc>().add(const SuggestCustomersByPhoneEvent(''));
      return;
    }
    _debounce = Timer(
      Duration(milliseconds: AppConstants.searchDebounceMs),
      () {
        if (!mounted) return;
        context.read<CustomerBloc>().add(
          SuggestCustomersByPhoneEvent(trimmed),
        );
      },
    );
  }

  void _onSearch() {
    _debounce?.cancel();
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      AppToast.warning('Vui lòng nhập số điện thoại để tìm kiếm', context: context);
      return;
    }
    context.read<CustomerBloc>().add(SuggestCustomersByPhoneEvent(phone));
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
                    autofocus: true,
                    onChanged: _onPhoneChanged,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(10),
                    ],
                    decoration: InputDecoration(
                      hintText: 'Nhập số điện thoại (VD: 0912...)',
                      hintStyle: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 14,
                      ),
                      prefixIcon: const Icon(
                        Icons.phone,
                        color: ColorPalette.appetizingOrange,
                      ),
                      suffixIcon: _phoneController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 18),
                              onPressed: () {
                                _phoneController.clear();
                                _onPhoneChanged('');
                              },
                            )
                          : null,
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

            // Search result / suggestions
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

                if (state is CustomerSuggestionsLoaded) {
                  return _buildSuggestionsList(state.customers);
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
                        'Nhập số điện thoại để hiển thị gợi ý khách hàng',
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

  Widget _buildSuggestionsList(List<CustomerEntity> customers) {
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            'Đề xuất khách hàng (${customers.length}):',
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: ColorPalette.textSecondary,
            ),
          ),
        ),
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 260),
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: customers.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final customer = customers[index];
              final pointsValue =
                  customer.loyaltyPoints * AppConstants.pointsToVndRate;

              return InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  context
                      .read<CustomerBloc>()
                      .add(SelectCustomerEvent(customer));
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: ColorPalette.success.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: ColorPalette.success.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor:
                            ColorPalette.success.withValues(alpha: 0.15),
                        child: const Icon(
                          Icons.person,
                          color: ColorPalette.success,
                          size: 20,
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
                                fontSize: 14.5,
                                color: ColorPalette.warmDarkGrey,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${customer.phone} • Quy đổi: ${currencyFormat.format(pointsValue)}',
                              style: const TextStyle(
                                color: ColorPalette.textSecondary,
                                fontSize: 12,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: ColorPalette.amber.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.star,
                              color: ColorPalette.amber,
                              size: 14,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              '${customer.loyaltyPoints} đ',
                              style: const TextStyle(
                                color: ColorPalette.warmDarkGrey,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(
                        Icons.check_circle_rounded,
                        color: ColorPalette.success,
                        size: 22,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
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
            'Không tìm thấy khách hàng khớp với "$phone"',
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
