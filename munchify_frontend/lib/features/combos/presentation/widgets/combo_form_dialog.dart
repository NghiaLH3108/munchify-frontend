import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import '../../../../injection_container.dart' as di;
import '../../../../core/widgets/app_toast.dart';

import '../../../../core/theme/ColorPalette.dart';
import '../../domain/entities/combo_entity.dart';
import '../../domain/entities/combo_form_options_entity.dart';
import '../../domain/entities/combo_input.dart';

/// Submit callback: returns `null` on success, or an error message to display
/// inside the dialog (dialog stays open so the admin keeps their input).
typedef ComboSubmitCallback = Future<String?> Function(ComboInput input);

class _ComponentLine {
  final int productId;
  final String name;
  final String unitName;
  final double unitPrice;
  int quantity;

  _ComponentLine({
    required this.productId,
    required this.name,
    required this.unitName,
    required this.unitPrice,
    required this.quantity,
  });

  double get total => unitPrice * quantity;
}

class ComboFormDialog extends StatefulWidget {
  final ComboEntity? combo;
  final ComboFormOptionsEntity options;
  final ComboSubmitCallback onSubmit;

  const ComboFormDialog({
    super.key,
    this.combo,
    required this.options,
    required this.onSubmit,
  });

  @override
  State<ComboFormDialog> createState() => _ComboFormDialogState();
}

