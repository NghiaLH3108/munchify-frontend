import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/admin/admin_widgets.dart';
import '../../domain/entities/product_entity.dart';
import '../../../../core/widgets/app_toast.dart';
import '../bloc/product_admin_bloc.dart';
import '../bloc/product_admin_event.dart';
import '../bloc/product_admin_state.dart';
import '../widgets/product_data_table.dart';
import '../widgets/product_filter_bar.dart';
import '../widgets/product_form_dialog.dart';
import '../widgets/product_stat_cards.dart';

class ProductManagementScreen extends StatefulWidget {
  final bool embedInShell;

  const ProductManagementScreen({super.key, this.embedInShell = true});

  @override
  State<ProductManagementScreen> createState() =>
      _ProductManagementScreenState();
}

class _ProductManagementScreenState extends State<ProductManagementScreen> {
  int _currentPage = 1;
  static const int _pageSize = 10;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    context.read<ProductAdminBloc>().add(const LoadProductsEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProductAdminBloc, ProductAdminState>(
      listener: (context, state) {
        if (state is ProductAdminLoaded && state.successMessage != null) {
          AppToast.success(state.successMessage!, context: context);
        }
        if (state is ProductAdminLoaded && state.errorMessage != null) {
          AppToast.error(state.errorMessage!, context: context);
        }
        if (state is ProductAdminError) {
          AppToast.error(state.message, context: context);
        }
      },
      builder: (context, state) {
        Widget? stateView;
        List<Widget> kpis = const [];
        Widget? table;

        if (state is ProductAdminLoading) {
          stateView = const AdminLoadingView(
            message: 'Đang đồng bộ danh sách sản phẩm...',
          );
        } else if (state is ProductAdminError) {
          stateView = AdminErrorView(message: state.message, onRetry: _loadData);
        } else if (state is ProductAdminLoaded) {
          final allProducts = state.products;
          final totalCount = allProducts.length;
          final totalPages = (totalCount / _pageSize).ceil().clamp(1, 999);
          if (_currentPage > totalPages) _currentPage = totalPages;
          final startIndex = (_currentPage - 1) * _pageSize;
          final endIndex = (startIndex + _pageSize).clamp(0, totalCount);
          final paginatedProducts = totalCount > 0
              ? allProducts.sublist(startIndex, endIndex)
              : <ProductEntity>[];

          kpis = ProductStatCards.cards(
            totalSkus: state.totalSkus,
            activeCount: state.activeCount,
            lowStockCount: state.lowStockCount,
          );
          table = ProductDataTable(
            products: paginatedProducts,
            currentPage: _currentPage,
            totalPages: totalPages,
            totalCount: totalCount,
            startIndex: totalCount > 0 ? startIndex + 1 : 0,
            endIndex: endIndex,
            onPageChanged: (page) => setState(() => _currentPage = page),
          );
        } else {
          stateView = const SizedBox.shrink();
        }

        return AdminListScaffold(
          embedInShell: widget.embedInShell,
          stickyHeader: AdminStickyHeader(
            breadcrumb: 'Sản phẩm',
            onRefresh: _loadData,
          ),
          header: AdminPageHeader(
            icon: Icons.fastfood_rounded,
            title: 'Quản lý Sản phẩm & Thực đơn',
            subtitle:
                'Quản lý danh sách thực đơn, đơn giá niêm yết, cảnh báo định mức...',
            addButtonText: 'Thêm món mới',
            onAddPressed: () => ProductFormDialog.show(context),
          ),
          filterBar: const ProductFilterBar(),
          kpiCards: kpis,
          table: table,
          stateView: stateView,
        );
      },
    );
  }
}
