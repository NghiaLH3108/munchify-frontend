import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/widgets/admin/admin_widgets.dart';
import '../../../../injection_container.dart' as di;
import '../../../categories/domain/entities/category_entity.dart';
import '../../../categories/domain/usecases/manage_category_usecases.dart';
import '../bloc/product_admin_bloc.dart';
import '../bloc/product_admin_event.dart';

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
    return AdminFilterBar(
      searchController: _searchController,
      searchHint: 'Tìm theo tên món ăn hoặc mã SKU...',
      onSearchChanged: _onSearchChanged,
      filters: [
        AdminDropdownFilter<String?>(
          value: _selectedCategoryId,
          items: [
            const DropdownMenuItem<String?>(value: null, child: Text('Tất cả danh mục')),
            ..._categories.map((c) => DropdownMenuItem<String?>(
                  value: c.id.toString(),
                  child: Text(c.categoryName),
                )),
          ],
          onChanged: (value) {
            setState(() => _selectedCategoryId = value);
            _applyFilters();
          },
        ),
        AdminDropdownFilter<bool?>(
          value: _selectedIsActive,
          items: const [
            DropdownMenuItem<bool?>(value: null, child: Text('Tất cả trạng thái')),
            DropdownMenuItem<bool?>(value: true, child: Text('Đang kinh doanh')),
            DropdownMenuItem<bool?>(value: false, child: Text('Ngừng bán')),
          ],
          onChanged: (value) {
            setState(() => _selectedIsActive = value);
            _applyFilters();
          },
        ),
      ],
      trailingActions: [
        IconButton(
          onPressed: _resetFilters,
          icon: const Icon(Icons.restart_alt, color: Color(0xFF64748B)),
          tooltip: 'Đặt lại bộ lọc',
        ),
      ],
    );
  }
}
