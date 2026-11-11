import 'package:flutter/material.dart';

/// Định nghĩa 1 cột cho [AdminDataTable].
///
/// - Cột co giãn: để [width] = null và đặt [flex].
/// - Cột cố định (#, THAO TÁC): đặt [width].
class AdminTableColumn<T> {
  final String label;
  final int flex;
  final double? width;
  final TextAlign align;
  final Widget Function(BuildContext context, T item, int index) cellBuilder;

  const AdminTableColumn({
    required this.label,
    required this.cellBuilder,
    this.flex = 1,
    this.width,
    this.align = TextAlign.left,
  });

  /// Cột số thứ tự '#' dạng badge tròn (giống màn Danh mục / Khách hàng).
  static AdminTableColumn<T> index<T>() => AdminTableColumn<T>(
        label: '#',
        width: 44,
        cellBuilder: (_, _, i) => AdminIndexBadge(index: i),
      );
}

/// Badge tròn hiển thị số thứ tự của hàng.
class AdminIndexBadge extends StatelessWidget {
  final int index;
  const AdminIndexBadge({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        width: 24,
        height: 24,
        decoration: const BoxDecoration(
          color: Color(0xFFF1F5F9),
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Text(
          '$index',
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: Color(0xFF64748B),
          ),
        ),
      ),
    );
  }
}

/// Nút thao tác vuông nhỏ có nền màu nhạt (Sửa / Xóa / Khóa ...).
class AdminRowActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback? onPressed;

  const AdminRowActionButton({
    super.key,
    required this.icon,
    required this.color,
    required this.tooltip,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, size: 18),
      color: color,
      tooltip: tooltip,
      style: IconButton.styleFrom(
        backgroundColor: color.withValues(alpha: 0.08),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        minimumSize: const Size(34, 34),
      ),
      onPressed: onPressed,
    );
  }
}

