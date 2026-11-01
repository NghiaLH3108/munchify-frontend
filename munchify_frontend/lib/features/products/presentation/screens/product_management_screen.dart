import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/ColorPalette.dart';
import '../../../../core/widgets/admin/admin_widgets.dart';
import '../bloc/product_admin_bloc.dart';
import '../bloc/product_admin_event.dart';
import '../bloc/product_admin_state.dart';
import '../widgets/product_data_table.dart';
import '../widgets/product_filter_bar.dart';
import '../widgets/product_form_dialog.dart';
import '../widgets/product_stat_cards.dart';

class ProductManagementScreen extends StatefulWidget {
  const ProductManagementScreen({super.key});

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
      backgroundColor: ColorPalette.webBgAdmin,
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
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Page Header (Sử dụng AdminPageHeader)
          AdminPageHeader(
            icon: Icons.fastfood_rounded,
            title: 'Quản lý Sản phẩm & Thực đơn',
            subtitle: 'Quản lý danh sách thực đơn, đơn giá niêm yết, cảnh báo định mức...',
            addButtonText: 'Thêm món mới',
            onAddPressed: () => ProductFormDialog.show(context),
          ),
          const SizedBox(height: 20),

          // 2. Filters & Search (Đưa lên trên KPI giống mẫu quản lý danh mục)
          const ProductFilterBar(),
          const SizedBox(height: 20),

          // 3. KPI Metrics
          ProductStatCards(
            totalSkus: state.totalSkus,
            activeCount: state.activeCount,
            lowStockCount: state.lowStockCount,
          ),
          const SizedBox(height: 20),
          
          // 4. Data Table
          Expanded(
            child: ProductDataTable(products: state.products),
          ),
        ],
      ),
    );
  }
}
