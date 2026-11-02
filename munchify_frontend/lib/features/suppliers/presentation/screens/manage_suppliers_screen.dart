import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/AppTypography.dart';
import '../../../../core/theme/ColorPalette.dart';
import '../../../../core/widgets/admin/admin_widgets.dart';
import '../../../../core/widgets/app_pagination_bar.dart';
import '../../../../injection_container.dart' as di;
import '../../../categories/domain/entities/category_entity.dart';
import '../../../categories/domain/usecases/manage_category_usecases.dart';
import '../../domain/entities/supplier_entity.dart';
import '../bloc/supplier_bloc.dart';
import '../bloc/supplier_event.dart';
import '../bloc/supplier_state.dart';
import '../widgets/supplier_form_dialog.dart';
import '../../../../core/widgets/app_toast.dart';

class ManageSuppliersScreen extends StatefulWidget {
  final bool embedInShell;

  const ManageSuppliersScreen({super.key, this.embedInShell = false});

  @override
  State<ManageSuppliersScreen> createState() => _ManageSuppliersScreenState();
}

class _ManageSuppliersScreenState extends State<ManageSuppliersScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool? _selectedStatus; // null: Tất cả, true: Đang hợp tác, false: Tạm ngưng
  String? _selectedCategory; // null: Tất cả nhóm hàng
  int _currentPage = 1;
  static const int _pageSize = 10;
  List<CategoryEntity> _systemCategories = [];

  @override
  void initState() {
    super.initState();
    _loadSuppliers();
    _loadSystemCategories();
  }

  Future<void> _loadSystemCategories() async {
    try {
      final getCategories = di.sl<GetCategoriesUseCase>();
      final result = await getCategories(pageSize: 50);
      result.fold(
        (_) {},
        (cats) {
          if (mounted) setState(() => _systemCategories = cats);
        },
      );
    } catch (_) {}
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadSuppliers() {
    context.read<SupplierBloc>().add(
          LoadSuppliersEvent(
            search: _searchController.text.trim().isEmpty
                ? null
                : _searchController.text.trim(),
            isActive: _selectedStatus,
          ),
        );
  }

  void _openAddDialog() {
    final state = context.read<SupplierBloc>().state;
    final suppliers =
        state is SupplierLoaded ? state.suppliers : <SupplierEntity>[];

    showDialog(
      context: context,
      builder: (_) => SupplierFormDialog(
        existingSuppliers: suppliers,
        onSave: ({
          required String supplierName,
          String? contactName,
          String? phone,
          String? address,
          bool? isActive,
          List<int>? categoryIds,
        }) {
          context.read<SupplierBloc>().add(
                CreateSupplierEvent(
                  supplierName: supplierName,
                  contactName: contactName,
                  phone: phone,
                  address: address,
                  isActive: isActive,
                  categoryIds: categoryIds,
                ),
              );
        },
      ),
    );
  }

  void _openEditDialog(SupplierEntity supplier) {
    final state = context.read<SupplierBloc>().state;
    final suppliers =
        state is SupplierLoaded ? state.suppliers : <SupplierEntity>[];

    showDialog(
      context: context,
      builder: (_) => SupplierFormDialog(
        supplier: supplier,
        existingSuppliers: suppliers,
        onSave: ({
          required String supplierName,
          String? contactName,
          String? phone,
          String? address,
          bool? isActive,
          List<int>? categoryIds,
        }) {
          context.read<SupplierBloc>().add(
                UpdateSupplierEvent(
                  id: supplier.supplierId,
                  supplierName: supplierName,
                  contactName: contactName,
                  phone: phone,
                  address: address,
                  isActive: isActive,
                  categoryIds: categoryIds,
                ),
              );
        },
      ),
    );
  }

  void _toggleSupplierStatus(SupplierEntity supplier) {
    context.read<SupplierBloc>().add(
          UpdateSupplierEvent(
            id: supplier.supplierId,
            supplierName: supplier.supplierName,
            contactName: supplier.contactName,
            phone: supplier.phone,
            address: supplier.address,
            isActive: !supplier.isActive,
            categoryIds: supplier.categoryIds,
          ),
        );
  }

  String _initialsFor(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return 'NC';
    return trimmed
        .split(RegExp(r'\s+'))
        .where((e) => e.isNotEmpty)
        .map((e) => e[0])
        .take(2)
        .join('')
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SupplierBloc, SupplierState>(
      listener: (context, state) {
        if (state is SupplierActionSuccess) {
          AppToast.success(
            state.message,
            context: context,
            duration: const Duration(seconds: 3),
          );
        } else if (state is SupplierError) {
          AppToast.error(
            state.message,
            context: context,
            duration: const Duration(seconds: 4),
          );
        }
      },
      builder: (context, state) {
        List<SupplierEntity> allSuppliers = [];
        bool isLoading = false;

        if (state is SupplierLoading) {
          isLoading = true;
        } else if (state is SupplierLoaded) {
          allSuppliers = state.suppliers;
        }

        final totalSuppliers = allSuppliers.length;
        final activeSuppliers = allSuppliers.where((s) => s.isActive).length;
        final inactiveSuppliers = totalSuppliers - activeSuppliers;

        final availableCategories = _systemCategories.isNotEmpty
            ? _systemCategories.map((c) => c.categoryName).toList()
            : (allSuppliers.expand((s) => s.categoryNames).toSet().toList()
              ..sort());

        final query = _searchController.text.trim().toLowerCase();
        final filteredList = allSuppliers.where((s) {
          final matchSearch = query.isEmpty ||
              s.supplierName.toLowerCase().contains(query) ||
              (s.contactName?.toLowerCase().contains(query) ?? false);
          final matchStatus =
              _selectedStatus == null || s.isActive == _selectedStatus;
          final matchCategory = _selectedCategory == null ||
              s.categoryNames.contains(_selectedCategory);
          return matchSearch && matchStatus && matchCategory;
        }).toList();

        final totalPages =
            (filteredList.length / _pageSize).ceil().clamp(1, 999);
        if (_currentPage > totalPages) _currentPage = totalPages;
        final startIndex = (_currentPage - 1) * _pageSize;
        final endIndex =
            (startIndex + _pageSize).clamp(0, filteredList.length);
        final paginatedList = filteredList.sublist(startIndex, endIndex);

        return AdminListScaffold(
          embedInShell: widget.embedInShell,
          stickyHeader: AdminStickyHeader(
            breadcrumb: 'Nhà cung cấp',
            onRefresh: _loadSuppliers,
          ),
          header: AdminPageHeader(
            icon: Icons.local_shipping_rounded,
            title: 'Quản lý Nhà Cung Cấp',
            subtitle:
                'Quản lý danh bạ đối tác cung ứng nguyên liệu & thực phẩm Munchify',
            addButtonText: 'Thêm Nhà Cung Cấp',
            onAddPressed: _openAddDialog,
          ),
          filterBar: _buildFilterBar(availableCategories),
          kpiCards: _buildKpiCards(
            totalSuppliers,
            activeSuppliers,
            inactiveSuppliers,
          ),
          table: _buildTable(
            paginatedList: paginatedList,
            totalCount: filteredList.length,
            startIndex: startIndex,
            endIndex: endIndex,
            totalPages: totalPages,
            isLoading: isLoading,
          ),
        );
      },
    );
  }

  List<Widget> _buildKpiCards(int total, int active, int inactive) {
    return [
      AdminKpiCard(
        title: 'TỔNG ĐỐI TÁC',
        value: total.toString(),
        subtitle: '+3 đối tác quý này',
        subTextColor: const Color(0xFF059669),
        showTrendIcon: true,
        icon: Icons.store_rounded,
        iconBg: const Color(0xFFFFF7ED),
        iconColor: const Color(0xFFE65100),
      ),
      AdminKpiCard(
        title: 'ĐANG HỢP TÁC',
        value: active.toString(),
        valueColor: const Color(0xFF059669),
        subtitle: total > 0
            ? 'Chiếm ${((active / total) * 100).toStringAsFixed(1)}% danh bạ'
            : 'Chiếm 0% danh bạ',
        subTextColor: const Color(0xFF64748B),
        icon: Icons.check_circle_outline_rounded,
        iconBg: const Color(0xFFECFDF5),
        iconColor: const Color(0xFF059669),
      ),
      AdminKpiCard(
        title: 'TẠM NGƯNG',
        value: inactive.toString(),
        valueColor: const Color(0xFF94A3B8),
        subtitle: 'Chưa kích hoạt cung ứng',
        subTextColor: const Color(0xFFD97706),
        icon: Icons.pause_circle_outline_rounded,
        iconBg: const Color(0xFFF1F5F9),
        iconColor: const Color(0xFF64748B),
        isWarning: inactive > 0,
      ),
    ];
  }

  Widget _buildFilterBar(List<String> categories) {
    return AdminFilterBar(
      searchController: _searchController,
      searchHint: 'Tìm kiếm theo tên nhà cung cấp...',
      onSearchChanged: (_) => setState(() => _currentPage = 1),
      onClearSearch: () => setState(() => _currentPage = 1),
      filters: [
        AdminDropdownFilter<bool?>(
          value: _selectedStatus,
          items: const [
            DropdownMenuItem(value: null, child: Text('Tất cả trạng thái')),
            DropdownMenuItem(value: true, child: Text('Đang hợp tác')),
            DropdownMenuItem(value: false, child: Text('Tạm ngưng')),
          ],
          onChanged: (val) {
            setState(() {
              _selectedStatus = val;
              _currentPage = 1;
            });
            _loadSuppliers();
          },
        ),
        AdminDropdownFilter<String?>(
          value: _selectedCategory,
          items: [
            const DropdownMenuItem(
              value: null,
              child: Text('Tất cả nhóm hàng'),
            ),
            ...categories.map(
              (cat) => DropdownMenuItem(value: cat, child: Text(cat)),
            ),
          ],
          onChanged: (val) {
            setState(() {
              _selectedCategory = val;
              _currentPage = 1;
            });
          },
        ),
      ],
    );
  }

  Widget _buildTable({
    required List<SupplierEntity> paginatedList,
    required int totalCount,
    required int startIndex,
    required int endIndex,
    required int totalPages,
    required bool isLoading,
  }) {
    return AdminDataTable<SupplierEntity>(
      title: 'Danh sách nhà cung cấp',
      countLabel: '$totalCount đối tác',
      subtitle: 'Hiển thị trang $_currentPage / $totalPages.',
      items: paginatedList,
      indexOffset: startIndex,
      isRefreshing: isLoading,
      onRowTap: _openEditDialog,
      emptyState: const AdminEmptyState(
        icon: Icons.inbox_rounded,
        title: 'Không tìm thấy nhà cung cấp nào phù hợp.',
      ),
      columns: [
        AdminTableColumn.index<SupplierEntity>(),
        AdminTableColumn(
          label: 'NHÀ CUNG CẤP',
          flex: 4,
          cellBuilder: (_, supplier, index) {
            final initials = _initialsFor(supplier.supplierName);
            final mod = index % 3;
            final bg = mod == 0
                ? const Color(0xFFFFEDD5)
                : (mod == 1
                    ? const Color(0xFFFEF3C7)
                    : const Color(0xFFDBEAFE));
            final fg = mod == 0
                ? const Color(0xFFE65100)
                : (mod == 1
                    ? const Color(0xFFB45309)
                    : const Color(0xFF1D4ED8));
            return Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: bg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    initials,
                    style: AppTypography.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: fg,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        supplier.supplierName,
                        style: AppTypography.plusJakarta(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF0F172A),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Mã: NCC-${supplier.supplierId.toString().padLeft(3, '0')}',
                        style: AppTypography.inter(
                          fontSize: 11,
                          color: const Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
        AdminTableColumn(
          label: 'NGƯỜI ĐẠI DIỆN',
          flex: 3,
          cellBuilder: (_, supplier, _) => Text(
            supplier.contactName ?? '—',
            style: AppTypography.inter(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF334155),
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        AdminTableColumn(
          label: 'NHÓM DANH MỤC',
          flex: 3,
          cellBuilder: (_, supplier, _) => Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFFFEDD5),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                supplier.categoryNames.isNotEmpty
                    ? supplier.categoryNames.first
                    : '—',
                style: AppTypography.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFC2410C),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
        AdminTableColumn(
          label: 'TRẠNG THÁI',
          flex: 3,
          cellBuilder: (_, supplier, _) => FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Switch(
                  value: supplier.isActive,
                  activeTrackColor: ColorPalette.success.withValues(alpha: 0.3),
                  activeThumbColor: ColorPalette.success,
                  inactiveTrackColor:
                      ColorPalette.error.withValues(alpha: 0.15),
                  inactiveThumbColor: ColorPalette.error.withValues(alpha: 0.6),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  onChanged: (_) => _toggleSupplierStatus(supplier),
                ),
                const SizedBox(width: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: supplier.isActive
                        ? ColorPalette.success.withValues(alpha: 0.08)
                        : ColorPalette.error.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    supplier.isActive ? 'Đang hợp tác' : 'Tạm ngưng',
                    style: AppTypography.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: supplier.isActive
                          ? ColorPalette.success
                          : ColorPalette.error,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        AdminTableColumn(
          label: 'THAO TÁC',
          width: 80,
          align: TextAlign.right,
          cellBuilder: (_, supplier, _) => Align(
            alignment: Alignment.centerRight,
            child: AdminRowActionButton(
              icon: Icons.edit_outlined,
              color: ColorPalette.appetizingOrange,
              tooltip: 'Chỉnh sửa',
              onPressed: () => _openEditDialog(supplier),
            ),
          ),
        ),
      ],
      pagination: AppPaginationBar(
        currentPage: _currentPage,
        totalPages: totalPages,
        totalCount: totalCount,
        itemLabel: 'nhà cung cấp',
        startIndex: totalCount > 0 ? startIndex + 1 : 0,
        endIndex: endIndex,
        onPageChanged: (page) => setState(() => _currentPage = page),
      ),
    );
  }
}
