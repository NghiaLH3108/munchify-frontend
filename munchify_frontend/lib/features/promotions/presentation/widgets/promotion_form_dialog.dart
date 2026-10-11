import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/ColorPalette.dart';
import '../../../../injection_container.dart';
import '../../../products/domain/usecases/get_products_usecase.dart' as admin_products;
import '../../domain/entities/promotion_entity.dart';
import '../bloc/promotion_form_bloc.dart';
import '../bloc/promotion_form_event.dart';
import '../bloc/promotion_form_state.dart';

class PromotionFormDialog extends StatefulWidget {
  final PromotionEntity? promotionToEdit;
  final VoidCallback onSuccess;

  const PromotionFormDialog({super.key, this.promotionToEdit, required this.onSuccess});

  @override
  State<PromotionFormDialog> createState() => _PromotionFormDialogState();
}

class _PromotionFormDialogState extends State<PromotionFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _codeController;
  late TextEditingController _nameController;
  late TextEditingController _descController;
  late TextEditingController _discountValueController;
  late TextEditingController _minOrderController;
  
  DateTime? _startDate;
  DateTime? _endDate;
  String _discountType = 'PERCENTAGE';
  bool _isActive = true;

  int _scopeType = 0; // 0: Toàn bộ menu, 1: Món cụ thể
  List<dynamic> _allProducts = [];
  List<String> _selectedProductIds = [];
  bool _isLoadingProducts = false;

  @override
  void initState() {
    super.initState();
    _codeController = TextEditingController(text: widget.promotionToEdit?.promotionCode ?? '');
    _nameController = TextEditingController(text: widget.promotionToEdit?.promotionName ?? '');
    _descController = TextEditingController(text: widget.promotionToEdit?.description ?? '');
    _discountValueController = TextEditingController(text: widget.promotionToEdit?.discountValue.toString() ?? '');
    _minOrderController = TextEditingController(text: widget.promotionToEdit?.minimumOrderAmount.toString() ?? '0');
    _startDate = widget.promotionToEdit?.startDate ?? DateTime.now();
    _endDate = widget.promotionToEdit?.endDate ?? DateTime.now().add(const Duration(days: 7));
    _discountType = widget.promotionToEdit?.discountType ?? 'PERCENTAGE';
    _isActive = widget.promotionToEdit?.isActive ?? true;

    if (widget.promotionToEdit is PromotionDetailEntity) {
      final detail = widget.promotionToEdit as PromotionDetailEntity;
      if (detail.products.isNotEmpty) {
        _scopeType = 1;
        // Assuming products contain ids or are strings, mapping to String.
        _selectedProductIds = detail.products.map((e) => e.toString()).toList();
      }
    }
    
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() => _isLoadingProducts = true);
    final usecase = sl<admin_products.GetProductsUseCase>();
    final result = await usecase.call();
    result.fold(
      (l) => null,
      (r) {
        if (mounted) {
          setState(() {
            _allProducts = r;
          });
        }
      },
    );
    setState(() => _isLoadingProducts = false);
  }

  @override
  void dispose() {
    _codeController.dispose();
    _nameController.dispose();
    _descController.dispose();
    _discountValueController.dispose();
    _minOrderController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(bool isStart) async {
    final initialDate = isStart ? _startDate : _endDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
      if (!mounted) return;
      context.read<PromotionFormBloc>().add(ValidatePromotionForm(startDate: _startDate, endDate: _endDate));
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_startDate == null || _endDate == null) return;
    
    final Map<String, dynamic> data = {
      'promotionCode': _codeController.text,
      'promotionName': _nameController.text,
      'description': _descController.text,
      'discountType': _discountType,
      'discountValue': double.tryParse(_discountValueController.text) ?? 0,
      'minimumOrderAmount': double.tryParse(_minOrderController.text) ?? 0,
      'startDate': _startDate!.toIso8601String(),
      'endDate': _endDate!.toIso8601String(),
      'isActive': _isActive,
      'products': _scopeType == 0 ? [] : _selectedProductIds,
    };

    context.read<PromotionFormBloc>().add(
      SubmitPromotionForm(id: widget.promotionToEdit?.promotionId?.toString(), data: data),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PromotionFormBloc, PromotionFormState>(
      listener: (context, state) {
        if (state is PromotionFormSuccess) {
          widget.onSuccess();
          Navigator.pop(context);
        } else if (state is PromotionFormError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: ColorPalette.error),
          );
        } else if (state is PromotionFormValidationFailed) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: ColorPalette.error),
          );
        }
      },
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: 600,
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.promotionToEdit == null ? 'Thêm khuyến mãi mới' : 'Cập nhật khuyến mãi',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _codeController,
                          decoration: const InputDecoration(labelText: 'Mã KM (VD: TET2026)', border: OutlineInputBorder()),
                          validator: (v) => v!.isEmpty ? 'Vui lòng nhập' : null,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(labelText: 'Tên chương trình', border: OutlineInputBorder()),
                          validator: (v) => v!.isEmpty ? 'Vui lòng nhập' : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descController,
                    decoration: const InputDecoration(labelText: 'Mô tả', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: _discountType,
                          decoration: const InputDecoration(labelText: 'Loại giảm giá', border: OutlineInputBorder()),
                          items: const [
                            DropdownMenuItem(value: 'PERCENTAGE', child: Text('Theo %')),
                            DropdownMenuItem(value: 'FIXED_AMOUNT', child: Text('Theo số tiền (VND)')),
                          ],
                          onChanged: (v) => setState(() => _discountType = v!),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _discountValueController,
                          decoration: const InputDecoration(labelText: 'Mức giảm', border: OutlineInputBorder()),
                          keyboardType: TextInputType.number,
                          validator: (v) => v!.isEmpty ? 'Vui lòng nhập' : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _minOrderController,
                    decoration: const InputDecoration(labelText: 'Đơn hàng tối thiểu (VND)', border: OutlineInputBorder()),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () => _pickDate(true),
                          child: InputDecorator(
                            decoration: const InputDecoration(labelText: 'Ngày bắt đầu', border: OutlineInputBorder()),
                            child: Text(_startDate != null ? DateFormat('dd/MM/yyyy').format(_startDate!) : 'Chọn ngày'),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: InkWell(
                          onTap: () => _pickDate(false),
                          child: InputDecorator(
                            decoration: const InputDecoration(labelText: 'Ngày kết thúc', border: OutlineInputBorder()),
                            child: Text(_endDate != null ? DateFormat('dd/MM/yyyy').format(_endDate!) : 'Chọn ngày'),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Kích hoạt ngay'),
                    value: _isActive,
                    onChanged: (v) => setState(() => _isActive = v),
                    contentPadding: EdgeInsets.zero,
                  ),
                  const Divider(),
                  const Text('Phạm vi áp dụng', style: TextStyle(fontWeight: FontWeight.bold)),
                  Row(
                    children: [
                      Radio<int>(
                        value: 0,
                        groupValue: _scopeType,
                        onChanged: (v) => setState(() => _scopeType = v!),
                      ),
                      const Text('Toàn bộ menu'),
                      const SizedBox(width: 16),
                      Radio<int>(
                        value: 1,
                        groupValue: _scopeType,
                        onChanged: (v) => setState(() => _scopeType = v!),
                      ),
                      const Text('Món cụ thể'),
                    ],
                  ),
                  if (_scopeType == 1) ...[
                    const SizedBox(height: 8),
                    _isLoadingProducts 
                      ? const Center(child: CircularProgressIndicator())
                      : Container(
                          height: 150,
                          decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(4)),
                          child: ListView.builder(
                            itemCount: _allProducts.length,
                            itemBuilder: (ctx, idx) {
                              final p = _allProducts[idx];
                              final pid = p.id;
                              return CheckboxListTile(
                                title: Text(p.name),
                                value: _selectedProductIds.contains(pid),
                                onChanged: (checked) {
                                  setState(() {
                                    if (checked == true) _selectedProductIds.add(pid);
                                    else _selectedProductIds.remove(pid);
                                  });
                                },
                              );
                            },
                          ),
                        ),
                  ],
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Hủy'),
                      ),
                      const SizedBox(width: 16),
                      BlocBuilder<PromotionFormBloc, PromotionFormState>(
                        builder: (context, state) {
                          if (state is PromotionFormLoading) {
                            return const CircularProgressIndicator();
                          }
                          return ElevatedButton(
                            onPressed: _submit,
                            child: const Text('Lưu'),
                          );
                        },
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
