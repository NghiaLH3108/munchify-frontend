import 'package:flutter/material.dart';

import '../../theme/AppTypography.dart';
import '../../theme/ColorPalette.dart';

/// Trạng thái đang tải toàn trang.
class AdminLoadingView extends StatelessWidget {
  final String message;
  const AdminLoadingView({super.key, this.message = 'Đang tải dữ liệu...'});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: ColorPalette.appetizingOrange,
            ),
          ),
          const SizedBox(height: 16),
          Text(message, style: AppTypography.dashboardSubtitle),
        ],
      ),
    );
  }
}

/// Trạng thái lỗi kèm nút "Thử Lại".
class AdminErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  final String title;

  const AdminErrorView({
    super.key,
    required this.message,
    required this.onRetry,
    this.title = 'Không thể tải dữ liệu',
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: ColorPalette.error.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.cloud_off_rounded,
                color: ColorPalette.error,
                size: 44,
              ),
            ),
            const SizedBox(height: 16),
            Text(title, style: AppTypography.dashboardHeadline),
            const SizedBox(height: 8),
            Text(
              message,
              style: AppTypography.dashboardSubtitle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Thử Lại'),
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorPalette.appetizingOrange,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Trạng thái danh sách rỗng (dùng bên trong table card).
class AdminEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? action;

  const AdminEmptyState({
    super.key,
    this.icon = Icons.inbox_outlined,
    this.title = 'Không có dữ liệu phù hợp',
    this.subtitle,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      child: Center(
        child: Column(
          children: [
            Icon(
              icon,
              size: 60,
              color: ColorPalette.textMuted.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(color: ColorPalette.textMuted, fontSize: 16),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 6),
              Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: ColorPalette.textMuted,
                  fontSize: 12,
                ),
              ),
            ],
            if (action != null) ...[
              const SizedBox(height: 20),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}
