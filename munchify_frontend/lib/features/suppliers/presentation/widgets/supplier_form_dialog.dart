import 'package:flutter/material.dart';
import '../../../../core/theme/AppTypography.dart';
import '../../../../injection_container.dart' as di;
import '../../../categories/domain/entities/category_entity.dart';
import '../../../categories/domain/usecases/manage_category_usecases.dart';
import '../../domain/entities/supplier_entity.dart';
import '../../../../core/widgets/app_toast.dart';

class SupplierFormDialog extends StatefulWidget {
  final SupplierEntity? supplier;
  final List<SupplierEntity>? existingSuppliers;
  final Function({
    required String supplierName,
    String? contactName,
    String? phone,
    String? address,
    bool? isActive,
    List<int>? categoryIds,
  }) onSave;

  const SupplierFormDialog({
    super.key,
    this.supplier,
    this.existingSuppliers,
    required this.onSave,
  });

  @override
  State<SupplierFormDialog> createState() => _SupplierFormDialogState();
}

class _SupplierFormDialogState extends State<SupplierFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _contactController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;
  late bool _isActive;
  late List<int> _selectedCategoryIds;

  List<CategoryEntity> _availableCategories = [];
  bool _isLoadingCategories = true;

  bool get isEdit => widget.supplier != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.supplier?.supplierName ?? '');
    _contactController = TextEditingController(text: widget.supplier?.contactName ?? '');
    _phoneController = TextEditingController(text: widget.supplier?.phone ?? '');
    _addressController = TextEditingController(text: widget.supplier?.address ?? '');
    _isActive = widget.supplier?.isActive ?? true;
    _selectedCategoryIds = List<int>.from(widget.supplier?.categoryIds ?? []);
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    try {
      final getCategories = di.sl<GetCategoriesUseCase>();
      final result = await getCategories();
      result.fold(
        (failure) => setState(() => _isLoadingCategories = false),
        (cats) => setState(() {
          _availableCategories = cats;
          _isLoadingCategories = false;
        }),
      );
    } catch (_) {
      if (mounted) setState(() => _isLoadingCategories = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _contactController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      if (_selectedCategoryIds.isEmpty) {
        AppToast.error('Vui lòng chọn ít nhất một danh mục ngành hàng cung ứng.', context: context);
        return;
      }

      widget.onSave(
        supplierName: _nameController.text.trim(),
        contactName: _contactController.text.trim().isEmpty ? null : _contactController.text.trim(),
        phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
        address: _addressController.text.trim().isEmpty ? null : _addressController.text.trim(),
        isActive: _isActive,
        categoryIds: _selectedCategoryIds,
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 580),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Modal Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
              decoration: const BoxDecoration(
                color: Color(0xFFFFFBF8),
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                border: Border(bottom: BorderSide(color: Color(0xFFFFEDD5))),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: isEdit ? const Color(0xFFFEF3C7) : const Color(0xFFFFEDD5),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      isEdit ? Icons.edit_note_rounded : Icons.add_circle_outline_rounded,
                      color: isEdit ? const Color(0xFFB45309) : const Color(0xFFE65100),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isEdit ? 'Cập Nhật Nhà Cung Cấp' : 'Thêm Nhà Cung Cấp Mới',
                          style: AppTypography.plusJakarta(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                        Text(
                          isEdit
                              ? 'Mã đối tác: NCC-${widget.supplier!.supplierId.toString().padLeft(3, '0')}'
                              : 'Nhập đầy đủ thông tin để lưu vào danh bạ Munchify POS',
                          style: AppTypography.inter(
                            fontSize: 12,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20, color: Color(0xFF94A3B8)),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // Modal Body
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('TÊN NHÀ CUNG CẤP', isRequired: true),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _nameController,
                        decoration: _inputDecoration('Ví dụ: Bánh Tráng Tân Tây Lộc'),
                        validator: (v) {
                          final val = v?.trim() ?? '';
                          if (val.isEmpty) {
                            return 'Vui lòng nhập tên nhà cung cấp';
                          }
                          if (val.length > 200) {
                            return 'Tên nhà cung cấp tối đa 200 ký tự';
                          }
                          // Bắt trùng tên nhà cung cấp
                          if (widget.existingSuppliers != null) {
                            final isDuplicate = widget.existingSuppliers!.any((s) {
                              final isSame = s.supplierName.trim().toLowerCase() == val.toLowerCase();
                              final isCurrent = widget.supplier != null && s.supplierId == widget.supplier!.supplierId;
                              return isSame && !isCurrent;
                            });
                            if (isDuplicate) {
                              return 'Tên nhà cung cấp này đã tồn tại';
                            }
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel('NGƯỜI ĐẠI DIỆN', isRequired: true),
                                const SizedBox(height: 6),
                                TextFormField(
                                  controller: _contactController,
                                  decoration: _inputDecoration('Ví dụ: Trần Văn Lộc'),
                                  validator: (v) {
                                    final val = v?.trim() ?? '';
                                    if (val.isEmpty) {
                                      return 'Vui lòng nhập người đại diện';
                                    }
                                    if (val.length > 200) {
                                      return 'Tên người đại diện tối đa 200 ký tự';
                                    }
                                    // Bắt trùng người đại diện
                                    if (widget.existingSuppliers != null) {
                                      final isDuplicate = widget.existingSuppliers!.any((s) {
                                        final isSame = (s.contactName?.trim().toLowerCase() ?? '') == val.toLowerCase();
                                        final isCurrent = widget.supplier != null && s.supplierId == widget.supplier!.supplierId;
                                        return isSame && !isCurrent;
                                      });
                                      if (isDuplicate) {
                                        return 'Người đại diện này đã tồn tại';
                                      }
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel('SỐ ĐIỆN THOẠI', isRequired: true),
                                const SizedBox(height: 6),
                                TextFormField(
                                  controller: _phoneController,
                                  decoration: _inputDecoration('0908123456'),
                                  keyboardType: TextInputType.phone,
                                  validator: (v) {
                                    final val = v?.trim() ?? '';
                                    if (val.isEmpty) {
                                      return 'Vui lòng nhập số điện thoại';
                                    }
                                    if (val.length > 200) {
                                      return 'Số điện thoại tối đa 200 ký tự';
                                    }
                                    // Bắt buộc phải là số
                                    final cleanPhone = val.replaceAll(RegExp(r'\s+'), '');
                                    final isNumeric = RegExp(r'^[0-9]+$').hasMatch(cleanPhone);
                                    if (!isNumeric) {
                                      return 'Số điện thoại chỉ được chứa chữ số';
                                    }
                                    // Bắt trùng số điện thoại
                                    if (widget.existingSuppliers != null) {
                                      final isDuplicate = widget.existingSuppliers!.any((s) {
                                        final sPhone = (s.phone?.replaceAll(RegExp(r'\s+'), '') ?? '');
                                        final isSame = sPhone == cleanPhone;
                                        final isCurrent = widget.supplier != null && s.supplierId == widget.supplier!.supplierId;
                                        return isSame && !isCurrent;
                                      });
                                      if (isDuplicate) {
                                        return 'Số điện thoại này đã tồn tại';
                                      }
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      _buildLabel('ĐỊA CHỈ KHO / TRỤ SỞ', isRequired: true),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _addressController,
                        decoration: _inputDecoration('Số nhà, đường, quận/huyện, tỉnh/thành'),
                        maxLines: 2,
                        validator: (v) {
                          final val = v?.trim() ?? '';
                          if (val.isEmpty) {
                            return 'Vui lòng nhập địa chỉ';
                          }
                          if (val.length > 200) {
                            return 'Địa chỉ tối đa 200 ký tự';
                          }
                          // Bắt trùng địa chỉ
                          if (widget.existingSuppliers != null) {
                            final isDuplicate = widget.existingSuppliers!.any((s) {
                              final isSame = (s.address?.trim().toLowerCase() ?? '') == val.toLowerCase();
                              final isCurrent = widget.supplier != null && s.supplierId == widget.supplier!.supplierId;
                              return isSame && !isCurrent;
                            });
                            if (isDuplicate) {
                              return 'Địa chỉ này đã tồn tại';
                            }
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // DANH MỤC HÀNG HÓA CUNG ỨNG (Option chọn gọn gàng)
                      _buildLabel('DANH MỤC NGÀNH HÀNG CUNG ỨNG', isRequired: true),
                      const SizedBox(height: 6),
                      if (_isLoadingCategories)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.0),
                          child: Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFE65100)),
                            ),
                          ),
                        )
                      else
                        DropdownButtonFormField<int>(
                          initialValue: _selectedCategoryIds.isNotEmpty && _availableCategories.any((c) => c.id == _selectedCategoryIds.first)
                              ? _selectedCategoryIds.first
                              : null,
                          isExpanded: true,
                          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF64748B)),
                          decoration: _inputDecoration('Chọn nhóm danh mục cung ứng'),
                          dropdownColor: Colors.white,
                          style: AppTypography.inter(fontSize: 13, color: const Color(0xFF1E293B), fontWeight: FontWeight.w500),
                          items: _availableCategories.map((cat) {
                            return DropdownMenuItem<int>(
                              value: cat.id,
                              child: Text(cat.categoryName),
                            );
                          }).toList(),
                          validator: (val) {
                            if (val == null) {
                              return 'Vui lòng chọn danh mục ngành hàng';
                            }
                            return null;
                          },
                          onChanged: (val) {
                            setState(() {
                              if (val != null) {
                                _selectedCategoryIds = [val];
                              }
                            });
                          },
                        ),
                      // Đã bỏ khung Switch Trạng thái (thay bằng thao tác Xóa mềm ở bảng danh sách)
                    ],
                  ),
                ),
              ),
            ),

            // Modal Footer
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: const BoxDecoration(
                color: Color(0xFFF8FAFC),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
                border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      side: const BorderSide(color: Color(0xFFCBD5E1)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: Text(
                      'Hủy bỏ',
                      style: AppTypography.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF475569),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE65100),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 0,
                    ),
                    child: Text(
                      isEdit ? 'Cập Nhật Thay Đổi' : 'Lưu Nhà Cung Cấp',
                      style: AppTypography.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text, {bool isRequired = false}) {
    return RichText(
      text: TextSpan(
        text: text,
        style: AppTypography.inter(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF475569),
          letterSpacing: 0.5,
        ),
        children: isRequired
            ? [
                const TextSpan(
                  text: ' *',
                  style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                )
              ]
            : [],
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: AppTypography.inter(fontSize: 13, color: const Color(0xFF94A3B8)),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFE65100), width: 1.5),
      ),
    );
  }
}
