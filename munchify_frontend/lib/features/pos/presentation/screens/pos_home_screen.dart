import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/pos_catalog_bloc.dart';
import '../bloc/pos_catalog_event.dart';
import '../bloc/pos_catalog_state.dart';
import '../../domain/entities/product_entity.dart';
import '../widgets/cart_summary_bottom_bar.dart';
import '../widgets/combo_grid_item.dart';
import '../widgets/product_grid_item.dart';
import '../../../customers/presentation/bloc/customer_bloc.dart';
import '../../../customers/presentation/bloc/customer_state.dart';
import '../../../customers/presentation/widgets/customer_lookup_bottom_sheet.dart';
import '../../../customers/presentation/widgets/add_customer_bottom_sheet.dart';
import '../../../customers/presentation/widgets/customer_loyalty_card.dart';

class PosHomeScreen extends StatefulWidget {
  const PosHomeScreen({Key? key}) : super(key: key);

  @override
  State<PosHomeScreen> createState() => _PosHomeScreenState();
}

class _PosHomeScreenState extends State<PosHomeScreen> {
  Timer? _debounce;
  final TextEditingController _searchController = TextEditingController();

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      context.read<PosCatalogBloc>().add(SearchProductEvent(query));
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFDF9), // Light Warm Cream
      appBar: _buildAppBar(),
      body: BlocBuilder<PosCatalogBloc, PosCatalogState>(
        builder: (context, state) {
          if (state is PosCatalogLoading) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFFE65100)));
          } else if (state is PosCatalogError) {
            return Center(child: Text('Lỗi tải dữ liệu: ${state.message}'));
          } else if (state is PosCatalogLoaded) {
            return _buildContent(state);
          }
          return const Center(child: Text('Đang khởi tạo...'));
        },
      ),
    );
  }

  Widget _buildContent(PosCatalogLoaded state) {
    final displayedProducts = state.displayedProducts;
    final combos = displayedProducts.where((p) => p.isCombo).toList();
    final normalProducts = displayedProducts.where((p) => !p.isCombo).toList();

    return Stack(
      children: [
        CustomScrollView(
          slivers: [
            _buildSearchBarSliver(),
            _buildCustomerRowSliver(),
            _buildCategoryTabsSliver(state),
            _buildInfoRowSliver(context, state),
            if (combos.isNotEmpty) _buildComboCarouselSliver(combos),
            _buildProductGridSliver(normalProducts),
            const SliverToBoxAdapter(
              child: SizedBox(height: 100), // padding for bottom bar
            ),
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
  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFE65100),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.restaurant, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Munchify POS',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'Trực tuyến • Quầy thu ngân #01',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      actions: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: const [
              Text('MT', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
              Icon(Icons.arrow_drop_down, color: Colors.black),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBarSliver() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  decoration: const InputDecoration(
                    icon: Icon(Icons.search, color: Colors.grey),
                    hintText: 'Tìm theo tên hoặc mã SP...',
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.qr_code_scanner, color: Color(0xFFE65100)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerRowSliver() {
    return SliverToBoxAdapter(
      child: BlocBuilder<CustomerBloc, CustomerState>(
        builder: (context, customerState) {
          if (customerState is CustomerSelected) {
            return const CustomerLoyaltyCard();
          }
          // Default: show phone lookup + add customer button
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => CustomerLookupBottomSheet.show(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.orange.shade200),
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.phone, size: 16, color: Color(0xFFE65100)),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Nhập SĐT khách (Tích điểm)...',
                              style: TextStyle(color: Colors.grey, fontSize: 13),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () => AddCustomerBottomSheet.show(context),
                  icon: const Icon(Icons.person_add, size: 16),
                  label: const Text('Thêm khách'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFA000), // Amber
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    elevation: 0,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoryTabsSliver(PosCatalogLoaded state) {
    final categories = state.categories;
    
    return SliverToBoxAdapter(
      child: SizedBox(
        height: 40,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: categories.length + 1, // +1 for "All"
          itemBuilder: (context, index) {
            final isAllOption = index == 0;
            final category = isAllOption ? null : categories[index - 1];
            final isSelected = isAllOption 
                ? state.selectedCategoryId == null 
                : state.selectedCategoryId == category?.id;

            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(isAllOption ? 'Tất cả' : category!.name),
                selected: isSelected,
                onSelected: (selected) {
                  context.read<PosCatalogBloc>().add(
                    FilterByCategoryEvent(isAllOption ? null : category?.id)
                  );
                },
                selectedColor: const Color(0xFFE65100),
                backgroundColor: Colors.white,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : Colors.black87,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(color: isSelected ? const Color(0xFFE65100) : Colors.grey.shade300),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildInfoRowSliver(BuildContext context, PosCatalogLoaded state) {
    final displayedCount = state.displayedProducts.length;
    final hasUnitFilter = state.selectedUnitName != null;

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            RichText(
              text: TextSpan(
                style: const TextStyle(color: Colors.black54, fontSize: 13),
                children: [
                  const TextSpan(text: 'Hiển thị '),
                  TextSpan(text: '$displayedCount sản phẩm', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                  const TextSpan(text: ' thực đơn'),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                _showUnitFilterBottomSheet(context, state);
              },
              child: Row(
                children: [
                  Icon(Icons.filter_list, size: 16, color: hasUnitFilter ? Colors.white : const Color(0xFFE65100)),
                  const SizedBox(width: 4),
                  Container(
                    padding: hasUnitFilter ? const EdgeInsets.symmetric(horizontal: 8, vertical: 4) : null,
                    decoration: hasUnitFilter ? BoxDecoration(
                      color: const Color(0xFFE65100),
                      borderRadius: BorderRadius.circular(12),
                    ) : null,
                    child: Text(
                      hasUnitFilter ? state.selectedUnitName! : 'Bộ lọc nhanh', 
                      style: TextStyle(
                        color: hasUnitFilter ? Colors.white : const Color(0xFFE65100), 
                        fontWeight: FontWeight.bold, 
                        fontSize: 13
                      )
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  void _showUnitFilterBottomSheet(BuildContext context, PosCatalogLoaded state) {
    // Extract unique units
    final units = state.products.map((p) => p.unitName).toSet().toList();
    units.sort();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (bottomSheetContext) {
        return SafeArea(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Lọc theo đơn vị', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(bottomSheetContext),
                    )
                  ],
                ),
              ),
              const Divider(),
              ListTile(
                title: const Text('Tất cả'),
                trailing: state.selectedUnitName == null ? const Icon(Icons.check, color: Color(0xFFE65100)) : null,
                onTap: () {
                  context.read<PosCatalogBloc>().add(const FilterByUnitEvent(null));
                  Navigator.pop(bottomSheetContext);
                },
              ),
              ...units.map((unit) => ListTile(
                title: Text(unit),
                trailing: state.selectedUnitName == unit ? const Icon(Icons.check, color: Color(0xFFE65100)) : null,
                onTap: () {
                  context.read<PosCatalogBloc>().add(FilterByUnitEvent(unit));
                  Navigator.pop(bottomSheetContext);
                },
              )).toList(),
              const SizedBox(height: 20),
            ],
          ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildComboCarouselSliver(List<ProductEntity> combos) {
    return SliverToBoxAdapter(
      child: Container(
        height: 280, // Approximate height of a combo item + padding
        margin: const EdgeInsets.only(bottom: 16),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: combos.length,
          itemBuilder: (context, index) {
            final product = combos[index];
            return Container(
              width: MediaQuery.of(context).size.width - 32, // Matches width of 2 regular products exactly
              margin: const EdgeInsets.only(right: 12),
              child: ComboGridItem(
                comboCode: product.code,
                comboName: product.name,
                description: 'Gồm thành phần combo', // Can be expanded later
                stockQuantity: product.stockQuantity,
                newPrice: product.price,
                oldPrice: product.price + 15000, // Dummy old price logic
                imageUrl: product.imageUrl ?? '',
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildProductGridSliver(List<ProductEntity> displayedProducts) {
    if (displayedProducts.isEmpty) {
      return const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Center(
            child: Text('Không tìm thấy sản phẩm nào', style: TextStyle(color: Colors.grey)),
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.90, // Tighter ratio for normal products
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final product = displayedProducts[index];
            
            return ProductGridItem(
              productCode: product.code,
              productName: product.name,
              unitName: product.unitName,
              stockQuantity: product.stockQuantity,
              price: product.price,
              imageUrl: product.imageUrl ?? '',
            );
          },
          childCount: displayedProducts.length,
        ),
      ),
    );
  }


}
