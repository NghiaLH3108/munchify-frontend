import 'package:flutter/material.dart';
import '../../theme/ColorPalette.dart';
import '../../theme/AppTypography.dart';

/// Reusable Admin Page Header Widget.
///
/// Follows the Munchify POS Admin Console design system:
/// - Leading brand/feature icon with soft warm background
/// - Bold title with descriptive subtitle
/// - Optional extra actions (Sync time, Export, Refresh)
/// - Primary "+ Add" action button
class AdminPageHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? addButtonText;
  final IconData? addButtonIcon;
  final VoidCallback? onAddPressed;
  final List<Widget>? extraActions;

  const AdminPageHeader({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.addButtonText,
    this.addButtonIcon = Icons.add_circle_outline_rounded,
    this.onAddPressed,
    this.extraActions,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFFFEDD5), width: 1.2),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 650;

          final titleSection = Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF7ED),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: const Color(0xFFFFEDD5),
                    width: 1,
                  ),
                ),
                child: Icon(
                  icon,
                  color: ColorPalette.appetizingOrange,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: AppTypography.plusJakarta(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0F172A),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: AppTypography.inter(
                        fontSize: 11,
                        color: const Color(0xFF64748B),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          );

          final actionsSection = Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ...?extraActions,
              if (addButtonText != null && onAddPressed != null) ...[
                if (extraActions != null && extraActions!.isNotEmpty)
                  const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: onAddPressed,
                  icon: Icon(addButtonIcon, size: 18),
                  label: Text(addButtonText!),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorPalette.appetizingOrange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    elevation: 2,
                    shadowColor: ColorPalette.appetizingOrange.withValues(alpha: 0.35),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    textStyle: AppTypography.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ],
          );

          if (isNarrow) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                titleSection,
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: actionsSection,
                ),
              ],
            );
          }

          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(child: titleSection),
              const SizedBox(width: 16),
              actionsSection,
            ],
          );
        },
      ),
    );
  }
}
