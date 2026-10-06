import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'dart:io';
import '../../domain/entities/product_entity.dart';
import '../../data/models/product_request_model.dart';
import '../bloc/product_form_bloc.dart';
import '../bloc/product_form_event.dart';
import '../bloc/product_form_state.dart';
import '../bloc/product_admin_bloc.dart';
import '../bloc/product_admin_event.dart';
import '../../../../injection_container.dart' as di;
import '../../../categories/domain/usecases/manage_category_usecases.dart';
import '../../../categories/domain/entities/category_entity.dart';
import '../../../units/domain/usecases/manage_unit_usecases.dart';
import '../../../units/domain/entities/unit_entity.dart';

class ProductFormDialog extends StatefulWidget {
  final ProductEntity? product;
  const ProductFormDialog({Key? key, this.product}) : super(key: key);

  static void show(BuildContext context, {ProductEntity? product}) {
    showDialog(
      context: context,
      builder: (_) => BlocProvider.value(
        value: context.read<ProductFormBloc>(),
        child: ProductFormDialog(product: product),
      ),
    );
  }

  @override
  State<ProductFormDialog> createState() => _ProductFormDialogState();
}

class _ProductFormDialogState extends State<ProductFormDialog> {
  final _formKey = GlobalKey<FormState>();
  String name = '';
  String sku = '';
  double price = 0;
  int minStock = 0;
  String? selectedCategoryId;
  String? selectedUnitId;
  
  String? uploadedImageUrl;
  bool isUploading = false;

