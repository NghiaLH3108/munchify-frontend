import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/ColorPalette.dart';
import '../../../../core/theme/AppTypography.dart';
import '../../../../injection_container.dart';
import '../cubit/dashboard_cubit.dart';

/// Executive Analytics Dashboard View connected to live Backend API.
class AnalyticsDashboardView extends StatefulWidget {
  const AnalyticsDashboardView({super.key});

  @override
  State<AnalyticsDashboardView> createState() => _AnalyticsDashboardViewState();
}

class _AnalyticsDashboardViewState extends State<AnalyticsDashboardView> {
  static final NumberFormat _vnd =
      NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0);

  String _selectedChartPeriod = 'hour'; // 'hour', 'week', 'month'
  String _selectedTableCategory = 'all'; // 'all', 'single', 'combo', 'drink'

  late final DashboardCubit _dashboardCubit;

  @override
  void initState() {
    super.initState();
    _dashboardCubit = sl<DashboardCubit>();
    _dashboardCubit.loadSummary();
  }

  @override
  void dispose() {
    _dashboardCubit.close();
    super.dispose();
  }

  String _compactVnd(double value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(value % 1000000 == 0 ? 0 : 1)}M ₫';
    }
    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(0)}K ₫';
    }
    return '${value.toStringAsFixed(0)} ₫';
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardCubit, DashboardState>(
      bloc: _dashboardCubit,
      builder: (context, state) {
        final data = state is DashboardLoaded ? state.summary : null;
        final isRefreshing = state is DashboardLoaded && state.isRefreshing;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildPageTitleBar(state),
              if (isRefreshing) ...[
                const SizedBox(height: 12),
                const LinearProgressIndicator(
                  minHeight: 2,
                  color: ColorPalette.appetizingOrange,
                  backgroundColor: Colors.transparent,
                ),
              ],
              const SizedBox(height: 20),
              if (state is DashboardLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 64),
                    child: CircularProgressIndicator(
                      color: ColorPalette.appetizingOrange,
                    ),
                  ),
                )
              else if (state is DashboardError)
                _buildErrorBanner(state.message)
              else ...[
                _buildMetricCards(data),
                const SizedBox(height: 24),
                _buildAnalyticsGrid(context, data),
                const SizedBox(height: 24),
                _buildTopProductsTableCard(data),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildErrorBanner(String message) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: ColorPalette.surfaceWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ColorPalette.borderSubtle),
      ),
      child: Column(
        children: [
          const Icon(Icons.error_outline,
              color: ColorPalette.dangerCrimson, size: 36),
          const SizedBox(height: 10),
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppTypography.inter(
                fontSize: 13, color: ColorPalette.textMuted),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () => _dashboardCubit.loadSummary(),
            icon: const Icon(Icons.refresh_rounded, size: 16),
            label: const Text('Thử lại'),
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorPalette.appetizingOrange,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // PAGE TITLE & OPERATIONAL STATUS BAR
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildPageTitleBar(DashboardState state) {
    final syncTimeText = state is DashboardLoaded
        ? 'Đồng bộ lúc ${DateFormat('HH:mm:ss').format(state.fetchedAt)}'
        : 'Đang đồng bộ dữ liệu...';

    return Wrap(
      spacing: 16,
      runSpacing: 12,
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: Column(
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
                'Cập nhật dữ liệu thời gian thực từ hệ thống bán hàng tại quầy POS.',
                style: AppTypography.inter(
                  fontSize: 13,
                  color: ColorPalette.textMuted,
                ),
              ),
            ],
          ),
        ),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.sync_rounded,
                    size: 16, color: ColorPalette.tertiary),
                const SizedBox(width: 6),
                Text(
                  syncTimeText,
                  style: AppTypography.inter(
                    fontSize: 12,
                    color: ColorPalette.textMuted,
                  ),
                ),
              ],
            ),
            OutlinedButton.icon(
              onPressed: () => _dashboardCubit.loadSummary(),
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('Làm mới'),
              style: OutlinedButton.styleFrom(
                foregroundColor: ColorPalette.onSurfaceDark,
                backgroundColor: ColorPalette.surfaceWhite,
                side: const BorderSide(color: ColorPalette.borderSubtle),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                textStyle: AppTypography.inter(
                    fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 4 HIGH-DENSITY KPI CARDS (Row 1)
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildMetricCards(DashboardSummary? data) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 1100
            ? 4
            : (constraints.maxWidth > 560 ? 2 : 1);
        const gap = 16.0;
        final cardWidth =
            (constraints.maxWidth - ((crossAxisCount - 1) * gap)) /
                crossAxisCount;

        final revenueChange = data?.revenueChangePercent;
        final revenueUp = (revenueChange ?? 0) >= 0;
        final revenueDiff =
            (data?.todayRevenue ?? 0) - (data?.yesterdayRevenue ?? 0);
        final orderDiff =
            (data?.todayOrderCount ?? 0) - (data?.yesterdayOrderCount ?? 0);

        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            // Card 1: Doanh thu hôm nay
            _buildKpiCard(
              width: cardWidth,
              title: 'DOANH THU HÔM NAY',
              value: data != null ? _vnd.format(data.todayRevenue) : '0 ₫',
              icon: Icons.payments_outlined,
              iconColor: ColorPalette.primaryContainer,
              iconBg: ColorPalette.primaryFixed.withValues(alpha: 0.6),
              bottomContent: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        if (revenueChange != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: (revenueUp
                                      ? ColorPalette.tertiary
                                      : ColorPalette.dangerCrimson)
                                  .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  revenueUp
                                      ? Icons.trending_up_rounded
                                      : Icons.trending_down_rounded,
                                  size: 14,
                                  color: revenueUp
                                      ? ColorPalette.tertiary
                                      : ColorPalette.dangerCrimson,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${revenueUp ? "+" : ""}${revenueChange.toStringAsFixed(1)}%',
                                  style: AppTypography.inter(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: revenueUp
                                        ? ColorPalette.tertiary
                                        : ColorPalette.dangerCrimson,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        Text(
                          data != null
                              ? 'So với hôm qua: ${revenueDiff >= 0 ? "+" : ""}${_vnd.format(revenueDiff)}'
                              : 'Chưa có dữ liệu hôm qua',
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.inter(
                            fontSize: 11,
                            color: ColorPalette.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  CustomPaint(
                    size: const Size(52, 20),
                    painter: _SparklinePainter(color: ColorPalette.tertiary),
                  ),
                ],
              ),
            ),
            // Card 2: Tổng đơn hàng
            _buildKpiCard(
              width: cardWidth,
              title: 'TỔNG ĐƠN HÀNG',
              value: data != null ? '${data.todayOrderCount}' : '0',
              valueUnit: ' đơn',
              icon: Icons.receipt_long_outlined,
              iconColor: ColorPalette.secondary,
              iconBg: ColorPalette.surfaceContainerHigh,
              bottomContent: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: RichText(
                      overflow: TextOverflow.ellipsis,
                      text: TextSpan(
                        text: 'Giá trị TB: ',
                        style: AppTypography.inter(
                            fontSize: 12, color: ColorPalette.textMuted),
                        children: [
                          TextSpan(
                            text: data != null
                                ? _vnd.format(data.averageOrderValue)
                                : '0 ₫',
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
                  ),
                  const SizedBox(width: 6),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        orderDiff >= 0
                            ? Icons.north_east_rounded
                            : Icons.south_east_rounded,
                        size: 13,
                        color: orderDiff >= 0
                            ? ColorPalette.tertiary
                            : ColorPalette.dangerCrimson,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        data != null
                            ? '${orderDiff >= 0 ? "+" : ""}$orderDiff đơn'
                            : '0 đơn',
                        style: AppTypography.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: orderDiff >= 0
                              ? ColorPalette.tertiary
                              : ColorPalette.dangerCrimson,
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
              titleBadge:
                  (data?.lowStockProductCount ?? 0) > 0 ? 'Cần nhập' : null,
              value: data != null ? '${data.lowStockProductCount}' : '0',
              valueUnit: ' sản phẩm',
              valueColor: (data?.lowStockProductCount ?? 0) > 0
                  ? ColorPalette.dangerCrimson
                  : null,
              icon: Icons.warning_amber_rounded,
              iconColor: ColorPalette.warningTangerine,
              iconBg: const Color(0xFFFFFBEB),
              borderLeft: (data?.lowStockProductCount ?? 0) > 0
                  ? const BorderSide(
                      color: ColorPalette.warningTangerine, width: 4)
                  : null,
              bottomContent: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      (data?.lowStockProductCount ?? 0) > 0
                          ? 'Chạm ngưỡng tồn tối thiểu'
                          : 'Tồn kho ổn định',
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.inter(
                          fontSize: 12, color: ColorPalette.textMuted),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Tổng ${data?.totalMenuProductsCount ?? 0} món',
                    style: AppTypography.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: ColorPalette.primaryContainer,
                    ),
                  ),
                ],
              ),
            ),
            // Card 4: Khách hàng thân thiết
            _buildKpiCard(
              width: cardWidth,
              title: 'KHÁCH HÀNG THÂN THIẾT',
              value: data != null ? '${data.totalCustomerCount}' : '0',
              valueUnit: ' thành viên',
              icon: Icons.group_add_outlined,
              iconColor: const Color(0xFF7E22CE),
              iconBg: const Color(0xFFFAF5FF),
              bottomContent: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: RichText(
                      overflow: TextOverflow.ellipsis,
                      text: TextSpan(
                        text: '+${data?.newCustomersTodayCount ?? 0} mới ',
                        style: AppTypography.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: ColorPalette.tertiary,
                        ),
                        children: [
                          TextSpan(
                            text: 'hôm nay',
                            style: AppTypography.inter(
                                fontSize: 12, color: ColorPalette.textMuted),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${(data?.loyaltyCustomerPercent ?? 0).toStringAsFixed(0)}% có điểm',
                    style: AppTypography.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF7E22CE),
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
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            crossAxisAlignment: WrapCrossAlignment.center,
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
                              if (titleBadge != null)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: ColorPalette.warningTangerine
                                        .withValues(alpha: 0.1),
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
                          ),
                          const SizedBox(height: 6),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: RichText(
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
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
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
                    border:
                        Border(top: BorderSide(color: ColorPalette.borderSubtle)),
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
  // MAIN CONTENT ANALYTICS GRID (Bar Chart Left / Donut Chart Right)
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildAnalyticsGrid(BuildContext context, DashboardSummary? data) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 1000;
        if (isDesktop) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 7, child: _buildRevenueTrendCard(data)),
              const SizedBox(width: 24),
              Expanded(flex: 5, child: _buildPaymentMethodsCard(data)),
            ],
          );
        } else {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildRevenueTrendCard(data),
              const SizedBox(height: 24),
              _buildPaymentMethodsCard(data),
            ],
          );
        }
      },
    );
  }

  List<DashboardTrendPoint> _activeTrendPoints(DashboardSummary? data) {
    if (data == null) return const [];
    switch (_selectedChartPeriod) {
      case 'week':
        return data.weeklyTrend;
      case 'month':
        return data.monthlyTrend;
      case 'hour':
      default:
        return data.hourlyTrend;
    }
  }

  Widget _buildRevenueTrendCard(DashboardSummary? data) {
    final points = _activeTrendPoints(data);
    final peakPoint = points.where((p) => p.isPeak).firstOrNull;
    final peakLabel = _selectedChartPeriod == 'hour'
        ? (data?.peakHourLabel.isNotEmpty == true
            ? data!.peakHourLabel
            : 'Chưa phát sinh đơn')
        : (peakPoint != null && peakPoint.revenue > 0
            ? peakPoint.label
            : 'Chưa phát sinh đơn');
    final peakRevenue = _selectedChartPeriod == 'hour'
        ? (data?.peakHourRevenue ?? 0)
        : (peakPoint?.revenue ?? 0);
    final peakOrders = _selectedChartPeriod == 'hour'
        ? (data?.peakHourOrderCount ?? 0)
        : (peakPoint?.orderCount ?? 0);

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
                    'Phân tích nhịp độ bán hàng thực tế từ các đơn hàng hoàn tất.',
                    style: AppTypography.inter(
                        fontSize: 12, color: ColorPalette.textMuted),
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
          // Peak Highlight Card (Responsive)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: ColorPalette.primaryFixed.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                  color: ColorPalette.primaryContainer.withValues(alpha: 0.2)),
            ),
            child: Row(
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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Cao điểm ghi nhận: $peakLabel',
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: ColorPalette.primaryContainer,
                        ),
                      ),
                      RichText(
                        overflow: TextOverflow.ellipsis,
                        text: TextSpan(
                          text: 'Doanh số cao nhất: ',
                          style: AppTypography.inter(
                              fontSize: 11, color: ColorPalette.textMuted),
                          children: [
                            TextSpan(
                              text: _vnd.format(peakRevenue),
                              style: AppTypography.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: ColorPalette.onSurfaceDark,
                              ),
                            ),
                            TextSpan(text: ' ($peakOrders đơn hoàn thành)'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: ColorPalette.surfaceWhite,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: ColorPalette.primaryContainer
                            .withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    peakOrders > 0 ? 'Đông khách' : 'Bình thường',
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
          // Bar Chart
          SizedBox(
            height: 220,
            child: _buildBarChart(points),
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
                      'Doanh thu thực tế (POS)',
                      style: AppTypography.inter(
                          fontSize: 11, color: ColorPalette.onSurfaceDark),
                    ),
                  ],
                ),
                RichText(
                  text: TextSpan(
                    text: 'Mốc cao nhất: ',
                    style: AppTypography.inter(
                        fontSize: 11, color: ColorPalette.textMuted),
                    children: [
                      TextSpan(
                        text: peakLabel,
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
            color:
                isSelected ? ColorPalette.onSurfaceDark : ColorPalette.textMuted,
          ),
        ),
      ),
    );
  }

  Widget _buildBarChart(List<DashboardTrendPoint> points) {
    final displayPoints = points.isNotEmpty
        ? points
        : const [
            DashboardTrendPoint(
                label: '08:00', revenue: 0, orderCount: 0, isPeak: false),
            DashboardTrendPoint(
                label: '11:00', revenue: 0, orderCount: 0, isPeak: false),
            DashboardTrendPoint(
                label: '13:00', revenue: 0, orderCount: 0, isPeak: false),
            DashboardTrendPoint(
                label: '15:00', revenue: 0, orderCount: 0, isPeak: false),
            DashboardTrendPoint(
                label: '17:00', revenue: 0, orderCount: 0, isPeak: false),
            DashboardTrendPoint(
                label: '19:00', revenue: 0, orderCount: 0, isPeak: false),
            DashboardTrendPoint(
                label: '21:00', revenue: 0, orderCount: 0, isPeak: false),
          ];

    final maxRev = displayPoints.fold<double>(
        0, (prev, elem) => elem.revenue > prev ? elem.revenue : prev);
    final chartCeiling = maxRev > 0 ? (maxRev * 1.2) : 3000000.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final axisLabelWidth = constraints.maxWidth < 420 ? 48.0 : 64.0;
        return Stack(
          children: [
            // Y-axis grid lines
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildGridLine(_compactVnd(chartCeiling), axisLabelWidth),
                _buildGridLine(
                    _compactVnd(chartCeiling * 2 / 3), axisLabelWidth),
                _buildGridLine(_compactVnd(chartCeiling / 3), axisLabelWidth),
                _buildGridLine('0 ₫', axisLabelWidth),
              ],
            ),
            // Bar columns
            Padding(
              padding: EdgeInsets.only(
                  top: 16,
                  bottom: 22,
                  left: axisLabelWidth + 6,
                  right: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: displayPoints.map((col) {
                  final ratio = chartCeiling > 0
                      ? (col.revenue / chartCeiling).clamp(0.0, 1.0)
                      : 0.0;
                  final barHeight = col.revenue > 0
                      ? math.max(8.0, 130.0 * ratio)
                      : 4.0;

                  return Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (col.isPeak && col.revenue > 0)
                          Container(
                            margin: const EdgeInsets.only(bottom: 4),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 4, vertical: 2),
                            decoration: BoxDecoration(
                              color: ColorPalette.inverseSurface,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              _compactVnd(col.revenue),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.inter(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        Container(
                          width: constraints.maxWidth < 450 ? 14 : 22,
                          height: barHeight,
                          decoration: BoxDecoration(
                            color: col.revenue > 0
                                ? (col.isPeak
                                    ? ColorPalette.primaryContainer
                                    : ColorPalette.primaryLight)
                                : ColorPalette.borderSubtle,
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(4)),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          col.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.inter(
                            fontSize: 10,
                            fontWeight:
                                col.isPeak ? FontWeight.w700 : FontWeight.w500,
                            color: col.isPeak
                                ? ColorPalette.primaryContainer
                                : ColorPalette.textMuted,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildGridLine(String label, double width) {
    return Row(
      children: [
        SizedBox(
          width: width,
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style:
                AppTypography.inter(fontSize: 10, color: ColorPalette.textMuted),
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
  Widget _buildPaymentMethodsCard(DashboardSummary? data) {
    final totalOrders = data?.paymentTotalOrderCount ?? 0;
    final methods = data?.paymentMethods ?? const [];

    DashboardPaymentMethod findMethod(String key, String defaultName) {
      return methods.where((m) => m.methodKey == key).firstOrNull ??
          DashboardPaymentMethod(
            methodKey: key,
            methodName: defaultName,
            orderCount: 0,
            totalAmount: 0,
            sharePercent: 0,
          );
    }

    final qr = findMethod('QR_CODE', 'VietQR / MoMo');
    final cash = findMethod('CASH', 'Tiền mặt (Cash)');
    final transfer = findMethod('TRANSFER', 'Chuyển khoản');

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
              Expanded(
                child: Text(
                  'Cơ cấu phương thức thanh toán',
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.plusJakarta(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: ColorPalette.onSurfaceDark,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.info_outline_rounded,
                  size: 18, color: ColorPalette.textMuted),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Tổng số $totalOrders đơn đã giao dịch thành công hôm nay.',
            style: AppTypography.inter(
                fontSize: 12, color: ColorPalette.textMuted),
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
                    painter: _PaymentDonutPainter(
                      qrRatio: (qr.sharePercent / 100).clamp(0.0, 1.0),
                      cashRatio: (cash.sharePercent / 100).clamp(0.0, 1.0),
                      transferRatio:
                          (transfer.sharePercent / 100).clamp(0.0, 1.0),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$totalOrders',
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
            title: qr.methodName,
            subtitle: '${qr.orderCount} đơn hoàn tất',
            amount: _vnd.format(qr.totalAmount),
            percent: '${qr.sharePercent.toStringAsFixed(0)}%',
            percentColor: ColorPalette.primaryContainer,
          ),
          const SizedBox(height: 10),
          _buildPaymentMethodRow(
            icon: Icons.attach_money_rounded,
            iconColor: ColorPalette.secondary,
            iconBg: ColorPalette.secondaryContainer.withValues(alpha: 0.2),
            title: cash.methodName,
            subtitle: '${cash.orderCount} đơn hoàn tất',
            amount: _vnd.format(cash.totalAmount),
            percent: '${cash.sharePercent.toStringAsFixed(0)}%',
            percentColor: ColorPalette.secondaryContainer,
          ),
          const SizedBox(height: 10),
          _buildPaymentMethodRow(
            icon: Icons.account_balance_rounded,
            iconColor: ColorPalette.tertiary,
            iconBg: ColorPalette.tertiary.withValues(alpha: 0.12),
            title: transfer.methodName,
            subtitle: '${transfer.orderCount} đơn đối soát',
            amount: _vnd.format(transfer.totalAmount),
            percent: '${transfer.sharePercent.toStringAsFixed(0)}%',
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
        border:
            Border.all(color: ColorPalette.borderSubtle.withValues(alpha: 0.7)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: ColorPalette.onSurfaceDark,
                        ),
                      ),
                      Text(
                        subtitle,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.inter(
                            fontSize: 11, color: ColorPalette.textMuted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
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
  // BOTTOM SECTION: TOP 5 PRODUCTS TABLE
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildTopProductsTableCard(DashboardSummary? data) {
    final allTop = data?.topProducts ?? const [];
    final filtered = allTop.where((p) {
      switch (_selectedTableCategory) {
        case 'single':
          return !p.isCombo;
        case 'combo':
          return p.isCombo;
        case 'drink':
          final cat = p.categoryName.toLowerCase();
          return cat.contains('trà') ||
              cat.contains('nước') ||
              cat.contains('giải khát') ||
              cat.contains('đồ uống') ||
              cat.contains('drink') ||
              cat.contains('coffee');
        case 'all':
        default:
          return true;
      }
    }).take(5).toList();

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
                    Wrap(
                      spacing: 10,
                      runSpacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          'Top 5 Sản phẩm & Combo bán chạy nhất',
                          style: AppTypography.plusJakarta(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: ColorPalette.onSurfaceDark,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
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
                      style: AppTypography.inter(
                          fontSize: 12, color: ColorPalette.textMuted),
                    ),
                  ],
                ),
                // Filter Pills
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildTableCategoryPill('all', 'Tất cả'),
                    _buildTableCategoryPill('single', 'Món lẻ'),
                    _buildTableCategoryPill('combo', 'Combo ăn vặt'),
                    _buildTableCategoryPill('drink', 'Nước uống'),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: ColorPalette.borderSubtle),
          // Table Content
          if (filtered.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
              child: Center(
                child: Text(
                  'Chưa có dữ liệu bán hàng cho phân loại này.',
                  style: AppTypography.inter(
                      fontSize: 13, color: ColorPalette.textMuted),
                ),
              ),
            )
          else
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
                      label:
                          Text('DOANH THU', style: AppTypography.tableHeader),
                      numeric: true,
                    ),
                    DataColumn(
                      label: Text('TỶ TRỌNG', style: AppTypography.tableHeader),
                    ),
                    DataColumn(
                      label: Text('TỒN KHO', style: AppTypography.tableHeader),
                    ),
                  ],
                  rows: filtered.asMap().entries.map((entry) {
                    final idx = entry.key + 1;
                    final item = entry.value;
                    final rank = '$idx';
                    final isTop1 = idx == 1;
                    final isTop2 = idx == 2;
                    final isStockSafe = !item.isOutOfStock;

                    Color rankBg = const Color(0xFFF1F5F9);
                    Color rankColor = const Color(0xFF64748B);
                    if (isTop1) {
                      rankBg = const Color(0xFFFBBF24);
                      rankColor = const Color(0xFF0F172A);
                    } else if (isTop2) {
                      rankBg = const Color(0xFFE2E8F0);
                      rankColor = const Color(0xFF334155);
                    }

                    final iconData = item.isCombo
                        ? Icons.lunch_dining_rounded
                        : Icons.tapas_rounded;
                    final iconColor = item.isCombo
                        ? ColorPalette.primaryContainer
                        : ColorPalette.primaryLight;
                    final iconBg = item.isCombo
                        ? const Color(0xFFFFEDD5)
                        : const Color(0xFFFFF7ED);

                    final stockLabel = item.isCombo
                        ? (isStockSafe
                            ? 'Còn ${item.stockQuantity} suất'
                            : 'Combo đã hết')
                        : (isStockSafe
                            ? 'Còn ${item.stockQuantity} ${item.unitName}'
                            : 'Sắp hết: ${item.stockQuantity} ${item.unitName}');

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
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: iconBg,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  iconData,
                                  color: iconColor,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              ConstrainedBox(
                                constraints:
                                    const BoxConstraints(maxWidth: 260),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.productName,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppTypography.inter(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: ColorPalette.onSurfaceDark,
                                      ),
                                    ),
                                    if (item.description != null &&
                                        item.description!.trim().isNotEmpty) ...[
                                      const SizedBox(height: 2),
                                      Text(
                                        item.description!,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: AppTypography.inter(
                                          fontSize: 11,
                                          color: ColorPalette.textMuted,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Code
                        DataCell(
                          Text(
                            item.productCode,
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
                            item.categoryName,
                            style: AppTypography.inter(
                              fontSize: 12,
                              color: ColorPalette.textMuted,
                            ),
                          ),
                        ),
                        // Price
                        DataCell(
                          Text(
                            _vnd.format(item.unitPrice),
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
                            '${item.quantitySold} ${item.unitName}',
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
                            _vnd.format(item.totalRevenue),
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
                            mainAxisSize: MainAxisSize.min,
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
                                  widthFactor:
                                      (item.revenueSharePercent / 100)
                                          .clamp(0.0, 1.0),
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
                                '${item.revenueSharePercent.toStringAsFixed(1)}%',
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
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: isStockSafe
                                  ? ColorPalette.tertiary.withValues(alpha: 0.1)
                                  : ColorPalette.warningTangerine
                                      .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (!isStockSafe) ...[
                                  const Icon(Icons.warning_rounded,
                                      size: 13,
                                      color: ColorPalette.warningTangerine),
                                  const SizedBox(width: 4),
                                ],
                                Text(
                                  stockLabel,
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
            child: Wrap(
              spacing: 12,
              runSpacing: 8,
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  'Hiển thị ${filtered.length} trên tổng số ${data?.totalMenuProductsCount ?? 0} món đang kinh doanh.',
                  style: AppTypography.inter(
                      fontSize: 12, color: ColorPalette.textMuted),
                ),
                Text(
                  'Tổng thực đơn: ${data?.totalMenuProductsCount ?? 0} món',
                  style: AppTypography.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: ColorPalette.primaryContainer,
                  ),
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
          color: isSelected
              ? ColorPalette.primaryContainer
              : ColorPalette.surfaceWhite,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? ColorPalette.primaryContainer
                : ColorPalette.borderSubtle,
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
    path.quadraticBezierTo(size.width * 0.2, size.height * 0.6,
        size.width * 0.4, size.height * 0.7);
    path.quadraticBezierTo(size.width * 0.6, size.height * 0.35,
        size.width * 0.8, size.height * 0.4);
    path.lineTo(size.width, size.height * 0.15);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _PaymentDonutPainter extends CustomPainter {
  final double qrRatio;
  final double cashRatio;
  final double transferRatio;

  _PaymentDonutPainter({
    required this.qrRatio,
    required this.cashRatio,
    required this.transferRatio,
  });

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

    double startAngle = -math.pi / 2;

    void drawSegment(double ratio, Color color) {
      if (ratio <= 0) return;
      final sweep = 2 * math.pi * ratio;
      final paint = Paint()
        ..color = color
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.butt
        ..style = PaintingStyle.stroke;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweep,
        false,
        paint,
      );
      startAngle += sweep;
    }

    drawSegment(qrRatio, ColorPalette.primaryContainer);
    drawSegment(cashRatio, ColorPalette.secondaryContainer);
    drawSegment(transferRatio, ColorPalette.tertiary);
  }

  @override
  bool shouldRepaint(covariant _PaymentDonutPainter oldDelegate) {
    return oldDelegate.qrRatio != qrRatio ||
        oldDelegate.cashRatio != cashRatio ||
        oldDelegate.transferRatio != transferRatio;
  }
}
