import 'package:flutter/material.dart';

import '../../../../core/theme/ColorPalette.dart';

class ComboDeleteConfirmDialog extends StatelessWidget {
  final String comboName;

  const ComboDeleteConfirmDialog({super.key, required this.comboName});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 420,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                color: Color(0xFFFFEBEE),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.delete_outline_rounded,
                  color: ColorPalette.dangerCrimson, size: 32),
            ),
            const SizedBox(height: 16),
            const Text(
              'Xác nhận xóa combo',
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 8),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  height: 1.5,
                  color: ColorPalette.textMuted,
                ),
                children: [
                  const TextSpan(text: 'Bạn có chắc muốn xóa combo '),
                  TextSpan(
                    text: '"$comboName"',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const TextSpan(
                    text: ' không? Combo đã có lịch sử giao dịch sẽ được '
                        'chuyển sang trạng thái ngừng bán thay vì xóa hẳn.',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF475569),
                    minimumSize: const Size.fromHeight(48),
                    side: const BorderSide(color: ColorPalette.borderSubtle),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Hủy bỏ'),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEF5350),
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Xác nhận xóa'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
