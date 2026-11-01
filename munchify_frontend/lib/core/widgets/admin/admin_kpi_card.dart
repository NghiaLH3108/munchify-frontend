import 'package:flutter/material.dart';
import '../../theme/ColorPalette.dart';
import '../../theme/AppTypography.dart';

/// Reusable KPI Summary Card for Admin Screens.
///
/// Matches the Munchify POS Admin design:
/// - Top gradient accent line
/// - Metric title and bold value
/// - Subtitle with optional trend indicator (up/down arrow)
/// - Themed icon box with soft colored background
class AdminKpiCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final double? width;
  final Color? valueColor;
  final Color? subTextColor;
  final bool showTrendIcon;
  final bool trendPositive;
  final bool isWarning;

  const AdminKpiCard({
    super.key,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    this.iconColor = ColorPalette.appetizingOrange,
    this.iconBg = const Color(0xFFFFF7ED),
    this.width,
    this.valueColor,
    this.subTextColor,
    this.showTrendIcon = false,
    this.trendPositive = true,
    this.isWarning = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFFFEDD5).withValues(alpha: 0.8),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: iconColor.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Stack(
          children: [
            // Top Accent Line
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 4,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      iconColor.withValues(alpha: 0.85),
                      iconColor.withValues(alpha: 0.2),
                    ],
                  ),
                ),
              ),
            ),
            // Card Content
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: AppTypography.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF64748B),
                            letterSpacing: 0.6,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          value,
                          style: AppTypography.plusJakarta(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: valueColor ??
                                (isWarning
                                    ? ColorPalette.error
                                    : const Color(0xFF0F172A)),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (showTrendIcon) ...[
                              Icon(
                                trendPositive
                                    ? Icons.trending_up_rounded
                                    : Icons.trending_down_rounded,
                                size: 14,
                                color: subTextColor ??
                                    (trendPositive
                                        ? ColorPalette.success
                                        : ColorPalette.error),
                              ),
                              const SizedBox(width: 4),
                            ],
                            Flexible(
                              child: Text(
                                subtitle,
                                style: AppTypography.inter(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: subTextColor ?? const Color(0xFF64748B),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: iconBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: iconColor.withValues(alpha: 0.15),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: iconColor.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Icon(icon, color: iconColor, size: 22),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
