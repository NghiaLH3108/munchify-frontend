import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';
import '../bloc/product_admin_bloc.dart';
import '../bloc/product_admin_event.dart';
import '../../../../injection_container.dart' as di;
import '../../../categories/domain/usecases/manage_category_usecases.dart';
import '../../../categories/domain/entities/category_entity.dart';

class ProductFilterBar extends StatefulWidget {
  const ProductFilterBar({Key? key}) : super(key: key);

  @override
  State<ProductFilterBar> createState() => _ProductFilterBarState();
}

class _ProductFilterBarState extends State<ProductFilterBar> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  
  String? _selectedCategoryId;
  bool? _selectedIsActive;

  List<CategoryEntity> _categories = [];

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final catRes = await di.sl<GetCategoriesUseCase>().call(pageSize: 100);
    setState(() {
      catRes.fold((_) {}, (list) => _categories = list);
    });
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _applyFilters();
    });
  }

  void _applyFilters() {
    context.read<ProductAdminBloc>().add(LoadProductsEvent(
      search: _searchController.text,
      categoryId: _selectedCategoryId,
      isActive: _selectedIsActive,
    ));
  }

  void _resetFilters() {
    _searchController.clear();
    setState(() {
      _selectedCategoryId = null;
      _selectedIsActive = null;
    });
    _applyFilters();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Search
          Expanded(
            flex: 2,
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Tìm theo tên món ăn hoặc mã SKU...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surfaceVariant,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Category Dropdown
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: _selectedCategoryId,
                  hint: const Text('Tất cả danh mục'),
                  items: [
                    const DropdownMenuItem<String>(value: null, child: Text('Tất cả danh mục')),
                    ..._categories.map((c) => DropdownMenuItem<String>(
                          value: c.id.toString(),
                          child: Text(c.categoryName),
                        ))
                  ],
                  onChanged: (value) {
                    setState(() => _selectedCategoryId = value);
                    _applyFilters();
                  },
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Status Dropdown
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<bool?>(
                  isExpanded: true,
                  value: _selectedIsActive,
                  hint: const Text('Tất cả trạng thái'),
                  items: const [
                    DropdownMenuItem<bool?>(value: null, child: Text('Tất cả trạng thái')),
                    DropdownMenuItem<bool?>(value: true, child: Text('Đang kinh doanh (Active)')),
                    DropdownMenuItem<bool?>(value: false, child: Text('Ngừng bán (Inactive)')),
                  ],
                  onChanged: (value) {
                    setState(() => _selectedIsActive = value);
                    _applyFilters();
                  },
                ),
              ),
            ),
          ),
          // Reset Button
          IconButton(
            onPressed: _resetFilters,
            icon: const Icon(Icons.restart_alt),
            tooltip: 'Đặt lại bộ lọc',
          ),
        ],
      ),
    );
  }
}