  List<CategoryEntity> categories = [];
  List<UnitEntity> units = [];
  bool isLoadingOptions = true;

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      name = widget.product!.name;
      sku = widget.product!.sku;
      price = widget.product!.price;
      minStock = widget.product!.minStockLevel;
      selectedCategoryId = widget.product!.categoryId;
      selectedUnitId = widget.product!.unitId;
      uploadedImageUrl = widget.product!.imageUrl;
    }
    _loadOptions();
  }

  Future<void> _loadOptions() async {
    final catRes = await di.sl<GetCategoriesUseCase>().call(pageSize: 100);
    final unitRes = await di.sl<GetUnitsUseCase>().call(pageSize: 100);

    setState(() {
      catRes.fold((_) {}, (list) => categories = list);
      unitRes.fold((_) {}, (list) => units = list);
      
      if (selectedCategoryId != null && !categories.any((c) => c.id.toString() == selectedCategoryId)) {
        selectedCategoryId = null;
      }
      if (selectedUnitId != null && !units.any((u) => u.id.toString() == selectedUnitId)) {
        selectedUnitId = null;
      }

      if (selectedCategoryId == null && categories.isNotEmpty) {
        selectedCategoryId = categories.first.id.toString();
      }
      if (selectedUnitId == null && units.isNotEmpty) {
        selectedUnitId = units.first.id.toString();
      }
      isLoadingOptions = false;
    });
  }

  Future<void> _pickAndUploadImage() async {
    try {
      PlatformFile? result = await FilePicker.pickFile(type: FileType.image);
      if (result != null) {
        setState(() => isUploading = true);
        
        FormData formData;
        if (result.path != null) {
          // Desktop/Mobile support
          formData = FormData.fromMap({
            "file": await MultipartFile.fromFile(result.path!, filename: result.name),
          });
        } else {
          // Web support
          final bytes = await result.readAsBytes();
          formData = FormData.fromMap({
            "file": MultipartFile.fromBytes(bytes, filename: result.name),
          });
        }

        final dio = di.sl<Dio>();
        final response = await dio.post('/api/upload/image', data: formData);
        
        if (response.statusCode == 200 && response.data != null && response.data['url'] != null) {
          setState(() {
            uploadedImageUrl = response.data['url'];
            isUploading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tải ảnh lên thành công')));
        } else {
          throw Exception('Failed to upload image');
        }
      }
    } catch (e) {
      setState(() => isUploading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi tải ảnh: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProductFormBloc, ProductFormState>(
      listener: (context, state) {
        if (state is ProductFormSuccess) {
          Navigator.of(context).pop();
          context.read<ProductAdminBloc>().add(const LoadProductsEvent());
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lưu thành công')));
        } else if (state is ProductFormError) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: 800,
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(widget.product == null ? 'Thêm sản phẩm mới' : 'Chỉnh sửa sản phẩm', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.of(context).pop()),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image upload
                    GestureDetector(
                      onTap: _pickAndUploadImage,
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: isUploading 
                          ? const Center(child: CircularProgressIndicator()) 
                          : uploadedImageUrl != null && uploadedImageUrl!.isNotEmpty
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(uploadedImageUrl!, fit: BoxFit.cover, errorBuilder: (_,__,___) => const Center(child: Icon(Icons.error))),
                              )
                            : const Center(child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.add_a_photo, size: 48, color: Colors.grey),
                                  SizedBox(height: 8),
                                  Text('Bấm để chọn ảnh', style: TextStyle(color: Colors.grey)),
                                ],
                              )),
                      ),
                    ),
                    const SizedBox(width: 24),
                    // Form fields
                    Expanded(
                      child: Column(
                        children: [
                          TextFormField(
                            initialValue: name,
                            decoration: const InputDecoration(labelText: 'Tên món / Sản phẩm', border: OutlineInputBorder()),
                            onSaved: (v) => name = v?.trim() ?? '',
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) return 'Vui lòng nhập tên';
                              final regex = RegExp(r'^[\p{L}0-9\s]+$', unicode: true);
                              if (!regex.hasMatch(v)) return 'Tên không chứa ký tự đặc biệt';
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            initialValue: sku,
                            decoration: const InputDecoration(labelText: 'Mã SKU', border: OutlineInputBorder()),
                            onSaved: (v) => sku = v?.trim() ?? '',
                            validator: (v) => (v == null || v.trim().isEmpty) ? 'Vui lòng nhập SKU' : null,
                          ),
                          const SizedBox(height: 16),
                          if (isLoadingOptions)
                            const Center(child: CircularProgressIndicator())
                          else
                            Row(
                              children: [
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    value: selectedCategoryId,
                                    decoration: const InputDecoration(labelText: 'Danh mục', border: OutlineInputBorder()),
                                    items: categories.map((c) => DropdownMenuItem(value: c.id.toString(), child: Text(c.categoryName))).toList(),
                                    onChanged: (v) => setState(() => selectedCategoryId = v),
                                    validator: (v) => v == null ? 'Chọn danh mục' : null,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    value: selectedUnitId,
                                    decoration: const InputDecoration(labelText: 'Đơn vị tính', border: OutlineInputBorder()),
                                    items: units.map((u) => DropdownMenuItem(value: u.id.toString(), child: Text(u.unitName))).toList(),
                                    onChanged: (v) => setState(() => selectedUnitId = v),
                                    validator: (v) => v == null ? 'Chọn đơn vị' : null,
                                  ),
                                ),
                              ],
                            ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  initialValue: price > 0 ? price.toString() : '',
                                  decoration: const InputDecoration(labelText: 'Giá niêm yết', border: OutlineInputBorder()),
                                  keyboardType: TextInputType.number,
                                  onSaved: (v) => price = double.tryParse(v ?? '0') ?? 0,
                                  validator: (v) {
                                    if (v == null || v.trim().isEmpty) return 'Không để trống';
                                    final val = double.tryParse(v);
                                    if (val == null) return 'Chỉ nhập số, không nhập chữ';
                                    if (val < 0) return 'Không nhập số âm';
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: TextFormField(
                                  initialValue: minStock > 0 ? minStock.toString() : '',
                                  decoration: const InputDecoration(labelText: 'Ngưỡng cảnh báo', border: OutlineInputBorder()),
                                  keyboardType: TextInputType.number,
                                  onSaved: (v) => minStock = int.tryParse(v ?? '0') ?? 0,
                                  validator: (v) {
                                    if (v == null || v.trim().isEmpty) return 'Không để trống';
                                    final val = int.tryParse(v);
                                    if (val == null) return 'Chỉ nhập số, không nhập chữ';
                                    if (val < 0) return 'Không nhập số âm';
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Hủy bỏ'),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();
                          final request = ProductRequestModel(
                            sku: sku,
                            name: name,
                            categoryId: selectedCategoryId ?? '1',
                            unitId: selectedUnitId ?? '1',
                            price: price,
                            minStockLevel: minStock,
                            isActive: widget.product?.isActive ?? true,
                            imageUrl: uploadedImageUrl,
                          );
                          context.read<ProductFormBloc>().add(SubmitProductFormEvent(
                            productId: widget.product?.id,
                            request: request,
                          ));
                        }
                      },
                      child: Text(widget.product == null ? 'Lưu món' : 'Cập nhật'),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
