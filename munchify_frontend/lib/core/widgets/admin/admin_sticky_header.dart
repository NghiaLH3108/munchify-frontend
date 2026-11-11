import 'package:flutter/material.dart';

import '../../theme/AppTypography.dart';
import '../../theme/ColorPalette.dart';

/// Thanh trên cùng (64px) khi màn Admin chạy độc lập (không nằm trong shell):
/// logo Munchify, breadcrumb, ô tìm nhanh (tuỳ chọn), Online, nút tải lại, avatar.
class AdminStickyHeader extends StatelessWidget {
  final String breadcrumb;
  final VoidCallback? onRefresh;
  final ValueChanged<String>? onQuickSearch;
  final String userInitials;
  final String userName;
  final String userRole;

  const AdminStickyHeader({
    super.key,
    required this.breadcrumb,
    this.onRefresh,
    this.onQuickSearch,
    this.userInitials = 'AD',
    this.userName = 'Admin',
    this.userRole = 'Quản trị',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      decoration: const BoxDecoration(
        color: ColorPalette.surface,
        border: Border(bottom: BorderSide(color: ColorPalette.borderSubtle)),
        boxShadow: [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 950;
          final isVeryNarrow = constraints.maxWidth < 650;

          return Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: ColorPalette.appetizingOrange.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.lunch_dining_rounded,
                  color: ColorPalette.appetizingOrange,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Munchify POS',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: ColorPalette.warmDarkGrey,
                ),
              ),
              if (!isNarrow) ...[
                const SizedBox(width: 10),
                const Icon(
                  Icons.chevron_right_rounded,
                  size: 18,
                  color: ColorPalette.textMuted,
                ),
                const SizedBox(width: 4),
                Text(
                  'Trang chủ',
                  style: AppTypography.labelSmall.copyWith(
                    color: ColorPalette.textMuted,
                    decoration: TextDecoration.none,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6),
                  child: Text(
                    '/',
                    style: TextStyle(color: ColorPalette.textMuted, fontSize: 12),
                  ),
                ),
                Text(
                  breadcrumb,
                  style: AppTypography.labelSmall.copyWith(
                    color: ColorPalette.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
              const Spacer(),
              Flexible(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  reverse: true,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!isNarrow && onQuickSearch != null) ...[
                        SizedBox(
                          width: 240,
                          height: 38,
                          child: _QuickSearchField(onChanged: onQuickSearch!),
                        ),
                        const SizedBox(width: 12),
                      ],
                      if (!isVeryNarrow) ...[
                        const _OnlineBadge(),
                        const SizedBox(width: 10),
                      ],
                      if (onRefresh != null) ...[
                        IconButton(
                          onPressed: onRefresh,
                          icon: const Icon(
                            Icons.refresh_rounded,
                            size: 20,
                            color: ColorPalette.textMuted,
                          ),
                          tooltip: 'Tải lại danh sách',
                          style: IconButton.styleFrom(
                            backgroundColor: ColorPalette.webBgAdmin,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      _UserChip(
                        initials: userInitials,
                        name: userName,
                        role: userRole,
                        compact: isVeryNarrow,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _QuickSearchField extends StatelessWidget {
  final ValueChanged<String> onChanged;
  const _QuickSearchField({required this.onChanged});

  @override
  Widget build(BuildContext context) {
    OutlineInputBorder border(Color c, [double w = 1]) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: c, width: w),
        );
    return TextField(
      onChanged: (v) => onChanged(v.trim()),
      style: const TextStyle(fontSize: 13),
      decoration: InputDecoration(
        hintText: 'Tìm nhanh... (Ctrl+K)',
        hintStyle: const TextStyle(fontSize: 12, color: ColorPalette.textMuted),
        prefixIcon: const Icon(
          Icons.search_rounded,
          size: 18,
          color: ColorPalette.textMuted,
        ),
        filled: true,
        fillColor: ColorPalette.webBgAdmin.withValues(alpha: 0.7),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        border: border(ColorPalette.borderSubtle),
        enabledBorder: border(ColorPalette.borderSubtle),
        focusedBorder: border(ColorPalette.appetizingOrange, 1.5),
      ),
    );
  }
}

class _OnlineBadge extends StatelessWidget {
  const _OnlineBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: ColorPalette.success.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: const BoxDecoration(
              color: ColorPalette.success,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          const Text(
            'Online',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: ColorPalette.success,
            ),
          ),
        ],
      ),
    );
  }
}

class _UserChip extends StatelessWidget {
  final String initials;
  final String name;
  final String role;
  final bool compact;

  const _UserChip({
    required this.initials,
    required this.name,
    required this.role,
    required this.compact,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        border: Border.all(color: ColorPalette.borderSubtle),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: ColorPalette.surfaceContainerHigh,
            child: Text(
              initials,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: ColorPalette.appetizingOrange,
              ),
            ),
          ),
          if (!compact) ...[
            const SizedBox(width: 8),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: ColorPalette.textPrimary,
                  ),
                ),
                Text(
                  role,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: ColorPalette.appetizingOrange,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 6),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 16,
              color: ColorPalette.textMuted,
            ),
          ],
        ],
      ),
    );
  }
}

