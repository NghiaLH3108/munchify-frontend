import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/ColorPalette.dart';
import '../../../../core/theme/AppTypography.dart';
import '../bloc/admin_order_bloc.dart';
import '../bloc/admin_order_event.dart';
import '../bloc/admin_order_state.dart';
import '../widgets/order_data_table.dart';
import '../widgets/order_detail_modal.dart';
import '../widgets/order_filter_bar.dart';
import '../../data/models/admin_order_filter_params.dart';

class AdminOrderInquiryScreen extends StatefulWidget {
  final bool embedInShell;

  const AdminOrderInquiryScreen({
    super.key,
    this.embedInShell = false,
  });

  @override
  State<AdminOrderInquiryScreen> createState() => _AdminOrderInquiryScreenState();
}

class _AdminOrderInquiryScreenState extends State<AdminOrderInquiryScreen> {
  AdminOrderFilterParams _filterParams = const AdminOrderFilterParams();

  @override
  void initState() {
    super.initState();
    context.read<AdminOrderBloc>().add(FetchAdminOrdersEvent(filterParams: _filterParams));
  }

  void _onFilterChanged(AdminOrderFilterParams newParams) {
    setState(() {
      _filterParams = newParams;
    });
    context.read<AdminOrderBloc>().add(FetchAdminOrdersEvent(filterParams: newParams));
  }

  void _onRefresh() {
    context.read<AdminOrderBloc>().add(FetchAdminOrdersEvent(filterParams: _filterParams));
  }

  @override
  Widget build(BuildContext context) {
    final content = SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildPageHeader(),
          const SizedBox(height: 20),

          // ── Filter Bar stays outside BlocBuilder to preserve focus & state ──
          OrderFilterBar(
            currentFilter: _filterParams,
            onFilterChanged: _onFilterChanged,
            onRefresh: _onRefresh,
          ),

          const SizedBox(height: 20),

          // ── Table Content reactive to Bloc State ──
          BlocConsumer<AdminOrderBloc, AdminOrderState>(
            listener: (context, state) {
              if (state is AdminOrderLoaded && state.selectedOrderDetail != null) {
                OrderDetailModal.show(context, state.selectedOrderDetail!);
              } else if (state is AdminOrderError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: ColorPalette.dangerCrimson,
                  ),
                );
              }
            },
            builder: (context, state) {
              if (state is AdminOrderLoading) {
                return Container(
                  height: 320,
                  decoration: BoxDecoration(
                    color: ColorPalette.surfaceWhite,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: ColorPalette.borderSubtle),
                  ),
                  child: const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(color: ColorPalette.primaryContainer),
                        SizedBox(height: 16),
                        Text(
                          'Đang tải danh sách đơn hàng...',
                          style: TextStyle(color: ColorPalette.textMuted, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                );
              }

              if (state is AdminOrderError) {
                return Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: ColorPalette.surfaceWhite,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: ColorPalette.borderSubtle),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline_rounded, color: ColorPalette.dangerCrimson, size: 40),
                        const SizedBox(height: 12),
                        Text(
                          'Đã xảy ra lỗi tải dữ liệu',
                          style: AppTypography.plusJakarta(fontSize: 16, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 4),
                        Text(state.message, style: AppTypography.inter(fontSize: 13, color: ColorPalette.textMuted)),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _onRefresh,
                          icon: const Icon(Icons.refresh_rounded),
                          label: const Text('Thử lại'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ColorPalette.primaryContainer,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              if (state is AdminOrderLoaded) {
                return OrderDataTable(
                  pagedOrders: state.pagedOrders,
                  onPageChanged: (newPage) {
                    context.read<AdminOrderBloc>().add(ChangeOrderPageEvent(newPage));
                  },
                  onViewDetail: (orderId) {
                    context.read<AdminOrderBloc>().add(FetchAdminOrderDetailEvent(orderId));
                  },
                );
              }

              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );

    if (widget.embedInShell) {
      return content;
    }

    return Scaffold(
      backgroundColor: ColorPalette.webBgAdmin,
      appBar: AppBar(
        title: const Text('Tra cứu Đơn hàng'),
        backgroundColor: ColorPalette.surfaceWhite,
        foregroundColor: ColorPalette.onSurfaceDark,
        elevation: 0,
      ),
      body: content,
    );
  }

  Widget _buildPageHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tra cứu & Theo dõi Đơn hàng',
          style: AppTypography.plusJakarta(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: ColorPalette.onSurfaceDark,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Giám sát lịch sử giao dịch bán lẻ tại quầy, lọc theo ngày và tra cứu chi tiết hóa đơn đối soát.',
          style: AppTypography.inter(
            fontSize: 13,
            color: ColorPalette.textMuted,
          ),
        ),
      ],
    );
  }
}
