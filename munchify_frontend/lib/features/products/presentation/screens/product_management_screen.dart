import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/widgets/app_toast.dart';
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
      body: BlocConsumer<ProductAdminBloc, ProductAdminState>(
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
    return Padding(
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
          Expanded(
            child: ProductDataTable(products: state.products),
          ),
        ],
      ),
    );
  }
}
