import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/ColorPalette.dart';
import '../../../products/domain/entities/product_entity.dart';
import '../../domain/entities/promotion_entity.dart';
import '../bloc/promotion_form_bloc.dart';
import '../bloc/promotion_form_event.dart';
import '../bloc/promotion_form_state.dart';
import '../../../../core/widgets/app_toast.dart';

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
  List<ProductEntity> _allProducts = [];
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
        _selectedProductIds = _extractProductIds(detail.products);
      }
    }
    
    context.read<PromotionFormBloc>().add(const LoadPromotionProducts());
  }

  List<String> _extractProductIds(List<dynamic> products) {
    final result = <String>[];
    for (final item in products) {
      if (item is ProductEntity) {
        result.add(item.id);
      } else if (item is Map<String, dynamic>) {
        final id = item['productId'] ?? item['id'];
        if (id != null) {
          result.add(id.toString());
        }
      } else if (item is int || item is String) {
        result.add(item.toString());
      }
    }
    return result;
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
    
    final List<int> productIds = _scopeType == 0
        ? []
        : _selectedProductIds
            .map((id) => int.tryParse(id) ?? 0)
            .where((id) => id > 0)
            .toList();

    if (_scopeType == 1 && productIds.isEmpty) {
      AppToast.error(
        'Vui lòng chọn ít nhất một món áp dụng hoặc chuyển sang "Toàn bộ menu"',
        context: context,
      );
      return;
    }

    final Map<String, dynamic> data = {
      'promotionCode': _codeController.text.trim(),
      'promotionName': _nameController.text.trim(),
      'description': _descController.text.trim(),
      'discountType': _discountType,
      'discountValue': double.tryParse(_discountValueController.text.trim()) ?? 0,
      'minimumOrderAmount': double.tryParse(_minOrderController.text.trim()) ?? 0,
      'startDate': _startDate!.toIso8601String(),
      'endDate': _endDate!.toIso8601String(),
      'isActive': _isActive,
      'productIds': productIds,
    };

    context.read<PromotionFormBloc>().add(
      SubmitPromotionForm(id: widget.promotionToEdit?.promotionId.toString(), data: data),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PromotionFormBloc, PromotionFormState>(
      listener: (context, state) {
        if (state is PromotionFormSuccess) {
          AppToast.success('Lưu khuyến mãi thành công!', context: context);
          widget.onSuccess();
          Navigator.pop(context);
        } else if (state is PromotionFormError) {
          AppToast.error(state.message, context: context);
        } else if (state is PromotionFormValidationFailed) {
          AppToast.error(state.message, context: context);
        } else if (state is PromotionFormProductsLoading) {
          setState(() => _isLoadingProducts = true);
        } else if (state is PromotionFormProductsLoaded) {
          setState(() {
            _allProducts = state.products;
            _isLoadingProducts = false;
          });
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
                          readOnly: widget.promotionToEdit != null,
                          decoration: InputDecoration(
                            labelText: widget.promotionToEdit != null
                                ? 'Mã KM (Cố định)'
                                : 'Mã KM (Bỏ trống để tự tạo)',
                            border: const OutlineInputBorder(),
                            filled: widget.promotionToEdit != null,
                            fillColor: widget.promotionToEdit != null ? ColorPalette.webBgAdmin : null,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(labelText: 'Tên chương trình *', border: OutlineInputBorder()),
                          validator: (v) => (v == null || v.trim().isEmpty) ? 'Vui lòng nhập tên chương trình' : null,
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
                            DropdownMenuItem(value: 'FIXED_AMOUNT', child: Text('Theo số tiền (VNĐ)')),
                          ],
                          onChanged: (v) => setState(() => _discountType = v!),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _discountValueController,
                          decoration: InputDecoration(
                            labelText: _discountType == 'PERCENTAGE' ? 'Mức giảm (%) *' : 'Mức giảm (VNĐ) *',
                            border: const OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return 'Vui lòng nhập mức giảm';
                            final val = double.tryParse(v.trim());
                            if (val == null) return 'Giá trị không hợp lệ';
                            if (_discountType == 'PERCENTAGE') {
                              if (val <= 0 || val > 100) return 'Phần trăm giảm từ 1% đến 100%';
                            } else {
                              if (val <= 0) return 'Số tiền giảm phải lớn hơn 0';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _minOrderController,
                    decoration: const InputDecoration(labelText: 'Đơn hàng tối thiểu (VNĐ)', border: OutlineInputBorder()),
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      if (v != null && v.trim().isNotEmpty) {
                        final val = double.tryParse(v.trim());
                        if (val == null || val < 0) return 'Đơn hàng tối thiểu không được âm';
                      }
                      return null;
                    },
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
                                    if (checked == true) {
                                      _selectedProductIds.add(pid);
                                    } else {
                                      _selectedProductIds.remove(pid);
                                    }
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
