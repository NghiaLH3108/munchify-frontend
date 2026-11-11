import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/ColorPalette.dart';
import '../../../../core/services/signalr_service.dart';
import '../../../../core/widgets/app_toast.dart';
import '../bloc/pos_catalog_bloc.dart';
import '../bloc/pos_catalog_event.dart';
import '../bloc/pos_catalog_state.dart';
import '../widgets/cart_summary_bottom_bar.dart';
import '../widgets/catalog_info_row.dart';
import '../widgets/category_tabs.dart';
import '../widgets/combo_carousel.dart';
import '../widgets/combo_section_header.dart';
import '../widgets/pos_app_bar.dart';
import '../widgets/pos_product_grid.dart';
import '../widgets/pos_search_bar.dart';

/// Màn hình chính POS: hiển thị danh mục, giỏ hàng và lắng nghe SignalR cảnh báo kho.
class PosHomeScreen extends StatefulWidget {
  const PosHomeScreen({super.key});

  @override
  State<PosHomeScreen> createState() => _PosHomeScreenState();
}

class _PosHomeScreenState extends State<PosHomeScreen> {
  @override
  void initState() {
    super.initState();
    signalRService.onLowStockWarning(_onLowStockAlertReceived);
    signalRService.onExpiryAlert(_onExpiryAlertReceived);
  }

  @override
  void dispose() {
    signalRService.removeLowStockWarningListener(_onLowStockAlertReceived);
    signalRService.removeExpiryAlertListener(_onExpiryAlertReceived);
    super.dispose();
  }

  void _onLowStockAlertReceived(String message) {
    if (!mounted) return;

    // Tự động reload danh mục POS để cập nhật số lượng tồn kho mới nhất
    context.read<PosCatalogBloc>().add(LoadCatalogEvent());

    AppToast.warning(
      'CẢNH BÁO TỒN KHO THẤP: $message',
      context: context,
      duration: const Duration(seconds: 4),
    );
  }

  void _onExpiryAlertReceived(String message) {
    if (!mounted) return;

    AppToast.error(
      message,
      context: context,
      duration: const Duration(seconds: 4),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorPalette.background,
      appBar: const PosAppBar(),
      body: BlocBuilder<PosCatalogBloc, PosCatalogState>(
        builder: (context, state) {
          if (state is PosCatalogLoading) {
            return const Center(
              child: CircularProgressIndicator(color: ColorPalette.appetizingOrange),
            );
          } else if (state is PosCatalogError) {
            return Center(child: Text('Lỗi tải dữ liệu: ${state.message}'));
          } else if (state is PosCatalogLoaded) {
            return _PosCatalogContent(state: state);
          }
          return const Center(child: Text('Đang khởi tạo...'));
        },
      ),
    );
  }
}

class _PosCatalogContent extends StatelessWidget {
  final PosCatalogLoaded state;

  const _PosCatalogContent({required this.state});

  @override
  Widget build(BuildContext context) {
    final combos = state.combos; // Combo được load riêng với đầy đủ comboItems

    return Stack(
      children: [
        CustomScrollView(
          slivers: [
            const SliverToBoxAdapter(child: PosSearchBar()),
            SliverToBoxAdapter(child: CategoryTabs(state: state)),
            SliverToBoxAdapter(child: CatalogInfoRow(state: state)),
            if (combos.isNotEmpty) ...[
              SliverToBoxAdapter(child: ComboSectionHeader(count: combos.length)),
              SliverToBoxAdapter(child: ComboCarousel(combos: combos)),
            ],
            PosProductGrid(products: state.displayedProducts),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
        const Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: CartSummaryBottomBar(),
        ),
      ],
    );
  }
}
