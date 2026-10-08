import 'package:flutter/material.dart';

import '../../../../core/constants/AppConstants.dart';
import '../../../../core/theme/ColorPalette.dart';

/// Selector để chọn phương thức thanh toán: CASH, QR_CODE, BANK_TRANSFER.
class PaymentMethodSelector extends StatelessWidget {
  final String selectedMethod;
  final ValueChanged<String> onChanged;

  const PaymentMethodSelector({
    Key? key,
    required this.selectedMethod,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _MethodOption(
          label: 'Tiền mặt',
          icon: Icons.payments_outlined,
          value: AppConstants.paymentCash,
          selected: selectedMethod,
          color: ColorPalette.cashColor,
          onTap: onChanged,
        ),
        const SizedBox(width: 10),
        _MethodOption(
          label: 'QR Code',
          icon: Icons.qr_code_scanner,
          value: AppConstants.paymentQrCode,
          selected: selectedMethod,
          color: ColorPalette.qrCodeColor,
          onTap: onChanged,
        ),
        const SizedBox(width: 10),
        _MethodOption(
          label: 'Chuyển khoản',
          icon: Icons.account_balance_outlined,
          value: AppConstants.paymentBankTransfer,
          selected: selectedMethod,
          color: ColorPalette.bankTransferColor,
          onTap: onChanged,
        ),
      ],
    );
  }
}

class _MethodOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final String value;
  final String selected;
  final Color color;
  final ValueChanged<String> onTap;

  const _MethodOption({
    required this.label,
    required this.icon,
    required this.value,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = selected == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.12) : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? color : Colors.grey.shade200,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: isSelected ? color : Colors.grey, size: 22),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight:
                      isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? color : Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
