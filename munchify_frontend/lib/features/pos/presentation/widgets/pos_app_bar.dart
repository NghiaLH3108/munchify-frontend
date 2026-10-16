import 'package:flutter/material.dart';
import '../../../../core/theme/ColorPalette.dart';
import '../../../inventory/presentation/screens/staff_damage_report_screen.dart';

/// AppBar của màn hình POS Home: logo, trạng thái quầy và chọn ca.
class PosAppBar extends StatelessWidget implements PreferredSizeWidget {
  const PosAppBar({Key? key}) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: ColorPalette.surface,
      elevation: 0,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: ColorPalette.appetizingOrange,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.restaurant, color: ColorPalette.onPrimary),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Munchify POS',
                style: TextStyle(
                  color: ColorPalette.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: ColorPalette.success,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'Trực tuyến • Quầy thu ngân #01',
                    style: TextStyle(color: ColorPalette.textHint, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      actions: [
        // Nút truy cập giao diện App Staff Báo cáo hàng hỏng / hư / hết hạn
        IconButton(
          tooltip: 'Báo cáo hàng hỏng / hết hạn',
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3E0),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFFFCC80)),
            ),
            child: const Icon(
              Icons.report_problem_outlined,
              color: ColorPalette.appetizingOrange,
              size: 20,
            ),
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const StaffDamageReportScreen(),
              ),
            );
          },
        ),
        Container(
          margin: const EdgeInsets.only(left: 4, right: 16, top: 10, bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Row(
            children: [
              Text('MT', style: TextStyle(color: ColorPalette.textPrimary, fontWeight: FontWeight.bold)),
              Icon(Icons.arrow_drop_down, color: ColorPalette.textPrimary),
            ],
          ),
        ),
      ],
    );
  }
}
