import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/ColorPalette.dart';
import '../../../../core/theme/AppTypography.dart';
import '../bloc/stock_movement_bloc.dart';
import '../bloc/stock_movement_event.dart';
import '../bloc/stock_movement_state.dart';
import '../../domain/entities/stock_movement_entity.dart';

class StockMovementHistoryScreen extends StatefulWidget {
  const StockMovementHistoryScreen({super.key});

  @override
  State<StockMovementHistoryScreen> createState() => _StockMovementHistoryScreenState();
}

class _StockMovementHistoryScreenState extends State<StockMovementHistoryScreen> {
  String? _selectedType;
  DateTime? _selectedFrom;
  DateTime? _selectedTo;
  final TextEditingController _productIdController = TextEditingController();

  final List<Map<String, String>> _movementTypes = [
    {'id': 'ALL', 'name': 'Tất cả'},
    {'id': 'IMPORT', 'name': 'Nhập kho'},
    {'id': 'SALE', 'name': 'Xuất bán'},
    {'id': 'COMBO_SALE', 'name': 'Xuất bán combo'},
    {'id': 'ADJUSTMENT', 'name': 'Điều chỉnh'},
    {'id': 'DAMAGE', 'name': 'Xuất hủy'}
  ];

  @override
  void initState() {
    super.initState();
    _applyFilters();
  }

  @override
  void dispose() {
    _productIdController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    int? productId = int.tryParse(_productIdController.text);
    context.read<StockMovementBloc>().add(LoadStockMovements(
          movementType: _selectedType == 'ALL' ? null : _selectedType,
          productId: productId,
          from: _selectedFrom,
          to: _selectedTo,
        ));
  }

  void _loadNextPage() {
    context.read<StockMovementBloc>().add(LoadNextPage());
  }

