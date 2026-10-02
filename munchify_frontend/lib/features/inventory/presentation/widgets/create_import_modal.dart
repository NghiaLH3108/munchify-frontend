import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../bloc/stock_import_bloc.dart';
import '../bloc/stock_import_event.dart';
import '../../../../../core/theme/ColorPalette.dart';
import '../../../../../core/constants/ApiEndpoints.dart';
import '../../../../../injection_container.dart' as di;
import 'package:dio/dio.dart';

class CreateImportModal extends StatefulWidget {
  const CreateImportModal({super.key});

  @override
  State<CreateImportModal> createState() => _CreateImportModalState();
}

class _CreateImportModalState extends State<CreateImportModal> {
  int? _selectedSupplierId;
  final TextEditingController _notesController = TextEditingController();
  bool _isLoading = true;
  
  List<Map<String, dynamic>> _availableProducts = [];
  List<Map<String, dynamic>> _availableSuppliers = [];

  final List<Map<String, dynamic>> _selectedItems = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final dio = di.sl<Dio>();
      final suppliersRes = await dio.get(ApiEndpoints.suppliers);
      
      setState(() {
        _availableSuppliers = List<Map<String, dynamic>>.from(suppliersRes.data['data'] ?? []);
        
        if (_availableSuppliers.isNotEmpty) {
          _selectedSupplierId = _availableSuppliers[0]['supplierId'] ?? _availableSuppliers[0]['id'];
        }
      });

      if (_selectedSupplierId != null) {
        await _fetchProductsForSupplier(_selectedSupplierId!);
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint('Error fetching data: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchProductsForSupplier(int supplierId) async {
    try {
      setState(() => _isLoading = true);
      final dio = di.sl<Dio>();
      final productsRes = await dio.get('${ApiEndpoints.productsForStock}?supplierId=$supplierId');
      
      setState(() {
        _availableProducts = List<Map<String, dynamic>>.from(productsRes.data['data'] ?? []);
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error fetching products: $e');
      setState(() => _isLoading = false);
    }
  }

  void _addItem(Map<String, dynamic> product) {
    setState(() {
      final pId = product['productId'] ?? product['id'];
      final existingIndex = _selectedItems.indexWhere((item) => item['productId'] == pId);
      if (existingIndex >= 0) {
        _selectedItems[existingIndex]['quantity'] += 1;
      } else {
        _selectedItems.add({
          'productId': pId,
          'productName': product['productName'] ?? product['name'],
          'sku': product['sku'] ?? 'N/A',
          'unitName': product['unitName'] ?? product['unit'] ?? 'Item',
          'quantity': 1,
          'importPrice': product['costPrice'] ?? product['price'] ?? 0,
        });
      }
    });
  }

  void _removeItem(int index) {
    setState(() {
      _selectedItems.removeAt(index);
    });
  }

  void _showProductSelection() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          backgroundColor: Colors.white,
          child: SizedBox(
            width: 600,
            height: 550,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Chọn sản phẩm',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text('Nhấn vào sản phẩm để thêm vào phiếu nhập', style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.black87),
                        onPressed: () => Navigator.of(context).pop(),
                        style: IconButton.styleFrom(backgroundColor: Colors.grey.shade100),
                      ),
                    ],
                  ),
                ),
                Divider(height: 1, color: Colors.grey.shade200),
                
                // Body List
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(24),
                    itemCount: _availableProducts.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final p = _availableProducts[index];
                      final pName = p['productName'] ?? p['name'] ?? 'Sản phẩm chưa có tên';
                      final pSku = p['sku'] ?? 'N/A';
                      final pPrice = p['costPrice'] ?? p['price'] ?? 0;
                      
