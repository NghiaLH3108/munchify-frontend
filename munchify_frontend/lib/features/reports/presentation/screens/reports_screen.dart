import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/AppTypography.dart';
import '../../../../core/theme/ColorPalette.dart';
import '../../../../injection_container.dart';
import '../../domain/entities/report_filter.dart';
import '../bloc/report_bloc.dart';
import '../bloc/report_event.dart';
import '../bloc/report_state.dart';
import '../utils/file_download.dart';
import '../widgets/payment_method_breakdown_widget.dart';
import '../widgets/revenue_chart_widget.dart';
import '../widgets/top_selling_table_widget.dart';

class ReportsScreen extends StatefulWidget {
  final bool embedInShell;

  const ReportsScreen({super.key, this.embedInShell = false});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  static final NumberFormat _vnd =
      NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0);

  late final ReportBloc _bloc;
  ReportFilter _filter = ReportFilter.today();

  @override
  void initState() {
    super.initState();
    _bloc = sl<ReportBloc>();
    _load();
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  void _load() => _bloc.add(LoadReports(_filter));

  void _setPeriod(String period) {
    setState(() => _filter = _filter.copyWith(period: period));
    _load();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _filter.date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked == null) return;
    setState(() => _filter = _filter.copyWith(date: picked));
    _load();
  }

  String get _dateLabel {
    switch (_filter.period) {
      case 'month':
        return DateFormat('MM/yyyy').format(_filter.date);
      case 'year':
        return DateFormat('yyyy').format(_filter.date);
      default:
        return DateFormat('dd/MM/yyyy').format(_filter.date);
    }
  }

  void _onStateChanged(BuildContext context, ReportState state) {
    if (state is! ReportLoaded) return;
    final messenger = ScaffoldMessenger.of(context);
    if (state.exportError != null) {
      messenger.showSnackBar(SnackBar(
        content: Text(state.exportError!),
        backgroundColor: Colors.redAccent,
      ));
    }
    final bytes = state.exportedBytes;
    if (bytes != null) {
      try {
        downloadFile(
          bytes,
          'bao-cao-${_filter.period}-${DateFormat('yyyyMMdd').format(_filter.date)}.xlsx',
        );
      } catch (e) {
        messenger.showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final body = BlocProvider.value(
      value: _bloc,
      child: BlocConsumer<ReportBloc, ReportState>(
        listenWhen: (p, c) => c is ReportLoaded && (c.exportedBytes != null || c.exportError != null),
        listener: _onStateChanged,
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildToolbar(state),
                const SizedBox(height: 20),
                if (state is ReportLoading || state is ReportInitial)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 80),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (state is ReportError)
                  _buildError(state.message)
                else if (state is ReportLoaded)
                  _buildContent(state),
              ],
            ),
          );
        },
      ),
    );

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: widget.embedInShell ? body : SafeArea(child: body),
    );
  }

  Widget _buildToolbar(ReportState state) {
    final exporting = state is ReportLoaded && state.isExporting;
    final canExport = state is ReportLoaded && !exporting;

    const double h = 40;
    final controls = Wrap(
      spacing: 12,
      runSpacing: 12,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        SegmentedButton<String>(
          style: const ButtonStyle(
            fixedSize: WidgetStatePropertyAll(Size.fromHeight(h)),
          ),
          segments: const [
            ButtonSegment(value: 'day', label: Text('Ngày')),
            ButtonSegment(value: 'month', label: Text('Tháng')),
            ButtonSegment(value: 'year', label: Text('Năm')),
          ],
          selected: {_filter.period},
          onSelectionChanged: (s) => _setPeriod(s.first),
        ),
        OutlinedButton.icon(
          onPressed: _pickDate,
          icon: const Icon(Icons.calendar_month_rounded, size: 16),
          label: Text(_dateLabel),
          style: OutlinedButton.styleFrom(minimumSize: const Size(0, h)),
        ),
        ElevatedButton.icon(
          onPressed: canExport ? () => _bloc.add(const ExportReportRequested()) : null,
          icon: exporting
              ? const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.file_download_rounded, size: 16),
          label: const Text('Xuất Excel'),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(0, h),
            backgroundColor: ColorPalette.primaryContainer,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );

    return Wrap(
      spacing: 16,
      runSpacing: 12,
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          'Báo cáo & Thống kê',
          style: AppTypography.plusJakarta(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: ColorPalette.onSurfaceDark,
          ),
        ),
        controls,
      ],
    );
  }

  Widget _buildError(String message) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: ColorPalette.surfaceWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ColorPalette.borderSubtle),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.redAccent),
          const SizedBox(width: 12),
          Expanded(child: Text(message)),
          TextButton(onPressed: _load, child: const Text('Thử lại')),
        ],
      ),
    );
  }

  Widget _buildContent(ReportLoaded state) {
    final r = state.revenue;
    return LayoutBuilder(builder: (context, c) {
      final wide = c.maxWidth > 900;
      const gap = 16.0;
      final cols = c.maxWidth > 900 ? 3 : (c.maxWidth > 560 ? 2 : 1);
      final kpiW = (c.maxWidth - gap * (cols - 1)) / cols;
      final kpis = Wrap(
        spacing: gap,
        runSpacing: gap,
        children: [
          _kpi('Tổng doanh thu', _vnd.format(r.totalRevenue), Icons.payments_rounded, kpiW),
          _kpi('Số đơn hoàn thành', '${r.orderCount}', Icons.receipt_long_rounded, kpiW),
          _kpi('Giá trị TB / đơn', _vnd.format(r.avgOrderValue), Icons.trending_up_rounded, kpiW),
        ],
      );
      final chart = RevenueChartWidget(points: r.dataPoints);
      final payments = PaymentMethodBreakdownWidget(items: r.byPaymentMethod);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          kpis,
          const SizedBox(height: 20),
          if (wide)
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(flex: 3, child: chart),
                  const SizedBox(width: gap),
                  Expanded(flex: 2, child: payments),
                ],
              ),
            )
          else ...[
            chart,
            const SizedBox(height: gap),
            payments,
          ],
          const SizedBox(height: 20),
          TopSellingTableWidget(items: state.topSelling),
        ],
      );
    });
  }

  Widget _kpi(String title, String value, IconData icon, double width) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: ColorPalette.surfaceWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ColorPalette.borderSubtle),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: ColorPalette.primaryFixed.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: ColorPalette.primaryContainer),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: AppTypography.inter(
                        fontSize: 12, color: ColorPalette.textMuted)),
                const SizedBox(height: 4),
                Text(value,
                    style: AppTypography.plusJakarta(
                        fontSize: 18, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
