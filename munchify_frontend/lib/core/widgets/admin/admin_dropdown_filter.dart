import 'package:flutter/material.dart';
import '../../theme/ColorPalette.dart';
import '../../theme/AppTypography.dart';

/// Reusable dropdown filter for Admin screens.
///
/// Styled to match Munchify POS theme:
/// - Warm cream background
/// - Border with subtle orange accent on focus
/// - Clean typography and proper padding
class AdminDropdownFilter<T> extends StatelessWidget {
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final String? hintText;
  final double? width;
  final IconData? prefixIcon;

  const AdminDropdownFilter({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
    this.hintText,
    this.width,
    this.prefixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBF8),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFFFE0B2), width: 1),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          items: items,
          onChanged: onChanged,
          hint: hintText != null
              ? Text(
                  hintText!,
                  style: AppTypography.inter(
                    fontSize: 13,
                    color: const Color(0xFF64748B),
                  ),
                )
              : null,
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            size: 18,
            color: ColorPalette.appetizingOrange,
          ),
          style: AppTypography.inter(
            fontSize: 13,
            color: const Color(0xFF1E293B),
            fontWeight: FontWeight.w500,
          ),
          dropdownColor: Colors.white,
          borderRadius: BorderRadius.circular(12),
          elevation: 4,
          isDense: true,
        ),
      ),
    );
  }
}
