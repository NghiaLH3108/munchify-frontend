import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/theme/ColorPalette.dart';
import '../../../../core/theme/AppTypography.dart';

/// Executive Analytics Dashboard View based on Munchify POS HTML mockup.
class AnalyticsDashboardView extends StatefulWidget {
  const AnalyticsDashboardView({super.key});

  @override
  State<AnalyticsDashboardView> createState() => _AnalyticsDashboardViewState();
}

class _AnalyticsDashboardViewState extends State<AnalyticsDashboardView> {
  String _selectedChartPeriod = 'hour'; // 'hour', 'week', 'month'
  String _selectedTableCategory = 'all'; // 'all', 'single', 'combo', 'drink'

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPageTitleBar(),
          const SizedBox(height: 20),
          _buildMetricCards(),
          const SizedBox(height: 24),
          _buildAnalyticsGrid(context),
          const SizedBox(height: 24),
          _buildTopProductsTableCard(),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // PAGE TITLE & OPERATIONAL STATUS BAR
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildPageTitleBar() {
    return Wrap(
      spacing: 16,
      runSpacing: 12,
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tổng quan điều hành F&B',
              style: AppTypography.plusJakarta(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: ColorPalette.onSurfaceDark,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Cập nhật dữ liệu thời gian thực từ 2 điểm bán tại quầy và các cổng giao đồ ăn trực tuyến.',
              style: AppTypography.inter(
                fontSize: 13,
                color: ColorPalette.textMuted,
              ),
            ),
          ],
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Icon(Icons.sync_rounded, size: 16, color: ColorPalette.tertiary),
                const SizedBox(width: 6),
                Text(
                  'Đồng bộ lúc 14:28:10 (3s trước)',
                  style: AppTypography.inter(
                    fontSize: 12,
                    color: ColorPalette.textMuted,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 14),
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.tune_rounded, size: 16),
              label: const Text('Tuỳ biến Widget'),
              style: OutlinedButton.styleFrom(
                foregroundColor: ColorPalette.onSurfaceDark,
                backgroundColor: ColorPalette.surfaceWhite,
                side: const BorderSide(color: ColorPalette.borderSubtle),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                textStyle: AppTypography.inter(fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 3. 4 HIGH-DENSITY KPI CARDS (Row 1)
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildMetricCards() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount =
            constraints.maxWidth > 1050 ? 4 : (constraints.maxWidth > 550 ? 2 : 1);
        final gap = 16.0;
        final cardWidth =
            (constraints.maxWidth - ((crossAxisCount - 1) * gap)) / crossAxisCount;

        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            // Card 1: Doanh thu hôm nay
            _buildKpiCard(
              width: cardWidth,
              title: 'DOANH THU HÔM NAY',
              value: '8.450.000 ₫',
              icon: Icons.payments_outlined,
              iconColor: ColorPalette.primaryContainer,
              iconBg: ColorPalette.primaryFixed.withValues(alpha: 0.6),
              bottomContent: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: ColorPalette.tertiary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.trending_up_rounded,
                                size: 14, color: ColorPalette.tertiary),
                            const SizedBox(width: 4),
                            Text(
                              '+12.5%',
                              style: AppTypography.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: ColorPalette.tertiary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '+940.000 ₫',
                        style: AppTypography.inter(
                          fontSize: 11,
                          color: ColorPalette.textMuted,
                        ),
                      ),
                    ],
                  ),
                  CustomPaint(
                    size: const Size(60, 20),
                    painter: _SparklinePainter(color: ColorPalette.tertiary),
                  ),
                ],
              ),
            ),
            // Card 2: Tổng đơn hàng
            _buildKpiCard(
              width: cardWidth,
              title: 'TỔNG ĐƠN HÀNG',
              value: '112',
              valueUnit: ' đơn',
              icon: Icons.receipt_long_outlined,
              iconColor: ColorPalette.secondary,
              iconBg: ColorPalette.surfaceContainerHigh,
              bottomContent: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  RichText(
                    text: TextSpan(
                      text: 'Giá trị TB: ',
                      style: AppTypography.inter(fontSize: 12, color: ColorPalette.textMuted),
                      children: [
                        TextSpan(
                          text: '75.400 ₫',
                          style: AppTypography.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: ColorPalette.onSurfaceDark,
                          ),
                        ),
                        const TextSpan(text: '/đơn'),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      const Icon(Icons.north_east_rounded,
                          size: 13, color: ColorPalette.tertiary),
                      const SizedBox(width: 2),
                      Text(
                        '+8 đơn',
                        style: AppTypography.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: ColorPalette.tertiary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Card 3: Cảnh báo tồn kho
            _buildKpiCard(
              width: cardWidth,
              title: 'CẢNH BÁO TỒN KHO',
              titleBadge: 'Cần nhập',
              value: '4',
              valueUnit: ' sản phẩm',
              valueColor: ColorPalette.dangerCrimson,
              icon: Icons.warning_amber_rounded,
              iconColor: ColorPalette.warningTangerine,
              iconBg: const Color(0xFFFFFBEB),
              borderLeft: const BorderSide(color: ColorPalette.warningTangerine, width: 4),
              bottomContent: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Sắp chạm ngưỡng tối thiểu',
                    style: AppTypography.inter(fontSize: 12, color: ColorPalette.textMuted),
                  ),
                  Row(
                    children: [
                      Text(
                        'Xem chi tiết kho',
                        style: AppTypography.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: ColorPalette.primaryContainer,
                        ),
                      ),
                      const SizedBox(width: 2),
                      const Icon(Icons.arrow_forward_rounded,
                          size: 13, color: ColorPalette.primaryContainer),
                    ],
                  ),
                ],
              ),
            ),
            // Card 4: Khách hàng thân thiết
            _buildKpiCard(
              width: cardWidth,
              title: 'KHÁCH HÀNG THÂN THIẾT',
              value: '348',
              valueUnit: ' thành viên',
              icon: Icons.group_add_outlined,
              iconColor: const Color(0xFF7E22CE),
              iconBg: const Color(0xFFFAF5FF),
              bottomContent: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  RichText(
                    text: TextSpan(
                      text: '+18 mới ',
                      style: AppTypography.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: ColorPalette.tertiary,
                      ),
                      children: [
                        TextSpan(
                          text: 'hôm nay',
                          style: AppTypography.inter(fontSize: 12, color: ColorPalette.textMuted),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: ColorPalette.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '62% tích điểm',
                      style: AppTypography.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: ColorPalette.onSurfaceDark,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildKpiCard({
    required double width,
    required String title,
    String? titleBadge,
    required String value,
    String? valueUnit,
    Color? valueColor,
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    BorderSide? borderLeft,
    required Widget bottomContent,
  }) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        color: ColorPalette.surfaceWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ColorPalette.borderSubtle),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          if (borderLeft != null)
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: Container(
                width: 4,
                color: borderLeft.color,
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          title,
                          style: AppTypography.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: ColorPalette.textMuted,
                            letterSpacing: 0.5,
                          ),
                        ),
                        if (titleBadge != null) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                            decoration: BoxDecoration(
                              color: ColorPalette.warningTangerine.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              titleBadge,
                              style: AppTypography.inter(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: ColorPalette.warningTangerine,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 6),
                    RichText(
                      text: TextSpan(
                        text: value,
                        style: AppTypography.plusJakarta(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: valueColor ?? ColorPalette.onSurfaceDark,
                        ),
                        children: [
                          if (valueUnit != null)
                            TextSpan(
                              text: valueUnit,
                              style: AppTypography.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: ColorPalette.textMuted,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.only(top: 12),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: ColorPalette.borderSubtle)),
            ),
            child: bottomContent,
          ),
        ],
      ),
    ),
  ],
),
);
}

  // ═══════════════════════════════════════════════════════════════════════════
  // 4. MAIN CONTENT ANALYTICS GRID (Bar Chart Left / Donut Chart Right)
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildAnalyticsGrid(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 1000;
        if (isDesktop) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 7, child: _buildRevenueTrendCard()),
              const SizedBox(width: 24),
              Expanded(flex: 5, child: _buildPaymentMethodsCard()),
            ],
          );
        } else {
          return Column(
            children: [
              _buildRevenueTrendCard(),
              const SizedBox(height: 24),
              _buildPaymentMethodsCard(),
            ],
          );
        }
      },
    );
  }

  Widget _buildRevenueTrendCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ColorPalette.surfaceWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ColorPalette.borderSubtle),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header & Filters
          Wrap(
            spacing: 12,
            runSpacing: 10,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Xu hướng doanh thu theo giờ & tuần',
                    style: AppTypography.plusJakarta(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: ColorPalette.onSurfaceDark,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Phân tích nhịp độ bán hàng nhằm tối ưu nhân sự ca trực và nguyên liệu chuẩn bị.',
                    style: AppTypography.inter(fontSize: 12, color: ColorPalette.textMuted),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: ColorPalette.webBgAdmin,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: ColorPalette.borderSubtle),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildChartPeriodTab('hour', 'Theo giờ'),
                    _buildChartPeriodTab('week', '7 ngày'),
                    _buildChartPeriodTab('month', 'Theo tháng'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Peak Highlight Card
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: ColorPalette.primaryFixed.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: ColorPalette.primaryContainer.withValues(alpha: 0.2)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: ColorPalette.primaryContainer,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(Icons.local_fire_department_rounded,
                          size: 16, color: Colors.white),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Giờ cao điểm ghi nhận: 18:00 - 19:30',
                          style: AppTypography.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: ColorPalette.primaryContainer,
                          ),
                        ),
                        RichText(
                          text: TextSpan(
                            text: 'Đạt doanh số kỷ lục: ',
                            style: AppTypography.inter(fontSize: 11, color: ColorPalette.textMuted),
                            children: [
                              TextSpan(
                                text: '2.350.000 ₫',
                                style: AppTypography.inter(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: ColorPalette.onSurfaceDark,
                                ),
                              ),
                              const TextSpan(text: ' (34 đơn hoàn thành)'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: ColorPalette.surfaceWhite,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: ColorPalette.primaryContainer.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    'Rất bận rộn',
                    style: AppTypography.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: ColorPalette.primaryContainer,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          // Bar Chart Simulation
          SizedBox(
            height: 220,
            child: _buildHourlyBarChart(),
          ),
          const SizedBox(height: 14),
          // Chart Legend & Footer
          Container(
            padding: const EdgeInsets.only(top: 12),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: ColorPalette.borderSubtle)),
            ),
            child: Wrap(
              spacing: 16,
              runSpacing: 8,
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: ColorPalette.primaryContainer,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Tại quầy (POS Counter) - 58%',
                          style: AppTypography.inter(fontSize: 11, color: ColorPalette.onSurfaceDark),
                        ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: ColorPalette.primaryLight,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Giao hàng / Mang đi - 42%',
                          style: AppTypography.inter(fontSize: 11, color: ColorPalette.onSurfaceDark),
                        ),
                      ],
                    ),
                  ],
                ),
                RichText(
                  text: TextSpan(
                    text: 'Khung giờ đông nhất: ',
                    style: AppTypography.inter(fontSize: 11, color: ColorPalette.textMuted),
                    children: [
                      TextSpan(
                        text: '17:30 - 20:30',
                        style: AppTypography.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: ColorPalette.onSurfaceDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartPeriodTab(String key, String label) {
    final isSelected = _selectedChartPeriod == key;
    return InkWell(
      onTap: () => setState(() => _selectedChartPeriod = key),
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? ColorPalette.surfaceWhite : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: AppTypography.inter(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? ColorPalette.onSurfaceDark : ColorPalette.textMuted,
          ),
        ),
      ),
    );
  }

  Widget _buildHourlyBarChart() {
    final columns = [
      {'time': '08:00', 'h1': 0.15, 'h2': 0.25, 'isPeak': false},
      {'time': '11:00', 'h1': 0.30, 'h2': 0.58, 'isPeak': false},
      {'time': '13:00', 'h1': 0.50, 'h2': 0.72, 'isPeak': false},
      {'time': '15:00', 'h1': 0.12, 'h2': 0.28, 'isPeak': false},
      {'time': '17:00', 'h1': 0.35, 'h2': 0.52, 'isPeak': false},
      {'time': '19:00', 'h1': 0.70, 'h2': 0.95, 'isPeak': true},
      {'time': '21:00', 'h1': 0.22, 'h2': 0.42, 'isPeak': false},
    ];

    return Stack(
      children: [
        // Y-axis grid lines
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildGridLine('3.000.000 ₫'),
            _buildGridLine('2.000.000 ₫'),
            _buildGridLine('1.000.000 ₫'),
            _buildGridLine('0 ₫'),
          ],
        ),
        // Bar columns
        Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 24, left: 70, right: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: columns.map((col) {
              final isPeak = col['isPeak'] as bool;
              return Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (isPeak)
                    Container(
                      margin: const EdgeInsets.only(bottom: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: ColorPalette.inverseSurface,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '2.35M ₫',
                        style: AppTypography.inter(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        width: 10,
                        height: 140 * (col['h1'] as double),
                        decoration: const BoxDecoration(
                          color: ColorPalette.primaryLight,
                          borderRadius: BorderRadius.vertical(top: Radius.circular(3)),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Container(
                        width: 10,
                        height: 140 * (col['h2'] as double),
                        decoration: const BoxDecoration(
                          color: ColorPalette.primaryContainer,
                          borderRadius: BorderRadius.vertical(top: Radius.circular(3)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    col['time'] as String,
                    style: AppTypography.inter(
                      fontSize: 10,
                      fontWeight: isPeak ? FontWeight.w700 : FontWeight.w500,
                      color: isPeak ? ColorPalette.primaryContainer : ColorPalette.textMuted,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildGridLine(String label) {
    return Row(
      children: [
        SizedBox(
          width: 65,
          child: Text(
            label,
            style: AppTypography.inter(fontSize: 10, color: ColorPalette.textMuted),
          ),
        ),
        const Expanded(
          child: Divider(height: 1, color: ColorPalette.borderSubtle),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // DONUT CHART: PAYMENT METHODS
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildPaymentMethodsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ColorPalette.surfaceWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ColorPalette.borderSubtle),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Cơ cấu phương thức thanh toán',
                style: AppTypography.plusJakarta(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: ColorPalette.onSurfaceDark,
                ),
              ),
              const Icon(Icons.info_outline_rounded, size: 18, color: ColorPalette.textMuted),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Tổng số 112 đơn đã giao dịch thành công trong ca.',
            style: AppTypography.inter(fontSize: 12, color: ColorPalette.textMuted),
          ),
          const SizedBox(height: 16),
          // Donut Chart Graphic
          Center(
            child: SizedBox(
              width: 150,
              height: 150,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CustomPaint(
                    size: const Size(150, 150),
                    painter: _PaymentDonutPainter(),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '112',
                        style: AppTypography.plusJakarta(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: ColorPalette.onSurfaceDark,
                        ),
                      ),
                      Text(
                        'TỔNG ĐƠN',
                        style: AppTypography.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: ColorPalette.textMuted,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Method List
          _buildPaymentMethodRow(
            icon: Icons.qr_code_scanner_rounded,
            iconColor: ColorPalette.primaryContainer,
            iconBg: ColorPalette.primaryContainer.withValues(alpha: 0.1),
            title: 'VietQR / MoMo',
            subtitle: '69 đơn hoàn tất',
            amount: '5.239.000 ₫',
            percent: '62%',
            percentColor: ColorPalette.primaryContainer,
          ),
          const SizedBox(height: 10),
          _buildPaymentMethodRow(
            icon: Icons.attach_money_rounded,
            iconColor: ColorPalette.secondary,
            iconBg: ColorPalette.secondaryContainer.withValues(alpha: 0.2),
            title: 'Tiền mặt (Cash)',
            subtitle: '32 đơn hoàn tất',
            amount: '2.366.000 ₫',
            percent: '28%',
            percentColor: ColorPalette.secondaryContainer,
          ),
          const SizedBox(height: 10),
          _buildPaymentMethodRow(
            icon: Icons.account_balance_rounded,
            iconColor: ColorPalette.tertiary,
            iconBg: ColorPalette.tertiary.withValues(alpha: 0.12),
            title: 'Chuyển khoản',
            subtitle: '11 đơn đối soát',
            amount: '845.000 ₫',
            percent: '10%',
            percentColor: ColorPalette.tertiaryContainer,
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodRow({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
    required String subtitle,
    required String amount,
    required String percent,
    required Color percentColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: ColorPalette.webBgAdmin.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: ColorPalette.borderSubtle.withValues(alpha: 0.7)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 18),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: ColorPalette.onSurfaceDark,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: AppTypography.inter(fontSize: 11, color: ColorPalette.textMuted),
                  ),
                ],
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amount,
                style: AppTypography.plusJakarta(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: ColorPalette.onSurfaceDark,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: percentColor,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  percent,
                  style: AppTypography.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 5. BOTTOM SECTION: TOP 5 PRODUCTS TABLE
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildTopProductsTableCard() {
    final products = [
      {
        'rank': '1',
        'name': 'Combo Ăn Vặt No Say (Bánh tráng + Trà sữa)',
        'sub': 'Tiết kiệm 15%',
        'code': 'CB01',
        'cat': 'Combo Tiết Kiệm',
        'price': '45.000 ₫',
        'sold': '42 phần',
        'rev': '1.890.000 ₫',
        'share': '22.4%',
        'stock': 'Còn 35 suất',
        'stockSafe': true,
        'icon': Icons.lunch_dining_rounded,
        'iconColor': ColorPalette.primaryContainer,
        'iconBg': const Color(0xFFFFEDD5),
      },
      {
        'rank': '2',
        'name': 'Bánh tráng trộn Sài Gòn đặc biệt',
        'sub': 'Trứng cút, bò khô, xoài chua',
        'code': 'P001',
        'cat': 'Bánh tráng & Snacks',
        'price': '25.000 ₫',
        'sold': '58 bịch',
        'rev': '1.450.000 ₫',
        'share': '17.2%',
        'stock': 'Còn 188 bịch',
        'stockSafe': true,
        'icon': Icons.tapas_rounded,
        'iconColor': ColorPalette.primaryLight,
        'iconBg': const Color(0xFFFFF7ED),
      },
      {
        'rank': '3',
        'name': 'Khô gà lá chanh thượng hạng',
        'sub': 'Hũ pet 250g hút ẩm',
        'code': 'P004',
        'cat': 'Thịt khô',
        'price': '45.000 ₫',
        'sold': '26 hũ',
        'rev': '1.170.000 ₫',
        'share': '13.8%',
        'stock': 'Còn 42 hũ',
        'stockSafe': true,
        'icon': Icons.takeout_dining_rounded,
        'iconColor': ColorPalette.secondary,
        'iconBg': const Color(0xFFFEF3C7),
      },
      {
        'rank': '4',
        'name': 'Trà sữa trân châu hoàng kim (M)',
        'sub': 'Đường 70%, Đá 50% phổ biến',
        'code': 'D002',
        'cat': 'Trà sữa & Giải khát',
        'price': '30.000 ₫',
        'sold': '35 ly',
        'rev': '1.050.000 ₫',
        'share': '12.4%',
        'stock': 'Còn 60 ly',
        'stockSafe': true,
        'icon': Icons.local_cafe_rounded,
        'iconColor': const Color(0xFFB45309),
        'iconBg': const Color(0xFFFEFCE8),
      },
      {
        'rank': '5',
        'name': 'Bánh tráng phơi sương muối nhuyễn',
        'sub': 'Kèm sốt bơ tỏi hành phi',
        'code': 'P002',
        'cat': 'Bánh tráng & Snacks',
        'price': '22.000 ₫',
        'sold': '38 bịch',
        'rev': '836.000 ₫',
        'share': '9.9%',
        'stock': 'Sắp hết: 4 bịch',
        'stockSafe': false,
        'icon': Icons.bakery_dining_rounded,
        'iconColor': ColorPalette.dangerCrimson,
        'iconBg': const Color(0xFFFEE2E2),
      },
    ];

    return Container(
      decoration: BoxDecoration(
        color: ColorPalette.surfaceWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ColorPalette.borderSubtle),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header & Filter Pills
          Padding(
            padding: const EdgeInsets.all(20),
            child: Wrap(
              spacing: 16,
              runSpacing: 12,
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Top 5 Sản phẩm & Combo bán chạy nhất hôm nay',
                          style: AppTypography.plusJakarta(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: ColorPalette.onSurfaceDark,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: ColorPalette.primaryFixed,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Trọng tâm',
                            style: AppTypography.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: ColorPalette.primaryContainer,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Xếp hạng theo tổng doanh thu thực tế ghi nhận qua hệ thống máy POS.',
                      style: AppTypography.inter(fontSize: 12, color: ColorPalette.textMuted),
                    ),
                  ],
                ),
                // Filter Pills
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildTableCategoryPill('all', 'Tất cả'),
                    const SizedBox(width: 8),
                    _buildTableCategoryPill('single', 'Món lẻ'),
                    const SizedBox(width: 8),
                    _buildTableCategoryPill('combo', 'Combo ăn vặt'),
                    const SizedBox(width: 8),
                    _buildTableCategoryPill('drink', 'Nước uống'),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: ColorPalette.borderSubtle),
          // Table Content
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 960),
              child: DataTable(
                headingRowHeight: 44,
                dataRowMinHeight: 64,
                dataRowMaxHeight: 70,
                horizontalMargin: 20,
                columnSpacing: 24,
                headingRowColor: WidgetStateProperty.all(
                  ColorPalette.webBgAdmin.withValues(alpha: 0.8),
                ),
                dividerThickness: 0.5,
                columns: const [
                  DataColumn(
                    label: Text('#', style: AppTypography.tableHeader),
                  ),
                  DataColumn(
                    label: Text('SẢN PHẨM', style: AppTypography.tableHeader),
                  ),
                  DataColumn(
                    label: Text('MÃ SP', style: AppTypography.tableHeader),
                  ),
                  DataColumn(
                    label: Text('DANH MỤC', style: AppTypography.tableHeader),
                  ),
                  DataColumn(
                    label: Text('GIÁ BÁN', style: AppTypography.tableHeader),
                    numeric: true,
                  ),
                  DataColumn(
                    label: Text('ĐÃ BÁN', style: AppTypography.tableHeader),
                    numeric: true,
                  ),
                  DataColumn(
                    label: Text('DOANH THU', style: AppTypography.tableHeader),
                    numeric: true,
                  ),
                  DataColumn(
                    label: Text('TỶ TRỌNG', style: AppTypography.tableHeader),
                  ),
                  DataColumn(
                    label: Text('TỒN KHO', style: AppTypography.tableHeader),
                  ),
                ],
                rows: products.map((item) {
                  final rank = item['rank'] as String;
                  final isTop1 = rank == '1';
                  final isTop2 = rank == '2';
                  final isTop3 = rank == '3';
                  final isStockSafe = item['stockSafe'] as bool;

                  Color rankBg = const Color(0xFFF1F5F9);
                  Color rankColor = const Color(0xFF64748B);
                  if (isTop1) {
                    rankBg = const Color(0xFFFBBF24);
                    rankColor = const Color(0xFF0F172A);
                  } else if (isTop2) {
                    rankBg = const Color(0xFFE2E8F0);
                    rankColor = const Color(0xFF334155);
                  } else if (isTop3) {
                    rankBg = const Color(0xFFF1F5F9);
                    rankColor = const Color(0xFF475569);
                  }

                  return DataRow(
                    cells: [
                      // Rank
                      DataCell(
                        Center(
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: rankBg,
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              rank,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: rankColor,
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Product Name + Icon
                      DataCell(
                        Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: item['iconBg'] as Color,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                item['icon'] as IconData,
                                color: item['iconColor'] as Color,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item['name'] as String,
                                  style: AppTypography.inter(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: ColorPalette.onSurfaceDark,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  item['sub'] as String,
                                  style: AppTypography.inter(
                                    fontSize: 11,
                                    color: ColorPalette.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Code
                      DataCell(
                        Text(
                          item['code'] as String,
                          style: AppTypography.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: ColorPalette.textMuted,
                          ),
                        ),
                      ),
                      // Category
                      DataCell(
                        Text(
                          item['cat'] as String,
                          style: AppTypography.inter(
                            fontSize: 12,
                            color: ColorPalette.textMuted,
                          ),
                        ),
                      ),
                      // Price
                      DataCell(
                        Text(
                          item['price'] as String,
                          style: AppTypography.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: ColorPalette.onSurfaceDark,
                          ),
                        ),
                      ),
                      // Sold
                      DataCell(
                        Text(
                          item['sold'] as String,
                          style: AppTypography.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: ColorPalette.onSurfaceDark,
                          ),
                        ),
                      ),
                      // Revenue
                      DataCell(
                        Text(
                          item['rev'] as String,
                          style: AppTypography.plusJakarta(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: ColorPalette.primaryContainer,
                          ),
                        ),
                      ),
                      // Share
                      DataCell(
                        Row(
                          children: [
                            Container(
                              width: 48,
                              height: 6,
                              decoration: BoxDecoration(
                                color: ColorPalette.borderSubtle,
                                borderRadius: BorderRadius.circular(3),
                              ),
                              child: FractionallySizedBox(
                                alignment: Alignment.centerLeft,
                                widthFactor: double.tryParse((item['share'] as String).replaceAll('%', ''))! / 100 * 3.5,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: ColorPalette.primaryContainer,
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              item['share'] as String,
                              style: AppTypography.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: ColorPalette.onSurfaceDark,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Stock
                      DataCell(
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: isStockSafe
                                ? ColorPalette.tertiary.withValues(alpha: 0.1)
                                : ColorPalette.warningTangerine.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (!isStockSafe) ...[
                                const Icon(Icons.warning_rounded,
                                    size: 13, color: ColorPalette.warningTangerine),
                                const SizedBox(width: 4),
                              ],
                              Text(
                                item['stock'] as String,
                                style: AppTypography.inter(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: isStockSafe
                                      ? ColorPalette.tertiary
                                      : ColorPalette.warningTangerine,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
          // Footer
          const Divider(height: 1, color: ColorPalette.borderSubtle),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Hiển thị 5 trên tổng số 48 món ăn trong danh mục ca làm việc.',
                  style: AppTypography.inter(fontSize: 12, color: ColorPalette.textMuted),
                ),
                Row(
                  children: [
                    Text(
                      'Xem tất cả thực đơn (48 món)',
                      style: AppTypography.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: ColorPalette.primaryContainer,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.arrow_forward_rounded,
                        size: 14, color: ColorPalette.primaryContainer),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableCategoryPill(String key, String label) {
    final isSelected = _selectedTableCategory == key;
    return InkWell(
      onTap: () => setState(() => _selectedTableCategory = key),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? ColorPalette.primaryContainer : ColorPalette.surfaceWhite,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? ColorPalette.primaryContainer : ColorPalette.borderSubtle,
          ),
        ),
        child: Text(
          label,
          style: AppTypography.inter(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? Colors.white : ColorPalette.textMuted,
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// CUSTOM PAINTERS: SPARKLINE & DONUT CHART
// ═══════════════════════════════════════════════════════════════════════════

class _SparklinePainter extends CustomPainter {
  final Color color;
  _SparklinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    path.moveTo(0, size.height * 0.8);
    path.quadraticBezierTo(
        size.width * 0.2, size.height * 0.6, size.width * 0.4, size.height * 0.7);
    path.quadraticBezierTo(
        size.width * 0.6, size.height * 0.35, size.width * 0.8, size.height * 0.4);
    path.lineTo(size.width, size.height * 0.15);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _PaymentDonutPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 24) / 2;
    const strokeWidth = 14.0;

    // Base circle
    final basePaint = Paint()
      ..color = const Color(0xFFF1F5F9)
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(center, radius, basePaint);

    // Segment 1: VietQR / MoMo (62%)
    final qrPaint = Paint()
      ..color = ColorPalette.primaryContainer
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * 0.62,
      false,
      qrPaint,
    );

    // Segment 2: Cash (28%)
    final cashPaint = Paint()
      ..color = ColorPalette.secondaryContainer
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2 + (2 * math.pi * 0.63),
      2 * math.pi * 0.27,
      false,
      cashPaint,
    );

    // Segment 3: Bank Transfer (10%)
    final bankPaint = Paint()
      ..color = ColorPalette.tertiary
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2 + (2 * math.pi * 0.91),
      2 * math.pi * 0.08,
      false,
      bankPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