  Future<void> _selectDate(BuildContext context, bool isFrom) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: ColorPalette.primaryContainer,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isFrom) {
          _selectedFrom = picked;
        } else {
          _selectedTo = picked;
        }
      });
      _applyFilters();
    }
  }

  void _showAdjustStockDialog(BuildContext context) {
    final productIdController = TextEditingController();
    final quantityController = TextEditingController();
    final reasonController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    String selectedMovementType = 'ADJUSTMENT';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Điều chỉnh tồn kho'),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      value: selectedMovementType,
                      decoration: const InputDecoration(labelText: 'Loại điều chỉnh'),
                      items: const [
                        DropdownMenuItem(value: 'ADJUSTMENT', child: Text('Điều chỉnh (ADJUSTMENT)')),
                        DropdownMenuItem(value: 'DAMAGE', child: Text('Xuất hủy (DAMAGE)')),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            selectedMovementType = value;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: productIdController,
                      decoration: const InputDecoration(labelText: 'ID Sản phẩm'),
                      keyboardType: TextInputType.number,
                      validator: (value) => value == null || value.isEmpty ? 'Không được để trống' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: quantityController,
                      decoration: const InputDecoration(labelText: 'Số lượng thay đổi (VD: 10, -5)'),
                      keyboardType: const TextInputType.numberWithOptions(signed: true),
                      validator: (value) => value == null || value.isEmpty ? 'Không được để trống' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: reasonController,
                      decoration: const InputDecoration(labelText: 'Lý do điều chỉnh'),
                      validator: (value) => value == null || value.isEmpty ? 'Không được để trống' : null,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Hủy'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      context.read<StockMovementBloc>().add(AdjustStockEvent(
                        productId: int.parse(productIdController.text),
                        quantityChange: int.parse(quantityController.text),
                        reason: reasonController.text,
                        movementType: selectedMovementType,
                      ));
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Xác nhận'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorPalette.webBgAdmin,
      body: BlocConsumer<StockMovementBloc, StockMovementState>(
        listener: (context, state) {
          if (state is StockMovementError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: ColorPalette.error,
              ),
            );
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildPageTitleBar(context),
                const SizedBox(height: 24),
                _buildTableCard(context, state),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPageTitleBar(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Lịch sử xuất/nhập kho',
                    style: AppTypography.plusJakarta(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: ColorPalette.onSurfaceDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tra cứu chi tiết các biến động về số lượng tồn kho của sản phẩm.',
                    style: AppTypography.inter(
                      fontSize: 13,
                      color: ColorPalette.textMuted,
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  OutlinedButton.icon(
                    onPressed: () => _applyFilters(),
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    label: const Text('Làm mới'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: () => _showAdjustStockDialog(context),
                    icon: const Icon(Icons.tune_rounded, size: 18),
                    label: const Text('Điều chỉnh kho'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorPalette.primaryContainer,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 18),
          _buildFilterToolbar(context),
        ],
      ),
    );
  }

  Widget _buildFilterToolbar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: ColorPalette.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ColorPalette.borderSubtle),
      ),
      child: Wrap(
        spacing: 16,
        runSpacing: 12,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          // Pills for movement types
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _movementTypes.map((type) {
              final isSelected = (_selectedType ?? 'ALL') == type['id'];
              return _buildPillFilter(
                label: type['name']!,
                isActive: isSelected,
                onTap: () {
                  setState(() => _selectedType = type['id']);
                  _applyFilters();
                },
              );
            }).toList(),
          ),
          Container(width: 1, height: 24, color: ColorPalette.borderSubtle),
          // Product ID Search
          SizedBox(
            width: 150,
            height: 36,
            child: TextField(
              controller: _productIdController,
              keyboardType: TextInputType.number,
              style: const TextStyle(fontSize: 13),
              decoration: InputDecoration(
                hintText: 'ID Sản phẩm...',
                hintStyle: const TextStyle(fontSize: 12, color: ColorPalette.textMuted),
                prefixIcon: const Icon(Icons.search_rounded, size: 16, color: ColorPalette.textMuted),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                filled: true,
                fillColor: ColorPalette.webBgAdmin.withValues(alpha: 0.6),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
              onSubmitted: (_) => _applyFilters(),
            ),
          ),
          // Dates
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDateButton(
                label: _selectedFrom != null ? DateFormat('dd/MM/yyyy').format(_selectedFrom!) : 'Từ ngày',
                onTap: () => _selectDate(context, true),
              ),
              const SizedBox(width: 8),
              const Text('-', style: TextStyle(color: ColorPalette.textMuted)),
              const SizedBox(width: 8),
              _buildDateButton(
                label: _selectedTo != null ? DateFormat('dd/MM/yyyy').format(_selectedTo!) : 'Đến ngày',
                onTap: () => _selectDate(context, false),
              ),
              if (_selectedFrom != null || _selectedTo != null) ...[
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.clear, size: 16),
                  onPressed: () {
                    setState(() {
                      _selectedFrom = null;
                      _selectedTo = null;
                    });
                    _applyFilters();
                  },
                  tooltip: 'Xóa ngày',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                )
              ]
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateButton({required String label, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: ColorPalette.borderSubtle),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_rounded, size: 14, color: ColorPalette.textMuted),
            const SizedBox(width: 6),
            Text(label, style: const TextStyle(fontSize: 12, color: ColorPalette.textPrimary)),
          ],
        ),
      ),
    );
  }

  Widget _buildPillFilter({
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isActive ? ColorPalette.appetizingOrange : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? ColorPalette.appetizingOrange : ColorPalette.borderSubtle,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isActive ? Colors.white : ColorPalette.textMuted,
          ),
        ),
      ),
    );
  }

  Widget _buildTableCard(BuildContext context, StockMovementState state) {
    List<StockMovementEntity> items = [];
    bool hasReachedMax = false;
    
    if (state is StockMovementLoaded) {
      items = state.movements;
      hasReachedMax = state.hasReachedMax;
    }

    return Container(
      decoration: BoxDecoration(
        color: ColorPalette.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ColorPalette.borderSubtle),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
            child: Row(
              children: [
                Text(
                  'Danh sách giao dịch',
                  style: AppTypography.plusJakarta(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: ColorPalette.onSurfaceDark,
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: ColorPalette.primaryFixed,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${items.length} mục',
                    style: AppTypography.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: ColorPalette.primaryContainer,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: ColorPalette.borderSubtle),
          
          if (state is StockMovementInitial || (state is StockMovementLoading && items.isEmpty))
            const Padding(
              padding: EdgeInsets.all(40.0),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (items.isEmpty)
            Container(
              padding: const EdgeInsets.all(40),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.inventory_2_outlined, size: 60, color: ColorPalette.textMuted.withValues(alpha: 0.5)),
                    const SizedBox(height: 16),
                    const Text('Không có dữ liệu phù hợp', style: TextStyle(color: ColorPalette.textMuted, fontSize: 16)),
                  ],
                ),
              ),
            )
          else
            LayoutBuilder(
              builder: (context, constraints) {
                final effectiveWidth = math.max(920.0, constraints.maxWidth);
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: effectiveWidth,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildProportionalTableHeader(),
                        ...items.asMap().entries.map((e) {
                          return _buildProportionalTableRow(context, e.value, e.key + 1);
                        }),
                      ],
                    ),
                  ),
                );
              },
            ),
            
          const Divider(height: 1, color: ColorPalette.borderSubtle),
          if (!hasReachedMax && items.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: TextButton.icon(
                  onPressed: (state is StockMovementLoading) ? null : _loadNextPage,
                  icon: (state is StockMovementLoading) 
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.arrow_downward_rounded, size: 16),
                  label: const Text('Tải thêm'),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProportionalTableHeader() {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: ColorPalette.webBgAdmin.withValues(alpha: 0.8),
        border: const Border(bottom: BorderSide(color: ColorPalette.borderSubtle)),
      ),
      child: const Row(
        children: [
          SizedBox(width: 44, child: Text('#', style: AppTypography.tableHeader)),
          SizedBox(width: 12),
          Expanded(flex: 3, child: Text('SẢN PHẨM', style: AppTypography.tableHeader)),
          Expanded(flex: 2, child: Text('THỜI GIAN', style: AppTypography.tableHeader)),
          Expanded(flex: 2, child: Text('NGHIỆP VỤ', style: AppTypography.tableHeader)),
          Expanded(flex: 3, child: Text('DIỄN GIẢI', style: AppTypography.tableHeader)),
          SizedBox(width: 120, child: Text('SỐ LƯỢNG', textAlign: TextAlign.right, style: AppTypography.tableHeader)),
        ],
      ),
    );
  }

  Widget _buildProportionalTableRow(BuildContext context, StockMovementEntity movement, int index) {
    Color iconColor;
    IconData iconData;
    String typeLabel;

    switch (movement.movementType) {
      case 'IMPORT':
        iconData = Icons.add_box_rounded;
        iconColor = ColorPalette.success;
        typeLabel = 'Nhập kho';
        break;
      case 'SALE':
      case 'COMBO_SALE':
        iconData = Icons.shopping_cart_checkout_rounded;
        iconColor = ColorPalette.dangerCrimson;
        typeLabel = 'Xuất bán';
        break;
      case 'ADJUSTMENT':
        iconData = Icons.tune_rounded;
        iconColor = ColorPalette.warningTangerine;
        typeLabel = 'Điều chỉnh';
        break;
      case 'DAMAGE':
        iconData = Icons.broken_image_rounded;
        iconColor = ColorPalette.textMuted;
        typeLabel = 'Xuất hủy';
        break;
      default:
        iconData = Icons.swap_horiz_rounded;
        iconColor = ColorPalette.tertiary;
        typeLabel = movement.movementType;
    }

    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: ColorPalette.borderSubtle, width: 0.5)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 44,
            child: Text(
              '$index',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: ColorPalette.textMuted),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 3,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  movement.productName,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: ColorPalette.textPrimary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'ID: ${movement.productId}',
                  style: const TextStyle(fontSize: 11, color: ColorPalette.textMuted),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat('dd/MM/yyyy').format(movement.createdAt),
                  style: const TextStyle(fontSize: 12, color: ColorPalette.textPrimary),
                ),
                Text(
                  DateFormat('HH:mm').format(movement.createdAt),
                  style: const TextStyle(fontSize: 11, color: ColorPalette.textMuted),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Row(
              children: [
                Icon(iconData, size: 16, color: iconColor),
                const SizedBox(width: 6),
                Text(
                  typeLabel,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: iconColor),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  movement.reason?.isNotEmpty == true ? movement.reason! : 'Không có ghi chú',
                  style: TextStyle(
                    fontSize: 12,
                    color: movement.reason?.isNotEmpty == true ? ColorPalette.textPrimary : ColorPalette.textMuted,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Bởi: ${movement.staffName}',
                  style: const TextStyle(fontSize: 11, color: ColorPalette.textMuted),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 120,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${movement.quantity > 0 ? '+' : ''}${movement.quantity}',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: movement.quantity > 0 ? ColorPalette.success : ColorPalette.dangerCrimson,
                  ),
                ),
                Text(
                  'Tồn: ${movement.newQuantity}',
                  style: const TextStyle(fontSize: 11, color: ColorPalette.textMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
