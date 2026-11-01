import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/product_entity.dart';
import '../bloc/product_admin_bloc.dart';
import '../bloc/product_admin_event.dart';
import '../bloc/product_admin_state.dart';
import '../widgets/product_data_table.dart';
import '../widgets/product_filter_bar.dart';
import '../widgets/product_stat_cards.dart';

class ProductManagementScreen extends StatefulWidget {
  const ProductManagementScreen({Key? key}) : super(key: key);

  @override
  State<ProductManagementScreen> createState() => _ProductManagementScreenState();
}

class _ProductManagementScreenState extends State<ProductManagementScreen> {
  int _currentPage = 1;
  static const int _pageSize = 10;
  @override
  void initState() {
    super.initState();
    // Dispatch initial load event
    context.read<ProductAdminBloc>().add(const LoadProductsEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: BlocBuilder<ProductAdminBloc, ProductAdminState>(
        builder: (context, state) {
          if (state is ProductAdminLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ProductAdminError) {
            return Center(child: Text('Error: ${state.message}', style: const TextStyle(color: Colors.red)));
          } else if (state is ProductAdminLoaded) {
            return _buildContent(context, state);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, ProductAdminLoaded state) {
    final allProducts = state.products;
    final totalCount = allProducts.length;
    final totalPages = (totalCount / _pageSize).ceil().clamp(1, 999);
    if (_currentPage > totalPages) _currentPage = totalPages;
    final startIndex = (_currentPage - 1) * _pageSize;
    final endIndex = (startIndex + _pageSize).clamp(0, totalCount);
    final paginatedProducts = totalCount > 0 ? allProducts.sublist(startIndex, endIndex) : <ProductEntity>[];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header & Stats
          ProductStatCards(
            totalSkus: state.totalSkus,
            activeCount: state.activeCount,
            lowStockCount: state.lowStockCount,
          ),
          const SizedBox(height: 24),
          
          // Filters
          const ProductFilterBar(),
          const SizedBox(height: 16),
          
          // Data Table
          ProductDataTable(
            products: paginatedProducts,
            currentPage: _currentPage,
            totalPages: totalPages,
            totalCount: totalCount,
            startIndex: totalCount > 0 ? startIndex + 1 : 0,
            endIndex: endIndex,
            onPageChanged: (page) => setState(() => _currentPage = page),
          ),
        ],
      ),
    );
  }
}
