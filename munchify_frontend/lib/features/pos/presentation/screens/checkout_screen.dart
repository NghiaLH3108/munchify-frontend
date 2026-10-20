import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
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

/// Màn hình thanh toán chuẩn POS Munchify – hỗ trợ Cash, VietQR, Bank Transfer
class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({Key? key}) : super(key: key);

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String _paymentMethod = AppConstants.paymentCash;
  final _cashController = TextEditingController();
  double _cashGiven = 0;

  // Trạng thái giả lập thanh toán VietQR (chỉ khi khách quét hoặc bấm giả lập mới chuyển true)
  bool _isQrPaid = false;

  // Cấu hình tài khoản ngân hàng quán (đồng bộ appsettings.json Backend)
  final String _bankId = 'MB';
  final String _bankName = 'MB Bank (Napas 247)';
  final String _accountNo = '0383344686';
  final String _accountName = 'MUNCHIFY STORE';

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
          context.read<CartCubit>().clearCart();
          context.read<CustomerBloc>().add(ClearSelectedCustomerEvent());

          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  Icon(
                    Icons.check_circle_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Text('Thanh toán thành công!'),
                ],
              ),
              backgroundColor: ColorPalette.success,
              behavior: SnackBarBehavior.floating,
            ),
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
          elevation: 0.5,
          title: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Thanh toán đơn hàng',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
              ),
              Text(
                'Quầy thu ngân POS',
                style: TextStyle(
                  fontSize: 11,
                  color: ColorPalette.textSecondary,
                ),
              ),
            ],
          ),
          actions: [
            Container(
              margin: const EdgeInsets.only(right: 14),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: ColorPalette.appetizingOrange.withValues(
                        alpha: 0.15,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person_rounded,
                      size: 14,
                      color: ColorPalette.appetizingOrange,
                    ),
                  ),
                  const SizedBox(width: 7),
                  const Text(
                    'Thu ngân: Admin',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF334155),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        body: BlocBuilder<CartCubit, CartState>(
          builder: (context, cartState) {
            return BlocBuilder<CustomerBloc, CustomerState>(
              builder: (context, customerState) {
                final pointsDiscount = customerState is CustomerSelected
                    ? customerState.discountFromPoints.toDouble()
                    : 0.0;
                final amountAfterVoucher =
                    (cartState.subtotal - cartState.discountAmount).clamp(
                      0.0,
                      double.infinity,
                    );
                final effectivePointsDiscount = pointsDiscount.clamp(
                  0.0,
                  amountAfterVoucher,
                );
                final finalTotal = amountAfterVoucher - effectivePointsDiscount;

                return Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ── 1. Tóm tắt đơn hàng + Khách hàng ───────────
                            _OrderSummaryCard(
                              cartState: cartState,
                              customerState: customerState,
                              pointsDiscount: effectivePointsDiscount,
                              finalTotal: finalTotal,
                              currency: currency,
                            ),
                            const SizedBox(height: 18),

                            // ── 2. Bộ chọn phương thức thanh toán ──────────
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: const [
                                Text(
                                  'Phương thức thanh toán',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                                Text(
                                  'Chạm để đổi',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: ColorPalette.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            PaymentMethodSelector(
                              selectedMethod: _paymentMethod,
                              onChanged: (m) => setState(() {
                                _paymentMethod = m;
                                _isQrPaid = false; // Reset trạng thái quét QR khi đổi phương thức
                              }),
                            ),
                            const SizedBox(height: 16),

                            // ── 3. Nội dung chi tiết theo phương thức ───────
                            if (_paymentMethod == AppConstants.paymentCash) ...[
                              _buildCashSection(finalTotal, currency),
                            ] else if (_paymentMethod ==
                                AppConstants.paymentQrCode) ...[
                              _buildVietQrSection(finalTotal),
                            ],

                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),

                    // ── 5. Nút xác nhận thanh toán dính đáy ─────────────
                    _ConfirmButton(
                      paymentMethod: _paymentMethod,
                      finalTotal: finalTotal,
                      cashGiven: _cashGiven,
                      isQrPaid: _isQrPaid,
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

  // ───────────────────────────────────────────────────────────────────────────
  // KHỐI TIỀN MẶT (PAY BY CASH)
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildCashSection(double finalTotal, NumberFormat currency) {
    final bool isEnough = _cashGiven >= finalTotal;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                'Tiền khách đưa',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Color(0xFF1E293B),
                ),
              ),
              Row(
                children: [
                  Icon(
                    Icons.flash_on_rounded,
                    size: 15,
                    color: ColorPalette.appetizingOrange,
                  ),
                  SizedBox(width: 3),
                  Text(
                    'Gợi ý tiền chẵn nhanh',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: ColorPalette.appetizingOrange,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Nút tiền chẵn nhanh + Nút đưa đúng tiền
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              // Nút Đưa đúng số tiền
              InkWell(
                onTap: () {
                  setState(() {
                    _cashGiven = finalTotal;
                    _cashController.text = finalTotal.toInt().toString();
                  });
                },
                borderRadius: BorderRadius.circular(10),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    gradient: _cashGiven == finalTotal
                        ? const LinearGradient(
                            colors: [
                              ColorPalette.appetizingOrange,
                              Color(0xFFE65100),
                            ],
                          )
                        : null,
                    color: _cashGiven == finalTotal
                        ? null
                        : const Color(0xFFFFF7ED),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: ColorPalette.appetizingOrange,
                      width: _cashGiven == finalTotal ? 1.5 : 1.2,
                    ),
                    boxShadow: _cashGiven == finalTotal
                        ? [
                            BoxShadow(
                              color: ColorPalette.appetizingOrange.withValues(
                                alpha: 0.3,
                              ),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ]
                        : [],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle_rounded,
                        size: 15,
                        color: _cashGiven == finalTotal
                            ? Colors.white
                            : ColorPalette.appetizingOrange,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Đúng số tiền (${currency.format(finalTotal)})',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.bold,
                          color: _cashGiven == finalTotal
                              ? Colors.white
                              : ColorPalette.appetizingOrange,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Danh sách mệnh giá chẵn
              ...AppConstants.quickCashAmounts.map((amount) {
                final isSelected = _cashGiven == amount.toDouble();
                return InkWell(
                  onTap: () {
                    setState(() {
                      _cashGiven = amount.toDouble();
                      _cashController.text = amount.toString();
                    });
                  },
                  borderRadius: BorderRadius.circular(10),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 9,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF1E293B)
                          : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF1E293B)
                            : const Color(0xFFE2E8F0),
                        width: 1,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.15),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : [],
                    ),
                    child: Text(
                      currency.format(amount),
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.w600,
                        color: isSelected
                            ? Colors.white
                            : const Color(0xFF475569),
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
          const SizedBox(height: 16),

          // Ô nhập tiền mặt
          TextField(
            controller: _cashController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
            decoration: InputDecoration(
              hintText: 'Nhập số tiền khác...',
              hintStyle: const TextStyle(
                color: Color(0xFF94A3B8),
                fontSize: 15,
                fontWeight: FontWeight.normal,
              ),
              prefixIcon: Container(
                margin: const EdgeInsets.all(8),
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: ColorPalette.cashColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.payments_rounded,
                  color: ColorPalette.cashColor,
                  size: 20,
                ),
              ),
              suffixText: 'VNĐ',
              suffixStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF64748B),
                fontSize: 13,
              ),
              suffixIcon: IconButton(
                icon: const Icon(
                  Icons.cancel_rounded,
                  size: 20,
                  color: Color(0xFF94A3B8),
                ),
                onPressed: () {
                  setState(() {
                    _cashGiven = 0;
                    _cashController.clear();
                  });
                },
              ),
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
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
            onChanged: (v) =>
                setState(() => _cashGiven = double.tryParse(v) ?? 0),
          ),
          const SizedBox(height: 14),

          // Khối tính tiền thối lại (Calculate Change)
          AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              gradient: isEnough
                  ? const LinearGradient(
                      colors: [Color(0xFFF0FDF4), Color(0xFFDCFCE7)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : const LinearGradient(
                      colors: [Color(0xFFFEF2F2), Color(0xFFFEE2E2)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isEnough
                    ? const Color(0xFF86EFAC)
                    : const Color(0xFFFCA5A5),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: (isEnough ? Colors.green : Colors.red).withValues(
                    alpha: 0.05,
                  ),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color:
                            (isEnough
                                    ? const Color(0xFF16A34A)
                                    : const Color(0xFFDC2626))
                                .withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isEnough
                            ? Icons.check_rounded
                            : Icons.info_outline_rounded,
                        color: isEnough
                            ? const Color(0xFF15803D)
                            : const Color(0xFFB91C1C),
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      isEnough
                          ? 'Tiền thối lại cho khách:'
                          : 'Khách còn thiếu:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13.5,
                        color: isEnough
                            ? const Color(0xFF166534)
                            : const Color(0xFF991B1B),
                      ),
                    ),
                  ],
                ),
                Text(
                  currency.format(
                    isEnough
                        ? _getChange(finalTotal)
                        : (finalTotal - _cashGiven),
                  ),
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                    color: isEnough
                        ? const Color(0xFF15803D)
                        : const Color(0xFFDC2626),
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // KHỐI QUÉT MÃ VIETQR (PAY BY VIETQR)
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildVietQrSection(double finalTotal) {
    final String addInfo = 'MUNCHIFY POS';
    final String qrImageUrl =
        'https://img.vietqr.io/image/$_bankId-$_accountNo-compact2.png?amount=${finalTotal.toInt()}&addInfo=${Uri.encodeComponent(addInfo)}&accountName=${Uri.encodeComponent(_accountName)}';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ColorPalette.border),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(
                Icons.qr_code_2_rounded,
                color: ColorPalette.qrCodeColor,
                size: 20,
              ),
              SizedBox(width: 6),
              Text(
                'Quét mã VietQR chuyển khoản nhanh',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: ColorPalette.qrCodeColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              // Flutter Web nhận SVG từ VietQR API (do CORS), native nhận PNG.
              child: kIsWeb
                  ? SvgPicture.network(
                      qrImageUrl,
                      width: 200,
                      height: 200,
                      fit: BoxFit.contain,
                      placeholderBuilder: (_) => const SizedBox(
                        width: 200,
                        height: 200,
                        child: Center(
                          child: CircularProgressIndicator(strokeWidth: 2.5),
                        ),
                      ),
                    )
                  : Image.network(
                      qrImageUrl,
                      width: 200,
                      height: 200,
                      fit: BoxFit.contain,
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return const SizedBox(
                          width: 200,
                          height: 200,
                          child: Center(
                            child: CircularProgressIndicator(strokeWidth: 2.5),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        debugPrint('QR Load Error: $error\nStack: $stackTrace');
                        return Container(
                          width: 200,
                          height: 200,
                          color: Colors.grey.shade100,
                          child: const Center(
                            child: Text(
                              'Không tải được mã QR',
                              style: TextStyle(color: Colors.grey, fontSize: 12),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ),
          const SizedBox(height: 14),

          // ── Khối trạng thái & Giả lập thanh toán VietQR (Sleek Minimal Fintech) ──
          if (!_isQrPaid) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFF86EFAC), width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withValues(alpha: 0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Pulse loader icon
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: const Color(0xFF16A34A).withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFF16A34A),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Đang chờ tín hiệu chuyển khoản...',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF166534),
                          ),
                        ),
                        SizedBox(height: 1),
                        Text(
                          'Quét QR trên app ngân hàng / ví điện tử',
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF15803D),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    icon: const Icon(
                      Icons.flash_on_rounded,
                      size: 15,
                      color: Colors.white,
                    ),
                    label: const Text(
                      'Khách đã CK',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF16A34A),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      setState(() => _isQrPaid = true);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(
                            children: const [
                              Icon(
                                Icons.check_circle_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                              SizedBox(width: 10),
                              Text(
                                'Ghi nhận chuyển khoản thành công!',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                          backgroundColor: const Color(0xFF16A34A),
                          duration: const Duration(seconds: 2),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ] else ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFF86EFAC), width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Color(0xFF16A34A),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Đã nhận thanh toán VietQR!',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF15803D),
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Khách đã thanh toán đủ • Sẵn sàng xác nhận đơn',
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF166534),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Order Summary Card ─────────────────────────────────────────────────────
class _OrderSummaryCard extends StatelessWidget {
  final CartState cartState;
  final CustomerState customerState;
  final double pointsDiscount;
  final double finalTotal;
  final NumberFormat currency;

  const _OrderSummaryCard({
    required this.cartState,
    required this.customerState,
    required this.pointsDiscount,
    required this.finalTotal,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    final customer = customerState is CustomerSelected
        ? (customerState as CustomerSelected).customer
        : null;
    final pointsToRedeem = customerState is CustomerSelected
        ? (customerState as CustomerSelected).pointsToRedeem
        : 0;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header khách hàng thân thiết nếu có
          if (customer != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                color: Color(0xFFFFF7ED),
                borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
                border: Border(bottom: BorderSide(color: Color(0xFFFFEDD5))),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: ColorPalette.appetizingOrange.withValues(
                            alpha: 0.15,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.person_rounded,
                          size: 18,
                          color: ColorPalette.appetizingOrange,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${customer.customerName} • ${customer.phone}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13.5,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          const Text(
                            'Khách hàng thân thiết',
                            style: TextStyle(
                              fontSize: 11,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: ColorPalette.appetizingOrange,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${customer.loyaltyPoints} điểm',
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Row('Tạm tính', currency.format(cartState.subtotal)),
                if (cartState.discountAmount > 0)
                  _Row(
                    'Giảm giá / Voucher',
                    '- ${currency.format(cartState.discountAmount)}',
                    valueColor: const Color(0xFF0284C7),
                  ),
                if (pointsDiscount > 0)
                  _Row(
                    'Đổi $pointsToRedeem điểm tích lũy',
                    '- ${currency.format(pointsDiscount)}',
                    valueColor: const Color(0xFF16A34A),
                  ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Divider(
                    height: 1,
                    thickness: 1,
                    color: Color(0xFFF1F5F9),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Tổng thanh toán',
                          style: TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF334155),
                          ),
                        ),
                        const SizedBox(height: 4),
                        InkWell(
                          onTap: () => _showItemsPreview(context),
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF7ED),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: const Color(0xFFFFEDD5),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '${cartState.itemCount} món trong giỏ',
                                  style: const TextStyle(
                                    fontSize: 11.5,
                                    color: ColorPalette.appetizingOrange,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.unfold_more_rounded,
                                  size: 14,
                                  color: ColorPalette.appetizingOrange,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      currency.format(finalTotal),
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: ColorPalette.appetizingOrange,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showItemsPreview(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Danh sách món thanh toán',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      '${cartState.itemCount} món',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: ColorPalette.appetizingOrange,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 8),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: cartState.items.length,
                    separatorBuilder: (_, __) => const Divider(height: 12),
                    itemBuilder: (context, index) {
                      final item = cartState.items[index];
                      return Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF7F3EE),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'x${item.quantity}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: ColorPalette.appetizingOrange,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              item.productName,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13.5,
                              ),
                            ),
                          ),
                          Text(
                            currency.format(item.totalPrice),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _Row(this.label, this.value, {this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: ColorPalette.textSecondary,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: valueColor ?? ColorPalette.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Confirm Button ─────────────────────────────────────────────────────────
class _ConfirmButton extends StatelessWidget {
  final String paymentMethod;
  final double finalTotal;
  final double cashGiven;
  final bool isQrPaid;
  final CartState cartState;
  final CustomerState customerState;
  final NumberFormat currency;

  const _ConfirmButton({
    required this.paymentMethod,
    required this.finalTotal,
    required this.cashGiven,
    required this.isQrPaid,
    required this.cartState,
    required this.customerState,
    required this.currency,
  });

  bool get _canConfirm {
    if (paymentMethod == AppConstants.paymentCash) {
      return cashGiven >= finalTotal;
    }
    if (paymentMethod == AppConstants.paymentQrCode) {
      return isQrPaid;
    }
    return true;
  }

  String get _buttonLabel {
    if (_canConfirm) {
      return 'Xác nhận Thanh toán • ${currency.format(finalTotal)}';
    }
    if (paymentMethod == AppConstants.paymentCash) {
      return 'Tiền đưa chưa đủ';
    }
    if (paymentMethod == AppConstants.paymentQrCode) {
      return 'Chờ khách quét mã QR';
    }
    return 'Xác nhận Thanh toán';
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OrderBloc, OrderState>(
      builder: (context, state) {
        final isLoading = state is OrderLoading;

        return Container(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 18),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: (_canConfirm && !isLoading)
                    ? () => _confirm(context)
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorPalette.appetizingOrange,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey.shade300,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _canConfirm
                                ? Icons.check_circle
                                : Icons.hourglass_top_rounded,
                            size: 20,
                            color: _canConfirm
                                ? Colors.white
                                : Colors.grey.shade600,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _buttonLabel,
                            style: TextStyle(
                              fontSize: 15.5,
                              fontWeight: FontWeight.bold,
                              color: _canConfirm
                                  ? Colors.white
                                  : Colors.grey.shade600,
                            ),
                          ),
                        ],
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

    final amountAfterVoucher = (cartState.subtotal - cartState.discountAmount)
        .clamp(0.0, double.infinity);
    final maxPointsNeeded = (amountAfterVoucher / AppConstants.pointsToVndRate)
        .ceil();
    final actualPointsToSend = pointsToRedeem > maxPointsNeeded
        ? maxPointsNeeded
        : pointsToRedeem;

    context.read<OrderBloc>().add(
      CreateOrderEvent(
        customerId: customer?.customerId,
        promotionCode: cartState.appliedPromotion?.promotionCode,
        paymentMethod: paymentMethod,
        pointsToRedeem: actualPointsToSend,
        cashGiven: paymentMethod == AppConstants.paymentCash ? cashGiven : null,
        items: cartState.items
            .map((i) => {'productId': i.productId, 'quantity': i.quantity})
            .toList(),
      ),
    );
  }
}
