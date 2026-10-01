import 'package:flutter/material.dart';

class UnitDeleteConfirmDialog extends StatelessWidget {
  final String unitName;

  const UnitDeleteConfirmDialog({Key? key, required this.unitName})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                color: Color(0xFFFFEBEE),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.delete_outline_rounded,
                color: Color(0xFFD32F2F),
                size: 32,
              ),
            ),
            const SizedBox(height: 16),

            // Title
            const Text(
              'Xác nhận xóa đơn vị',
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 8),

            // Description
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  height: 1.5,
                  color: Color(0xFF64748B),
                ),
                children: [
                  const TextSpan(text: 'Bạn có chắc muốn xóa đơn vị tính '),
                  TextSpan(
                    text: '"$unitName"',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const TextSpan(
                      text:
                          ' không? Đơn vị đang được dùng bởi sản phẩm sẽ không thể xóa.'),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Actions
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF475569),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: Color(0xFFE2E8F0)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    textStyle: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  child: const Text('Hủy bỏ'),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEF5350),
                    foregroundColor: Colors.white,
                    elevation: 2,
                    shadowColor: const Color(0xFFEF5350).withOpacity(0.4),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    textStyle: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
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
