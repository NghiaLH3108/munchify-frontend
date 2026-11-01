import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/AppTypography.dart';
import '../../../../core/theme/ColorPalette.dart';
import '../../../../core/widgets/admin/admin_widgets.dart';
import '../../../../injection_container.dart' as di;
import '../../../categories/domain/entities/category_entity.dart';
import '../../../categories/domain/usecases/manage_category_usecases.dart';
import '../../domain/entities/supplier_entity.dart';
import '../bloc/supplier_bloc.dart';
import '../bloc/supplier_event.dart';
import '../bloc/supplier_state.dart';
import '../widgets/supplier_form_dialog.dart';

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
  static const int _pageSize = 8;
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
            search: _searchController.text.trim().isEmpty ? null : _searchController.text.trim(),
            isActive: _selectedStatus,
          ),
        );
  }

  void _openAddDialog() {
    final state = context.read<SupplierBloc>().state;
    final suppliers = state is SupplierLoaded ? state.suppliers : <SupplierEntity>[];

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
    final suppliers = state is SupplierLoaded ? state.suppliers : <SupplierEntity>[];

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

  @override
  Widget build(BuildContext context) {
    return BlocListener<SupplierBloc, SupplierState>(
      listener: (context, state) {
        if (state is SupplierActionSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Text(state.message),
                ],
              ),
              backgroundColor: const Color(0xFF059669),
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 3),
            ),
          );
        } else if (state is SupplierError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error_outline_rounded, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Expanded(child: Text(state.message)),
                ],
              ),
              backgroundColor: const Color(0xFFDC2626),
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: ColorPalette.webBgAdmin,
        body: BlocBuilder<SupplierBloc, SupplierState>(
          builder: (context, state) {
            List<SupplierEntity> allSuppliers = [];
            bool isLoading = false;

            if (state is SupplierLoading) {
              isLoading = true;
            } else if (state is SupplierLoaded) {
              allSuppliers = state.suppliers;
            }

            // Tính toán KPI Stats
            final totalSuppliers = allSuppliers.length;
            final activeSuppliers = allSuppliers.where((s) => s.isActive).length;
            final inactiveSuppliers = totalSuppliers - activeSuppliers;

            // Thu thập danh sách các nhóm ngành hàng (ưu tiên từ toàn bộ danh mục hệ thống)
            final availableCategories = _systemCategories.isNotEmpty
                ? _systemCategories.map((c) => c.categoryName).toList()
                : (allSuppliers.expand((s) => s.categoryNames).toSet().toList()..sort());

            // Lọc theo từ khóa, trạng thái và nhóm hàng
            final query = _searchController.text.trim().toLowerCase();
            final filteredList = allSuppliers.where((s) {
              final matchSearch = query.isEmpty ||
                  s.supplierName.toLowerCase().contains(query) ||
                  (s.contactName?.toLowerCase().contains(query) ?? false);
              final matchStatus = _selectedStatus == null || s.isActive == _selectedStatus;
              final matchCategory = _selectedCategory == null || s.categoryNames.contains(_selectedCategory);
              return matchSearch && matchStatus && matchCategory;
            }).toList();

            // Phân trang
            final totalPages = (filteredList.length / _pageSize).ceil().clamp(1, 999);
            if (_currentPage > totalPages) _currentPage = totalPages;
            final startIndex = (_currentPage - 1) * _pageSize;
            final endIndex = (startIndex + _pageSize).clamp(0, filteredList.length);
            final paginatedList = filteredList.sublist(startIndex, endIndex);

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Top Header (Sử dụng AdminPageHeader)
                  _buildHeader(),
                  const SizedBox(height: 20),
                  // Filter & Search Controls (Đưa lên trên KPI giống mẫu quản lý danh mục)
                  _buildFilterBar(availableCategories),
                  const SizedBox(height: 20),
                  // KPI Cards
                  _buildKpiStatsBar(totalSuppliers, activeSuppliers, inactiveSuppliers),
                  const SizedBox(height: 20),
                  // Data Table
                  _buildDataTableContainer(
                    paginatedList: paginatedList,
                    totalCount: filteredList.length,
                    startIndex: startIndex,
                    endIndex: endIndex,
                    totalPages: totalPages,
                    isLoading: isLoading,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ═══════════════════════════════════════════════════════════════════════════
  // 1. TOP HEADER (Sử dụng AdminPageHeader dùng chung)
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildHeader() {
    return AdminPageHeader(
      icon: Icons.local_shipping_rounded,
      title: 'Quản lý Nhà Cung Cấp',
      subtitle: 'Quản lý danh bạ đối tác cung ứng nguyên liệu & thực phẩm Munchify',
      addButtonText: 'Thêm Nhà Cung Cấp',
      onAddPressed: _openAddDialog,
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 2. KPI STATS CARDS (Sử dụng AdminKpiCard dùng chung)
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildKpiStatsBar(int total, int active, int inactive) {
    return LayoutBuilder(builder: (context, constraints) {
      final isWide = constraints.maxWidth >= 768;
      final cardWidth = isWide ? (constraints.maxWidth - 32) / 3 : constraints.maxWidth;

      return Wrap(
        spacing: 16,
        runSpacing: 16,
        children: [
          AdminKpiCard(
            width: cardWidth,
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
            width: cardWidth,
            title: 'ĐANG HỢP TÁC',
            value: active.toString(),
            valueColor: const Color(0xFF059669),
            subtitle: total > 0 ? 'Chiếm ${((active / total) * 100).toStringAsFixed(1)}% danh bạ' : 'Chiếm 0% danh bạ',
            subTextColor: const Color(0xFF64748B),
            icon: Icons.check_circle_outline_rounded,
            iconBg: const Color(0xFFECFDF5),
            iconColor: const Color(0xFF059669),
          ),
          AdminKpiCard(
            width: cardWidth,
            title: 'TẠM NGƯNG',
            value: inactive.toString(),
            valueColor: const Color(0xFF94A3B8),
            subtitle: 'Chưa kích hoạt cung ứng',
            subTextColor: const Color(0xFFD97706),
            icon: Icons.pause_circle_outline_rounded,
            iconBg: const Color(0xFFF1F5F9),
            iconColor: const Color(0xFF64748B),
          ),
        ],
      );
    });
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 3. FILTER & SEARCH CONTROLS (Sử dụng AdminFilterBar & AdminDropdownFilter)
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildFilterBar(List<String> categories) {
    return AdminFilterBar(
      searchController: _searchController,
      searchHint: 'Tìm kiếm theo tên nhà cung cấp...',
      onSearchChanged: (_) => setState(() => _currentPage = 1),
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
            const DropdownMenuItem(value: null, child: Text('Tất cả nhóm hàng')),
            ...categories.map((cat) => DropdownMenuItem(value: cat, child: Text(cat))),
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

  // ═══════════════════════════════════════════════════════════════════════════
  // 4. DATA TABLE & PAGINATION
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildDataTableContainer({
    required List<SupplierEntity> paginatedList,
    required int totalCount,
    required int startIndex,
    required int endIndex,
    required int totalPages,
    required bool isLoading,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFFEDD5).withValues(alpha: 0.9), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE65100).withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.015),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          children: [
            if (isLoading)
              const LinearProgressIndicator(
                backgroundColor: Color(0xFFFFEDD5),
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE65100)),
              ),

            // Table Header with warm gradient
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFFFFBF8), Color(0xFFFFF4EC)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                border: Border(bottom: BorderSide(color: Color(0xFFFFE0B2), width: 1.1)),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 50, child: Text('STT', textAlign: TextAlign.center, style: _headerStyle)),
                  const Expanded(
                    flex: 4,
                    child: Row(
                      children: [
                        SizedBox(width: 46), // Khoảng trống tương ứng kích thước avatar (36px) + khoảng cách (10px)
                        Expanded(child: Text('NHÀ CUNG CẤP', style: _headerStyle)),
                      ],
                    ),
                  ),
                  const Expanded(flex: 3, child: Text('NGƯỜI ĐẠI DIỆN', textAlign: TextAlign.center, style: _headerStyle)),
                  const Expanded(flex: 3, child: Text('NHÓM DANH MỤC', textAlign: TextAlign.center, style: _headerStyle)),
                  const Expanded(flex: 2, child: Text('TRẠNG THÁI', textAlign: TextAlign.center, style: _headerStyle)),
                  const SizedBox(width: 135, child: Text('THAO TÁC', textAlign: TextAlign.center, style: _headerStyle)),
                ],
              ),
            ),

          // Table Body
          if (paginatedList.isEmpty && !isLoading)
            Padding(
              padding: const EdgeInsets.all(48.0),
              child: Column(
                children: [
                  const Icon(Icons.inbox_rounded, size: 48, color: Color(0xFFCBD5E1)),
                  const SizedBox(height: 12),
                  Text(
                    'Không tìm thấy nhà cung cấp nào phù hợp.',
                    style: AppTypography.inter(fontSize: 14, color: const Color(0xFF64748B)),
                  ),
                ],
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: paginatedList.length,
              separatorBuilder: (_, _) => const Divider(height: 1, color: Color(0xFFF1F5F9)),
              itemBuilder: (context, index) {
                final supplier = paginatedList[index];
                final stt = (startIndex + index + 1).toString().padLeft(2, '0');
                final initials = supplier.supplierName.trim().isNotEmpty
                    ? supplier.supplierName.trim().split(' ').map((e) => e[0]).take(2).join('').toUpperCase()
                    : 'NC';

                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  color: index % 2 == 0 ? Colors.white : const Color(0xFFFAFAFA),
                  child: Row(
                    children: [
                      // STT
                      SizedBox(
                        width: 50,
                        child: Text(
                          stt,
                          textAlign: TextAlign.center,
                          style: AppTypography.inter(fontSize: 12, color: const Color(0xFF94A3B8)),
                        ),
                      ),

                      // Nhà cung cấp
                      Expanded(
                        flex: 4,
                        child: Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: index % 3 == 0
                                    ? const Color(0xFFFFEDD5)
                                    : (index % 3 == 1 ? const Color(0xFFFEF3C7) : const Color(0xFFDBEAFE)),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                initials,
                                style: AppTypography.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: index % 3 == 0
                                      ? const Color(0xFFE65100)
                                      : (index % 3 == 1 ? const Color(0xFFB45309) : const Color(0xFF1D4ED8)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
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
                                    style: AppTypography.inter(fontSize: 11, color: const Color(0xFF94A3B8)),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Người đại diện (Căn giữa)
                      Expanded(
                        flex: 3,
                        child: Text(
                          supplier.contactName ?? '---',
                          textAlign: TextAlign.center,
                          style: AppTypography.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF334155),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                      // Nhóm danh mục (Căn giữa)
                      Expanded(
                        flex: 3,
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFEDD5),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              supplier.categoryNames.isNotEmpty
                                  ? supplier.categoryNames.first
                                  : '---',
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

                      // Trạng thái (Căn giữa)
                      Expanded(
                        flex: 2,
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: supplier.isActive ? const Color(0xFFECFDF5) : const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: supplier.isActive ? const Color(0xFFA7F3D0) : const Color(0xFFCBD5E1),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: supplier.isActive ? const Color(0xFF10B981) : const Color(0xFF94A3B8),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  supplier.isActive ? 'Đang hợp tác' : 'Tạm ngưng',
                                  style: AppTypography.inter(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: supplier.isActive ? const Color(0xFF047857) : const Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Thao tác (Căn giữa)
                      SizedBox(
                        width: 135,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit_outlined, size: 18, color: Color(0xFFE65100)),
                              tooltip: 'Chỉnh sửa',
                              onPressed: () => _openEditDialog(supplier),
                            ),
                            const SizedBox(width: 4),
                            Tooltip(
                              message: supplier.isActive ? 'Tạm ngưng hợp tác (Xóa mềm)' : 'Kích hoạt lại hợp tác',
                              child: Transform.scale(
                                scale: 0.72,
                                child: Switch(
                                  value: supplier.isActive,
                                  activeThumbColor: const Color(0xFF10B981),
                                  activeTrackColor: const Color(0xFFA7F3D0),
                                  inactiveThumbColor: const Color(0xFF94A3B8),
                                  inactiveTrackColor: const Color(0xFFE2E8F0),
                                  onChanged: (_) => _toggleSupplierStatus(supplier),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

          // Pagination Footer
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
              border: Border(top: BorderSide(color: Color(0xFFF1F5F9))),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Hiển thị ${totalCount > 0 ? startIndex + 1 : 0} - $endIndex trong tổng số $totalCount nhà cung cấp',
                  style: AppTypography.inter(fontSize: 12, color: const Color(0xFF64748B)),
                ),
                Row(
                  children: [
                    OutlinedButton(
                      onPressed: _currentPage > 1 ? () => setState(() => _currentPage--) : null,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        side: const BorderSide(color: Color(0xFFE2E8F0)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Trước', style: TextStyle(fontSize: 12)),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE65100),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '$_currentPage / $totalPages',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton(
                      onPressed: _currentPage < totalPages ? () => setState(() => _currentPage++) : null,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        side: const BorderSide(color: Color(0xFFE2E8F0)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Sau', style: TextStyle(fontSize: 12)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      ),
    );
  }

  static const TextStyle _headerStyle = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    color: Color(0xFF64748B),
    letterSpacing: 0.5,
  );
}
