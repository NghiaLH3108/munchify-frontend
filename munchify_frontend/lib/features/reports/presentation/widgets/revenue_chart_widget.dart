import 'package:flutter/material.dart';
import '../../../../core/theme/AppTypography.dart';
import '../../../../core/theme/ColorPalette.dart';
import '../../domain/entities/revenue_summary_entity.dart';

/// Bar chart of revenue per bucket (hour / day / month) drawn with CustomPainter.
class RevenueChartWidget extends StatelessWidget {
  final List<RevenueDataPointEntity> points;

  const RevenueChartWidget({super.key, required this.points});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ColorPalette.surfaceWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ColorPalette.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Biểu đồ doanh thu',
            style: AppTypography.plusJakarta(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: ColorPalette.onSurfaceDark,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 240,
            width: double.infinity,
            child: points.isEmpty
                ? Center(
                    child: Text(
                      'Chưa có dữ liệu',
                      style: AppTypography.inter(
                        fontSize: 13,
                        color: ColorPalette.textMuted,
                      ),
                    ),
                  )
                : CustomPaint(painter: _BarChartPainter(points)),
          ),
        ],
      ),
    );
  }
}

class _BarChartPainter extends CustomPainter {
  final List<RevenueDataPointEntity> points;

  _BarChartPainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    const bottomPad = 22.0;
    final chartH = size.height - bottomPad;
    final maxV = points.map((p) => p.revenue).fold<double>(0, (a, b) => a > b ? a : b);
    final scale = maxV <= 0 ? 0.0 : chartH / maxV;

    final gridPaint = Paint()
      ..color = ColorPalette.borderSubtle
      ..strokeWidth = 1;
    for (var i = 0; i <= 4; i++) {
      final y = chartH * i / 4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final slot = size.width / points.length;
    final barW = slot * 0.6;
    final barPaint = Paint()..color = ColorPalette.primaryContainer;
    final labelEvery = (points.length / 12).ceil().clamp(1, 1000);

    for (var i = 0; i < points.length; i++) {
      final h = points[i].revenue * scale;
      final x = i * slot + (slot - barW) / 2;
      canvas.drawRRect(
        RRect.fromRectAndCorners(
          Rect.fromLTWH(x, chartH - h, barW, h),
          topLeft: const Radius.circular(4),
          topRight: const Radius.circular(4),
        ),
        barPaint,
      );

      if (i % labelEvery == 0) {
        final tp = TextPainter(
          text: TextSpan(
            text: points[i].label,
            style: const TextStyle(fontSize: 10, color: Color(0xFF8A8A8A)),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(canvas, Offset(i * slot + (slot - tp.width) / 2, chartH + 6));
      }
    }
  }

  @override
  bool shouldRepaint(covariant _BarChartPainter old) => old.points != points;
}