                      return InkWell(
                        onTap: () {
                          _addItem(p);
                          Navigator.of(context).pop();
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: Colors.grey.shade200),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x08000000),
                                blurRadius: 8,
                                offset: Offset(0, 2),
                              )
                            ]
                          ),
                          child: Row(
                            children: [
                              // Product Icon/Image placeholder
                              Container(
                                width: 52,
                                height: 52,
                                decoration: BoxDecoration(
                                  color: Colors.orange.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.inventory_2_rounded, color: ColorPalette.appetizingOrange, size: 28),
                              ),
                              const SizedBox(width: 16),
                              
                              // Info
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      pName,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade100,
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            'SKU: $pSku',
                                            style: TextStyle(fontSize: 12, color: Colors.grey.shade700, fontWeight: FontWeight.w600),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          NumberFormat.currency(locale: 'vi_VN', symbol: 'đ', decimalDigits: 0).format(pPrice),
                                          style: const TextStyle(fontWeight: FontWeight.w700, color: ColorPalette.appetizingOrange, fontSize: 14),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              
                              // Add button
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.orange.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.all(8),
                                child: const Icon(Icons.add_shopping_cart, color: ColorPalette.appetizingOrange, size: 20),
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  double _calculateTotal() {
    double total = 0;
    for (var item in _selectedItems) {
      total += (item['quantity'] * item['importPrice']);
    }
    return total;
  }

  void _submitDraft() {
    if (_selectedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn ít nhất 1 mặt hàng', style: TextStyle(color: Colors.white)), backgroundColor: Colors.red),
      );
      return;
    }

    if (_selectedSupplierId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn nhà cung cấp', style: TextStyle(color: Colors.white)), backgroundColor: Colors.red),
      );
      return;
    }

    context.read<StockImportBloc>().add(
      CreateDraftImportEvent(
        supplierId: _selectedSupplierId!,
        notes: _notesController.text,
        items: _selectedItems.map((item) => {
          'productId': item['productId'],
          'quantity': item['quantity'],
          'importPrice': item['importPrice'],
        }).toList(),
      ),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.white,
      child: Container(
        width: 1000,
        height: 850,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Tạo Phiếu Nhập Kho', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text('Điền thông tin nhà cung cấp và mặt hàng cần nhập vào kho', style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                    style: IconButton.styleFrom(backgroundColor: Colors.grey.shade100),
                  )
                ],
              ),
            ),
            
            _isLoading ? const Expanded(child: Center(child: CircularProgressIndicator())) : Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Supplier Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        RichText(
                          text: TextSpan(
                            text: 'Nhà Cung Cấp ',
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: Colors.black),
                            children: const [
                              TextSpan(text: '*', style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('Thêm nhà cung cấp mới'),
                          style: TextButton.styleFrom(foregroundColor: Colors.blue.shade700),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade200),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          value: _selectedSupplierId,
                          isExpanded: true,
                          icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey.shade600),
                          onChanged: (int? newValue) {
                            if (newValue != null && newValue != _selectedSupplierId) {
                              setState(() {
                                _selectedSupplierId = newValue;
                                _selectedItems.clear(); // Xoá danh sách sản phẩm đã chọn khi đổi nhà cung cấp
                              });
                              _fetchProductsForSupplier(newValue);
                            }
                          },
                          items: _availableSuppliers.map<DropdownMenuItem<int>>((supplier) {
                            final sId = supplier['supplierId'] ?? supplier['id'];
                            return DropdownMenuItem<int>(
                              value: sId,
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.orange.shade50,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(Icons.storefront, color: ColorPalette.appetizingOrange),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text('${supplier['supplierName'] ?? supplier['name']} - SĐT: ${supplier['phone'] ?? ''}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                                        const SizedBox(height: 4),
                                        Text('Địa chỉ: ${supplier['address'] ?? ''}', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    // Products Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Text('Danh sách sản phẩm nhập', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(16)),
                              child: Text('${_selectedItems.length} mặt hàng', style: TextStyle(color: Colors.grey.shade700, fontSize: 12)),
                            ),
                          ],
                        ),
                        Container(
                          width: 400,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.search, color: Colors.grey.shade500, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextField(
                                  decoration: InputDecoration(
                                    hintText: 'Tìm & thêm sản phẩm theo tên hoặc mã SKU...',
                                    hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(4)),
                                child: Text('F2', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Table items
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade200),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          // Table Header
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF9FAFB),
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                              border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
                            ),
                            child: Row(
                              children: [
                                Expanded(flex: 1, child: Text('STT', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey.shade700, fontSize: 13))),
                                Expanded(flex: 4, child: Text('Tên sản phẩm', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey.shade700, fontSize: 13))),
                                Expanded(flex: 2, child: Center(child: Text('Đơn vị', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey.shade700, fontSize: 13)))),
                                Expanded(flex: 2, child: Center(child: Text('Số lượng', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey.shade700, fontSize: 13)))),
                                Expanded(flex: 3, child: Align(alignment: Alignment.centerRight, child: Text('Giá nhập (đ)', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey.shade700, fontSize: 13)))),
                                Expanded(flex: 3, child: Align(alignment: Alignment.centerRight, child: Text('Thành tiền (đ)', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey.shade700, fontSize: 13)))),
                                Expanded(flex: 1, child: Align(alignment: Alignment.center, child: Text('Xóa', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey.shade700, fontSize: 13)))),
                              ],
                            ),
                          ),
                          // Table Items
                          ..._selectedItems.asMap().entries.map((entry) {
                            int index = entry.key;
                            var item = entry.value;
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              decoration: BoxDecoration(
                                border: index != _selectedItems.length - 1 ? Border(bottom: BorderSide(color: Colors.grey.shade100)) : null,
                              ),
                              child: Row(
                                children: [
                                  Expanded(flex: 1, child: Text('${index + 1}', style: TextStyle(color: Colors.grey.shade600, fontSize: 14))),
                                  Expanded(
                                    flex: 4, 
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(item['productName'], style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                                        const SizedBox(height: 4),
                                        Text('SKU: ${item['sku']}', style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                                      ],
                                    ),
                                  ),
                                  Expanded(flex: 2, child: Center(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                      decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(12)),
                                      child: Text(item['unitName'], style: TextStyle(fontSize: 12, color: Colors.grey.shade700, fontWeight: FontWeight.w500)),
                                    ),
                                  )),
                                  Expanded(
                                    flex: 2, 
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF3F4F6),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Row(
                                          children: [
                                            InkWell(
                                              onTap: () {
                                                if (item['quantity'] > 1) {
                                                  setState(() => item['quantity'] -= 1);
                                                }
                                              },
                                              child: const Padding(
                                                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                                child: Icon(Icons.remove, size: 16, color: Colors.black54),
                                              ),
                                            ),
                                            Expanded(
                                              child: TextField(
                                                controller: TextEditingController(text: item['quantity'].toString())
                                                  ..selection = TextSelection.collapsed(offset: item['quantity'].toString().length),
                                                textAlign: TextAlign.center,
                                                keyboardType: TextInputType.number,
                                                decoration: const InputDecoration(
                                                  contentPadding: EdgeInsets.zero,
                                                  isDense: true,
                                                  border: InputBorder.none,
                                                ),
                                                style: const TextStyle(fontWeight: FontWeight.w500),
                                                onChanged: (val) {
                                                  final newVal = int.tryParse(val);
                                                  if (newVal != null) {
                                                    setState(() => item['quantity'] = newVal);
                                                  }
                                                },
                                              ),
                                            ),
                                            InkWell(
                                              onTap: () {
                                                setState(() => item['quantity'] += 1);
                                              },
                                              child: const Padding(
                                                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                                child: Icon(Icons.add, size: 16, color: Colors.black54),
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    )
                                  ),
                                  Expanded(
                                    flex: 3, 
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 8.0),
                                      child: TextFormField(
                                        initialValue: item['importPrice'].toString(),
                                        textAlign: TextAlign.right,
                                        keyboardType: TextInputType.number,
                                        decoration: InputDecoration(
                                          contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                                          filled: true,
                                          fillColor: const Color(0xFFF3F4F6),
                                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                                          suffixText: 'đ',
                                        ),
                                        style: const TextStyle(fontWeight: FontWeight.w500),
                                        onChanged: (val) {
                                          final newVal = double.tryParse(val);
                                          if (newVal != null) {
                                            setState(() {
                                              item['importPrice'] = newVal;
                                            });
                                          }
                                        },
                                      ),
                                    )
                                  ),
                                  Expanded(
                                    flex: 3, 
                                    child: Align(
                                      alignment: Alignment.centerRight,
                                      child: Text(
                                        NumberFormat.currency(locale: 'vi_VN', symbol: 'đ', decimalDigits: 0).format(item['quantity'] * item['importPrice']),
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                      ),
                                    )
                                  ),
                                  Expanded(
                                    flex: 1, 
                                    child: IconButton(
                                      icon: const Icon(Icons.delete_outline, color: Color(0xFFC81E1E)),
                                      onPressed: () => _removeItem(index),
                                    )
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: TextButton.icon(
                        onPressed: _showProductSelection,
                        icon: const Icon(Icons.add_circle_outline, color: ColorPalette.appetizingOrange),
                        label: const Text('Thêm dòng sản phẩm khác', style: TextStyle(color: ColorPalette.appetizingOrange, fontWeight: FontWeight.w600, fontSize: 15)),
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.orange.shade50,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    // Notes Section
                    Row(
                      children: [
                        const Text('Ghi chú phiếu nhập', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                        const SizedBox(width: 8),
                        Text('(Tùy chọn)', style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _notesController,
                      maxLines: 2,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFFF3F4F6),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
            
            // Footer
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                border: Border(top: BorderSide(color: Colors.grey.shade200)),
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('Tổng tiền tạm tính: ', style: TextStyle(fontSize: 16, color: Colors.grey.shade700, fontWeight: FontWeight.w600)),
                      Text(
                        NumberFormat.currency(locale: 'vi_VN', symbol: 'đ', decimalDigits: 0).format(_calculateTotal()), 
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFFC04313))
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.grey.shade200,
                          foregroundColor: Colors.grey.shade800,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text('Hủy bỏ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton.icon(
                        onPressed: _submitDraft,
                        icon: const Icon(Icons.bookmark_border, color: Colors.white),
                        label: const Text('Lưu nháp', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFB1390A),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
