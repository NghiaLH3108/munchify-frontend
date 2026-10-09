import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../customers/presentation/bloc/customer_bloc.dart';
import '../../../customers/presentation/bloc/customer_state.dart';
import '../../../customers/presentation/bloc/customer_event.dart';
import 'package:dio/dio.dart';
import 'package:munchify_frontend/core/constants/AppConstants.dart';

class CartSummaryBottomBar extends StatelessWidget {
  const CartSummaryBottomBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, -4),
            blurRadius: 10,
          )
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Cart Icon with Badge
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.shopping_cart_outlined, color: Color(0xFFE65100)),
                ),
                Positioned(
                  top: -6,
                  right: -6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFBF360C),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text('3 món', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
            
            const SizedBox(width: 16),
            
            // Total amount & Customer Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    currencyFormat.format(105000),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  BlocBuilder<CustomerBloc, CustomerState>(
                    builder: (context, customerState) {
                      if (customerState is CustomerSelected) {
                        return Row(
                          children: [
                            const Icon(Icons.verified_user_outlined, size: 12, color: Colors.green),
                            const SizedBox(width: 4),
                            Text(
                              '${customerState.customer.customerName} (${customerState.customer.loyaltyPoints} điểm)',
                              style: const TextStyle(color: Colors.grey, fontSize: 12),
                            ),
                          ],
                        );
                      }
                      return const Text('Khách lẻ', style: TextStyle(color: Colors.grey, fontSize: 12));
                    },
                  ),
                ],
              ),
            ),
            
            // Checkout Button
            BlocBuilder<CustomerBloc, CustomerState>(
              builder: (context, customerState) {
                return ElevatedButton(
                  onPressed: () async {
                    int? customerId;
                    if (customerState is CustomerSelected) {
                      customerId = customerState.customer.customerId; // Assuming customerId is the property name
                    }
                    
                    try {
                      final dio = Dio();
                      final response = await dio.post('${AppConstants.baseUrl}/api/orders/checkout-test', data: {
                        'customerId': customerId,
                        'totalAmount': 105000,
                        'pointsRedeemed': 0
                      });
                      
                      if (response.statusCode == 200) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Thanh toán thành công! Tích được ${response.data['pointsEarned']} điểm.')),
                        );
                        
                        // Lấy lại dữ liệu khách hàng để cập nhật điểm mới nhất trên giao diện
                        if (customerState is CustomerSelected) {
                           context.read<CustomerBloc>().add(SearchCustomerByPhoneEvent(customerState.customer.phone));
                        }
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Lỗi thanh toán: $e')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFBF360C),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Row(
                    children: const [
                      Text('Thanh\ntoán', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward),
                    ],
                  ),
                );
              }
            ),
          ],
        ),
      ),
    );
  }
}