class _ComboFormDialogState extends State<ComboFormDialog> {
  static final NumberFormat _vnd =
      NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0);

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _codeCtrl;
  late final TextEditingController _discountCtrl;
  late final TextEditingController _imageCtrl;
  late final TextEditingController _descCtrl;
  final TextEditingController _searchCtrl = TextEditingController();

  bool _isActive = true;
  final List<_ComponentLine> _lines = [];

  bool _saving = false;
  String? _serverError;
  String? _itemsError;
  bool _isUploading = false;

  bool get _isEdit => widget.combo != null;

  @override
  void initState() {
    super.initState();
    final c = widget.combo;
    _nameCtrl = TextEditingController(text: c?.name);
    _codeCtrl = TextEditingController(text: c?.code);
    _imageCtrl = TextEditingController(text: c?.imageUrl);
    _descCtrl = TextEditingController(text: c?.description);
    _isActive = c?.isActive ?? true;

    double initialDiscount = 0;
    if (c != null && c.basePrice > 0) {
      initialDiscount = (1 - (c.price / c.basePrice)) * 100;
      if (initialDiscount < 0) initialDiscount = 0;
      if (initialDiscount > 100) initialDiscount = 100;
    }
    _discountCtrl = TextEditingController(
        text: c == null ? '0' : initialDiscount.toStringAsFixed(0));
    _discountCtrl.addListener(() => setState(() {}));

    if (c != null) {
      for (final item in c.items) {
        _lines.add(_ComponentLine(
          productId: item.componentProductId,
          name: item.componentProductName,
          unitName: item.unitName,
          unitPrice: item.unitPrice,
          quantity: item.quantity,
        ));
      }
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _codeCtrl.dispose();
    _discountCtrl.dispose();
    _imageCtrl.dispose();
    _descCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  double get _discountPercent => double.tryParse(_discountCtrl.text.trim()) ?? 0;
  double get _retailTotal => _lines.fold(0.0, (s, l) => s + l.total);
  double get _comboPrice => _retailTotal * (1 - (_discountPercent / 100));

  Future<void> _pickAndUploadImage() async {
    try {
      PlatformFile? result = await FilePicker.pickFile(type: FileType.image);
      if (result != null) {
        setState(() => _isUploading = true);

        FormData formData;
        if (result.path != null) {
          formData = FormData.fromMap({
            "file": await MultipartFile.fromFile(
              result.path!,
              filename: result.name,
            ),
          });
        } else {
          final bytes = await result.readAsBytes();
          formData = FormData.fromMap({
            "file": MultipartFile.fromBytes(bytes, filename: result.name),
          });
        }

        final dio = di.sl<Dio>();
        final response = await dio.post('/api/upload/image', data: formData);

        if (response.statusCode == 200 &&
            response.data != null &&
            response.data['url'] != null) {
          setState(() {
            _imageCtrl.text = response.data['url'];
            _isUploading = false;
          });
        } else {
          throw Exception('Failed to upload image');
        }
      }
    } catch (e) {
      setState(() => _isUploading = false);
      if (mounted) {
        AppToast.error('Lỗi tải ảnh: $e', context: context);
      }
    }
  }

  void _addProduct(ComponentProductEntity p) {
    setState(() {
      _lines.add(_ComponentLine(
        productId: p.id,
        name: p.name,
        unitName: p.unitName,
        unitPrice: p.price,
        quantity: 1,
      ));
      _itemsError = null;
    });
  }

  Future<void> _submit() async {
    final formOk = _formKey.currentState!.validate();
    if (_lines.isEmpty) {
      setState(() => _itemsError = 'Combo cần ít nhất 1 sản phẩm thành phần');
    }
    if (!formOk || _lines.isEmpty) return;

    final input = ComboInput(
      code: _codeCtrl.text.trim().isEmpty ? null : _codeCtrl.text.trim(),
      name: _nameCtrl.text.trim(),
      description:
          _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
      price: _comboPrice,
      imageUrl:
          _imageCtrl.text.trim().isEmpty ? null : _imageCtrl.text.trim(),
      isActive: _isActive,
      items: _lines
          .map((l) => ComboItemInput(
              componentProductId: l.productId, quantity: l.quantity))
          .toList(),
    );

    setState(() {
      _saving = true;
      _serverError = null;
    });
    final error = await widget.onSubmit(input);
    if (!mounted) return;
    if (error == null) {
      Navigator.of(context).pop(true);
    } else {
      setState(() {
        _saving = false;
        _serverError = error;
      });
    }
  }

  InputDecoration _decoration(String hint, {String? prefix}) {
    OutlineInputBorder border(Color color, [double width = 1]) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: color, width: width),
        );
    return InputDecoration(
      hintText: hint,
      prefixText: prefix,
      hintStyle: const TextStyle(
          fontFamily: 'Inter', fontSize: 13, color: Color(0xFF94A3B8)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: border(ColorPalette.borderSubtle),
      enabledBorder: border(ColorPalette.borderSubtle),
      focusedBorder: border(ColorPalette.appetizingOrange, 2),
      errorBorder: border(ColorPalette.dangerCrimson),
      focusedErrorBorder: border(ColorPalette.dangerCrimson, 2),
    );
  }

  Widget _label(String text, {bool required = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: RichText(
        text: TextSpan(
          text: text,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1E293B),
          ),
          children: [
            if (required)
              const TextSpan(
                text: ' *',
                style: TextStyle(color: ColorPalette.dangerCrimson),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.of(context).size.height * 0.9;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.all(24),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 820, maxHeight: maxHeight),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(),
            const Divider(height: 1, color: ColorPalette.borderSubtle),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_serverError != null) _buildErrorBanner(_serverError!),
                      _buildInfoSection(),
                      const SizedBox(height: 24),
                      _buildComponentsSection(),
                    ],
                  ),
                ),
              ),
            ),
            const Divider(height: 1, color: ColorPalette.borderSubtle),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: ColorPalette.appetizingOrange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              _isEdit ? Icons.edit_rounded : Icons.add_rounded,
              color: ColorPalette.appetizingOrange,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _isEdit ? 'Cập nhật combo' : 'Thêm combo mới',
              style: const TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Color(0xFF94A3B8)),
            onPressed: _saving ? null : () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorBanner(String message) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ColorPalette.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: ColorPalette.error.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded,
              color: ColorPalette.error, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                  fontFamily: 'Inter', fontSize: 13, color: ColorPalette.error),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection() {
    Widget twoCols(Widget a, Widget b) => LayoutBuilder(
          builder: (context, c) {
            if (c.maxWidth < 560) {
              return Column(children: [a, const SizedBox(height: 16), b]);
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: a),
                const SizedBox(width: 16),
                Expanded(child: b),
              ],
            );
          },
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        twoCols(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _label('Tên combo', required: true),
              TextFormField(
                controller: _nameCtrl,
                decoration: _decoration('Ví dụ: Combo Ăn Vặt No Say'),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Tên combo không được để trống';
                  }
                  if (v.trim().length > 200) return 'Tối đa 200 ký tự';
                  return null;
                },
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _label('Mã combo'),
              TextFormField(
                controller: _codeCtrl,
                decoration: _decoration(
                    _isEdit ? 'Mã combo' : 'Để trống để tự động tạo (CB-xxxxxx)'),
                validator: (v) =>
                    (v != null && v.trim().length > 50) ? 'Tối đa 50 ký tự' : null,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        twoCols(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _label('Giảm giá (%)', required: true),
              TextFormField(
                controller: _discountCtrl,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: _decoration('0'),
                validator: (v) {
                  final value = double.tryParse((v ?? '').trim());
                  if (value == null || value < 0 || value > 100) {
                    return 'Giảm giá phải từ 0 - 100%';
                  }
                  return null;
                },
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _label('Ảnh combo'),
              GestureDetector(
                onTap: _isUploading ? null : _pickAndUploadImage,
                child: Container(
                  height: 120,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: ColorPalette.borderSubtle),
                  ),
                  child: _isUploading
                      ? const Center(
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: ColorPalette.appetizingOrange,
                            ),
                          ),
                        )
                      : _imageCtrl.text.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  Image.network(
                                    _imageCtrl.text,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => const Center(
                                      child: Icon(Icons.broken_image_rounded,
                                          size: 32, color: ColorPalette.textMuted),
                                    ),
                                  ),
                                  Positioned(
                                    top: 4,
                                    right: 4,
                                    child: InkWell(
                                      onTap: () => setState(() => _imageCtrl.clear()),
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: Colors.black54,
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: const Icon(Icons.close, size: 14, color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : const Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.cloud_upload_outlined,
                                      size: 28, color: ColorPalette.textMuted),
                                  SizedBox(height: 4),
                                  Text('Nhấn để tải ảnh lên',
                                      style: TextStyle(
                                          fontSize: 11,
                                          color: ColorPalette.textMuted)),
                                ],
                              ),
                            ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _label('Mô tả'),
        TextFormField(
          controller: _descCtrl,
          maxLines: 2,
          decoration: _decoration('Mô tả ngắn về combo...'),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            border: Border.all(color: ColorPalette.borderSubtle),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Trạng thái bán',
                        style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1E293B))),
                    SizedBox(height: 2),
                    Text('Combo đang bán sẽ hiển thị cho nhân viên tại quầy POS',
                        style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                            color: ColorPalette.textMuted)),
                  ],
                ),
              ),
              Switch(
                value: _isActive,
                activeThumbColor: ColorPalette.appetizingOrange,
                onChanged: (v) => setState(() => _isActive = v),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildComponentsSection() {
    final selectedIds = _lines.map((e) => e.productId).toSet();
    final query = _searchCtrl.text.trim().toLowerCase();
    final available = widget.options.products.where((p) {
      if (selectedIds.contains(p.id)) return false;
      if (query.isEmpty) return true;
      return p.name.toLowerCase().contains(query) ||
          p.code.toLowerCase().contains(query);
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.inventory_2_outlined,
                size: 18, color: ColorPalette.appetizingOrange),
            const SizedBox(width: 8),
            const Text(
              'Sản phẩm thành phần',
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            const Text(' *',
                style: TextStyle(color: ColorPalette.dangerCrimson)),
          ],
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, c) {
            final picker = _buildPicker(available);
            final selected = _buildSelectedList();
            if (c.maxWidth < 640) {
              return Column(children: [picker, const SizedBox(height: 16), selected]);
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: picker),
                const SizedBox(width: 16),
                Expanded(child: selected),
              ],
            );
          },
        ),
        if (_itemsError != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(_itemsError!,
                style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    color: ColorPalette.dangerCrimson)),
          ),
        const SizedBox(height: 16),
        _buildPriceSummary(),
      ],
    );
  }

  Widget _buildPicker(List<ComponentProductEntity> available) {
    return Container(
      height: 280,
      decoration: BoxDecoration(
        border: Border.all(color: ColorPalette.borderSubtle),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (_) => setState(() {}),
              style: const TextStyle(fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Tìm sản phẩm đơn...',
                prefixIcon: const Icon(Icons.search_rounded, size: 18),
                isDense: true,
                filled: true,
                fillColor: ColorPalette.webBgAdmin.withValues(alpha: 0.7),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const Divider(height: 1, color: ColorPalette.borderSubtle),
          Expanded(
            child: available.isEmpty
                ? const Center(
                    child: Text('Không còn sản phẩm phù hợp',
                        style: TextStyle(
                            fontSize: 12, color: ColorPalette.textMuted)),
                  )
                : ListView.separated(
                    itemCount: available.length,
                    separatorBuilder: (_, __) => const Divider(
                        height: 1, color: ColorPalette.borderSubtle),
                    itemBuilder: (context, i) {
                      final p = available[i];
                      return InkWell(
                        onTap: () => _addProduct(p),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(p.name,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                            fontFamily: 'Inter',
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600)),
                                    Text(
                                        '${p.code} · ${_vnd.format(p.price)} / ${p.unitName}',
                                        style: const TextStyle(
                                            fontSize: 11,
                                            color: ColorPalette.textMuted)),
                                  ],
                                ),
                              ),
                              const Icon(Icons.add_circle_rounded,
                                  color: ColorPalette.appetizingOrange,
                                  size: 24),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedList() {
    return Container(
      height: 280,
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBF7),
        border: Border.all(
            color: _itemsError != null
                ? ColorPalette.dangerCrimson
                : ColorPalette.borderSubtle),
        borderRadius: BorderRadius.circular(12),
      ),
      child: _lines.isEmpty
          ? const Center(
              child: Text('Chưa chọn sản phẩm nào',
                  style:
                      TextStyle(fontSize: 12, color: ColorPalette.textMuted)),
            )
          : ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 4),
              itemCount: _lines.length,
              separatorBuilder: (_, __) =>
                  const Divider(height: 1, color: ColorPalette.borderSubtle),
              itemBuilder: (context, i) {
                final l = _lines[i];
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(l.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600)),
                            Text(_vnd.format(l.total),
                                style: const TextStyle(
                                    fontSize: 11,
                                    color: ColorPalette.textMuted)),
                          ],
                        ),
                      ),
                      _qtyButton(Icons.remove_rounded, () {
                        if (l.quantity > 1) setState(() => l.quantity--);
                      }),
                      SizedBox(
                        width: 32,
                        child: Text('${l.quantity}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w700)),
                      ),
                      _qtyButton(Icons.add_rounded, () {
                        if (l.quantity < 1000) setState(() => l.quantity++);
                      }),
                      IconButton(
                        tooltip: 'Bỏ sản phẩm',
                        icon: const Icon(Icons.delete_outline_rounded,
                            size: 20, color: ColorPalette.dangerCrimson),
                        onPressed: () => setState(() => _lines.removeAt(i)),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Widget _qtyButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          border: Border.all(color: ColorPalette.borderSubtle),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 16),
      ),
    );
  }

  Widget _buildPriceSummary() {
    final retail = _retailTotal;
    final price = _comboPrice;
    final saving = retail - price;
    final hasPrice = price > 0 && _lines.isNotEmpty;
    final isLoss = hasPrice && saving <= 0;

    Widget cell(String label, String value, {Color? color}) => Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      fontSize: 11, color: ColorPalette.textMuted)),
              const SizedBox(height: 2),
              Text(value,
                  style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: color ?? const Color(0xFF1E293B))),
            ],
          ),
        );

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isLoss
            ? ColorPalette.warning.withValues(alpha: 0.08)
            : ColorPalette.amberTint,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isLoss
              ? ColorPalette.warning.withValues(alpha: 0.4)
              : ColorPalette.appetizingOrange.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              cell('Tổng giá mua lẻ', _vnd.format(retail)),
              cell('Giá bán combo', _vnd.format(price),
                  color: ColorPalette.appetizingOrange),
              cell(
                'Khách tiết kiệm',
                hasPrice ? _vnd.format(saving > 0 ? saving : 0) : '—',
                color: ColorPalette.success,
              ),
            ],
          ),
          if (isLoss) ...[
            const SizedBox(height: 8),
            const Row(
              children: [
                Icon(Icons.warning_amber_rounded,
                    size: 16, color: ColorPalette.warning),
                SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Giá combo không thấp hơn tổng giá mua lẻ — khách sẽ không được ưu đãi.',
                    style: TextStyle(fontSize: 12, color: ColorPalette.warning),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: const BoxDecoration(
        color: Color(0xFFF8FAFC),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: _saving ? null : () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF475569),
              minimumSize: const Size(48, 48),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: ColorPalette.borderSubtle),
              ),
            ),
            child: const Text('Hủy'),
          ),
          const SizedBox(width: 12),
          ElevatedButton.icon(
            onPressed: _saving ? null : _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorPalette.appetizingOrange,
              foregroundColor: Colors.white,
              minimumSize: const Size(48, 48),
              padding: const EdgeInsets.symmetric(horizontal: 22),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: _saving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                : Icon(_isEdit ? Icons.save_rounded : Icons.add_rounded,
                    size: 18),
            label: Text(_isEdit ? 'Lưu thay đổi' : 'Thêm mới'),
          ),
        ],
      ),
    );
  }
}
