import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../bloc/category_bloc.dart';
import '../bloc/category_event.dart';
import '../bloc/category_state.dart';
import '../widgets/category_form_dialog.dart';
import '../widgets/delete_confirm_dialog.dart';

class ManageCategoriesScreen extends StatefulWidget {
  const ManageCategoriesScreen({Key? key}) : super(key: key);

  @override
  State<ManageCategoriesScreen> createState() => _ManageCategoriesScreenState();
}

class _ManageCategoriesScreenState extends State<ManageCategoriesScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool? _filterIsActive;
  int _currentPage = 1;
  final int _pageSize = 10;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    context.read<CategoryBloc>().add(LoadCategoriesEvent(
          searchTerm: _searchController.text.trim(),
          isActive: _filterIsActive,
          page: _currentPage,
          pageSize: _pageSize,
        ));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showAddCategory() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const CategoryFormDialog(),
    );

    if (result != null) {
      if (!mounted) return;
      context.read<CategoryBloc>().add(CreateCategoryEvent(
            categoryName: result['categoryName'],
            description: result['description'],
            isActive: result['isActive'],
          ));
    }
  }

  void _showEditCategory(int id, String name, String? desc, bool isActive) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: false,
      builder: (context) => CategoryFormDialog(
        id: id,
        initialName: name,
        initialDescription: desc,
        initialIsActive: isActive,
      ),
    );

    if (result != null) {
      if (!mounted) return;
      context.read<CategoryBloc>().add(UpdateCategoryEvent(
            id: id,
            categoryName: result['categoryName'],
            description: result['description'],
            isActive: result['isActive'],
          ));
    }
  }

  void _showDeleteConfirm(int id, String name) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => DeleteConfirmDialog(categoryName: name),
    );

    if (confirmed == true) {
      if (!mounted) return;
      context.read<CategoryBloc>().add(DeleteCategoryEvent(id));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: const Color(0xFFE2E8F0),
            height: 1.0,
          ),
        ),
        title: const Text(
          'Danh mục',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1E293B),
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF475569)),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {},
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: CircleAvatar(
              backgroundColor: Color(0xFFFFDBCF),
              child: Text(
                'AM',
                style: TextStyle(
                  color: Color(0xFFE65100),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          )
        ],
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<CategoryBloc, CategoryState>(
            listenWhen: (previous, current) => current is CategoryLoaded && current.successMessage != null,
            listener: (context, state) {
              if (state is CategoryLoaded && state.successMessage != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.successMessage!),
                    backgroundColor: const Color(0xFF2E7D32),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
          ),
          BlocListener<CategoryBloc, CategoryState>(
            listenWhen: (previous, current) => current is CategoryError,
            listener: (context, state) {
              if (state is CategoryError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: const Color(0xFFD32F2F),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
          ),
        ],
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Quản lý Danh mục',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Quản lý các nhóm sản phẩm trong thực đơn và điểm bán',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed: _showAddCategory,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE65100),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 2,
                    ),
                    icon: const Icon(Icons.add, size: 20),
                    label: const Text(
                      'Thêm danh mục',
                      style: TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 24),

              // Filter Bar
              Container(
                height: 56,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextField(
                        controller: _searchController,
                        onSubmitted: (_) => _loadData(),
                        style: const TextStyle(fontSize: 13),
                        decoration: const InputDecoration(
                          hintText: 'Tìm kiếm danh mục...',
                          prefixIcon: Icon(Icons.search, size: 18, color: Color(0xFF94A3B8)),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                    Container(width: 1, height: 24, color: const Color(0xFFE2E8F0)),
                    const SizedBox(width: 16),
                    DropdownButton<bool?>(
                      value: _filterIsActive,
                      hint: const Text('Tất cả trạng thái', style: TextStyle(fontSize: 13)),
                      underline: const SizedBox(),
                      icon: const Icon(Icons.expand_more, size: 18, color: Color(0xFF94A3B8)),
                      style: const TextStyle(fontSize: 13, color: Color(0xFF1E293B), fontWeight: FontWeight.w500),
                      items: const [
                        DropdownMenuItem(value: null, child: Text('Tất cả trạng thái')),
                        DropdownMenuItem(value: true, child: Text('Đang hoạt động')),
                        DropdownMenuItem(value: false, child: Text('Ngừng hoạt động')),
                      ],
                      onChanged: (val) {
                        setState(() {
                          _filterIsActive = val;
                          _currentPage = 1;
                        });
                        _loadData();
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Data Table
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: BlocBuilder<CategoryBloc, CategoryState>(
                    builder: (context, state) {
                      if (state is CategoryLoading && state is! CategoryLoaded) {
                        return const Center(child: CircularProgressIndicator(color: Color(0xFFE65100)));
                      }

                      if (state is CategoryLoaded) {
                        if (state.categories.isEmpty) {
                          return const Center(
                            child: Text(
                              'Không có danh mục nào.',
                              style: TextStyle(color: Color(0xFF64748B)),
                            ),
                          );
                        }

                        return Column(
                          children: [
                            Expanded(
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width - 48),
                                  child: DataTable(
                                    headingRowColor: MaterialStateProperty.all(const Color(0xFFF8FAFC)),
                                    dataRowMinHeight: 64,
                                    dataRowMaxHeight: 64,
                                    columns: const [
                                      DataColumn(label: Text('TÊN DANH MỤC', style: _headerStyle)),
                                      DataColumn(label: Text('MÔ TẢ', style: _headerStyle)),
                                      DataColumn(label: Text('SỐ SẢN PHẨM', style: _headerStyle), numeric: true),
                                      DataColumn(label: Text('TRẠNG THÁI', style: _headerStyle)),
                                      DataColumn(label: Text('NGÀY TẠO', style: _headerStyle)),
                                      DataColumn(label: Text('HÀNH ĐỘNG', style: _headerStyle)),
                                    ],
                                    rows: state.categories.map((cat) {
                                      return DataRow(
                                        cells: [
                                          DataCell(
                                            Row(
                                              children: [
                                                Container(
                                                  width: 32,
                                                  height: 32,
                                                  decoration: BoxDecoration(
                                                    color: const Color(0xFFFFEDD5),
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                  alignment: Alignment.center,
                                                  child: Text(
                                                    cat.categoryName.isNotEmpty ? cat.categoryName[0].toUpperCase() : 'C',
                                                    style: const TextStyle(
                                                      color: Color(0xFFE65100),
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 12),
                                                Text(
                                                  cat.categoryName,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    color: Color(0xFF1E293B),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          DataCell(Text(
                                            cat.description ?? '',
                                            style: const TextStyle(color: Color(0xFF475569)),
                                          )),
                                          DataCell(Text(
                                            '${cat.productCount} sản phẩm',
                                            style: const TextStyle(fontWeight: FontWeight.w500, color: Color(0xFF334155)),
                                          )),
                                          DataCell(
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: cat.isActive ? const Color(0xFFECFDF5) : const Color(0xFFF1F5F9),
                                                border: Border.all(
                                                  color: cat.isActive ? const Color(0xFFA7F3D0) : const Color(0xFFE2E8F0),
                                                ),
                                                borderRadius: BorderRadius.circular(16),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Container(
                                                    width: 6,
                                                    height: 6,
                                                    decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      color: cat.isActive ? const Color(0xFF059669) : const Color(0xFF94A3B8),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 6),
                                                  Text(
                                                    cat.isActive ? 'Đang hoạt động' : 'Ngừng hoạt động',
                                                    style: TextStyle(
                                                      fontSize: 11,
                                                      fontWeight: FontWeight.w600,
                                                      color: cat.isActive ? const Color(0xFF065F46) : const Color(0xFF475569),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          DataCell(Text(
                                            cat.createdAt != null ? DateFormat('dd/MM/yyyy').format(cat.createdAt!) : '',
                                            style: const TextStyle(fontFamily: 'Inter', color: Color(0xFF64748B)),
                                          )),
                                          DataCell(
                                            Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                IconButton(
                                                  icon: const Icon(Icons.edit, color: Color(0xFFFFB300), size: 18),
                                                  onPressed: () => _showEditCategory(cat.id, cat.categoryName, cat.description, cat.isActive),
                                                ),
                                                IconButton(
                                                  icon: const Icon(Icons.delete_outline, color: Color(0xFFEF4444), size: 18),
                                                  onPressed: () => _showDeleteConfirm(cat.id, cat.categoryName),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ),
                            ),
                            // Footer pagination area
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: const BoxDecoration(
                                border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Trang $_currentPage',
                                    style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                                  ),
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.chevron_left, size: 20),
                                        onPressed: _currentPage > 1
                                            ? () {
                                                setState(() => _currentPage--);
                                                _loadData();
                                              }
                                            : null,
                                      ),
                                      const SizedBox(width: 8),
                                      IconButton(
                                        icon: const Icon(Icons.chevron_right, size: 20),
                                        onPressed: !state.isListEnd
                                            ? () {
                                                setState(() => _currentPage++);
                                                _loadData();
                                              }
                                            : null,
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            )
                          ],
                        );
                      }

                      return const SizedBox.shrink();
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

const TextStyle _headerStyle = TextStyle(
  fontFamily: 'Inter',
  fontSize: 12,
  fontWeight: FontWeight.bold,
  color: Color(0xFF64748B),
);
