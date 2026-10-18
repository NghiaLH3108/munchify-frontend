import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../bloc/stock_import_bloc.dart';
import '../bloc/stock_import_event.dart';
import '../../domain/entities/stock_import_entity.dart';
import '../../../../../core/theme/ColorPalette.dart';

class ImportDetailModal extends StatelessWidget {
  final StockImportEntity importEntity;

  const ImportDetailModal({super.key, required this.importEntity});

  @override
  Widget build(BuildContext context) {
    final totalQuantity = importEntity.details.fold<int>(0, (sum, item) => sum + item.quantity);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.white,
      child: Container(
        width: 900,
        height: 750,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.receipt_long, color: ColorPalette.appetizingOrange, size: 28),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text('Chi tiết Phiếu Nhập #${importEntity.importCode}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                            const SizedBox(width: 12),
                            _buildStatusBadge(importEntity.status),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text('Mã tham chiếu hệ thống: MNC-WH-${DateFormat('yyyyMMdd').format(importEntity.importDate)}-${importEntity.importId.toString().padLeft(3, '0')}', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                      ],
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                  style: IconButton.styleFrom(backgroundColor: Colors.grey.shade100),
                )
              ],
            ),
            const SizedBox(height: 24),
            
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Info Section
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9FAFB),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.storefront, size: 18, color: Colors.grey.shade700),
                                  const SizedBox(width: 8),
                                  Text('THÔNG TIN NHÀ CUNG CẤP & GIAO NHẬN', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey.shade700, fontSize: 13)),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.orange.shade50,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text('Mã NCC: #SUP-${importEntity.supplierId.toString().padLeft(3, '0')}', style: TextStyle(color: ColorPalette.appetizingOrange, fontSize: 12, fontWeight: FontWeight.w600)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Nhà cung cấp', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                                    const SizedBox(height: 4),
                                    Text(importEntity.supplierName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Mã nhà cung cấp', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(Icons.badge_outlined, size: 16, color: ColorPalette.appetizingOrange),
                                        const SizedBox(width: 4),
                                        Text('SUP-${importEntity.supplierId.toString().padLeft(3, '0')}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Thời gian lập phiếu', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(Icons.calendar_today, size: 16, color: Colors.grey.shade700),
                                        const SizedBox(width: 6),
                                        Text(DateFormat('dd/MM/yyyy HH:mm').format(importEntity.importDate), style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15)),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Người lập phiếu', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(Icons.person_outline, size: 18, color: ColorPalette.appetizingOrange),
                                        const SizedBox(width: 4),
                                        Text(
                                          importEntity.userName.isNotEmpty ? importEntity.userName : 'Admin (Hệ thống)', 
                                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.sticky_note_2_outlined, size: 16, color: ColorPalette.appetizingOrange),
                                    const SizedBox(width: 6),
                                    Text('Ghi chú giao dịch:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.grey.shade700)),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  importEntity.notes ?? 'Không có ghi chú', 
                                  style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 14)
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Table Section
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade200),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF9FAFB),
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                              border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.list_alt, size: 20, color: Colors.grey.shade700),
                                    const SizedBox(width: 8),
                                    const Text('Danh mục vật tư & Nguyên liệu nhập kho', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                                  ],
                                ),
                                Text('${importEntity.details.length < 10 ? '0' : ''}${importEntity.details.length} mặt hàng', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                              ],
                            ),
                          ),
                          // Table Header
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey.shade200))),
                            child: Row(
                              children: [
                                Expanded(flex: 1, child: Text('STT', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey.shade700, fontSize: 12))),
                                Expanded(flex: 5, child: Text('TÊN MẶT HÀNG', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey.shade700, fontSize: 12))),
                                Expanded(flex: 2, child: Center(child: Text('QUY CÁCH', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey.shade700, fontSize: 12)))),
                                Expanded(flex: 2, child: Align(alignment: Alignment.centerRight, child: Text('SỐ LƯỢNG', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey.shade700, fontSize: 12)))),
                                Expanded(flex: 2, child: Align(alignment: Alignment.centerRight, child: Text('ĐƠN GIÁ', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey.shade700, fontSize: 12)))),
                                Expanded(flex: 3, child: Align(alignment: Alignment.centerRight, child: Text('THÀNH TIỀN', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey.shade700, fontSize: 12)))),
                              ],
                            ),
                          ),
                          // Table Items
                          ...importEntity.details.asMap().entries.map((entry) {
                            int index = entry.key;
                            var item = entry.value;
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              decoration: BoxDecoration(
                                border: index != importEntity.details.length - 1 ? Border(bottom: BorderSide(color: Colors.grey.shade100)) : null,
                              ),
                              child: Row(
                                children: [
                                  Expanded(flex: 1, child: Text('${index + 1}', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey.shade500))),
                                  Expanded(
                                    flex: 5, 
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(item.productName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                        const SizedBox(height: 4),
                                        Text('SKU: PRD-${item.productId.toString().padLeft(3, '0')}', style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                                      ],
                                    )
                                  ),
                                  Expanded(flex: 2, child: Center(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                      decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(12)),
                                      child: Text(item.unitName, style: TextStyle(fontSize: 12, color: Colors.grey.shade700, fontWeight: FontWeight.w500)),
                                    ),
                                  )),
                                  Expanded(flex: 2, child: Align(alignment: Alignment.centerRight, child: Text('${item.quantity}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)))),
                                  Expanded(flex: 2, child: Align(alignment: Alignment.centerRight, child: Text(NumberFormat.currency(locale: 'vi_VN', symbol: 'đ', decimalDigits: 0).format(item.importPrice), style: TextStyle(color: Colors.grey.shade700, fontSize: 14)))),
                                  Expanded(
                                    flex: 3, 
                                    child: Align(
                                      alignment: Alignment.centerRight, 
                                      child: Text(
                                        NumberFormat.currency(locale: 'vi_VN', symbol: 'đ', decimalDigits: 0).format(item.quantity * item.importPrice), 
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                          // Table Footer
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF9FAFB),
                              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
                              border: Border(top: BorderSide(color: Colors.grey.shade200)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Text('Tổng số lượng: ', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                                    Text('$totalQuantity sản phẩm ', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                    Text('(${importEntity.details.length} mặt hàng)', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                                    const SizedBox(width: 16),
                                    Text('Thuế VAT (0%): ', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                                    const Text('0 đ', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Icon(
                                      importEntity.status == 'COMPLETED' ? Icons.verified_outlined : Icons.pending_actions,
                                      size: 16, 
                                      color: importEntity.status == 'COMPLETED' ? Colors.green.shade700 : Colors.orange.shade700,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      importEntity.status == 'COMPLETED' 
                                          ? 'Đã hoàn tất kiểm đếm & nhập kho' 
                                          : (importEntity.status == 'DRAFT' ? 'Phiếu nháp chờ kiểm đếm thực tế' : 'Phiếu đã hủy'),
                                      style: TextStyle(
                                        color: importEntity.status == 'COMPLETED' ? Colors.green.shade700 : Colors.grey.shade700, 
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Divider(),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('Tổng tiền phiếu: ', style: TextStyle(fontSize: 16, color: Colors.grey.shade700)),
                    Text(
                      NumberFormat.currency(locale: 'vi_VN', symbol: 'đ', decimalDigits: 0).format(importEntity.totalAmount), 
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFFC04313)) // Dark orange
                    ),
                  ],
                ),
                if (importEntity.status == 'DRAFT')
                  Row(
                    children: [
                      TextButton.icon(
                        onPressed: () {
                          context.read<StockImportBloc>().add(CancelImportEvent(importEntity.importId));
                          Navigator.of(context).pop();
                        },
                        icon: const Icon(Icons.delete_outline, color: Color(0xFFC81E1E)),
                        label: const Text('Hủy phiếu nhập', style: TextStyle(color: Color(0xFFC81E1E), fontWeight: FontWeight.w600)),
                        style: TextButton.styleFrom(
                          backgroundColor: const Color(0xFFFDE8E8),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton.icon(
                        onPressed: () {
                          context.read<StockImportBloc>().add(CompleteImportEvent(importEntity.importId));
                          Navigator.of(context).pop();
                        },
                        icon: const Icon(Icons.check_circle_outline, color: Colors.white),
                        label: const Text('Xác nhận nhập kho', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFB1390A), // Dark orange
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ],
                  ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bgColor;
    Color textColor;
    String text;
    IconData? icon;

    switch (status.toUpperCase()) {
      case 'COMPLETED':
        bgColor = const Color(0xFFDEF7EC);
        textColor = const Color(0xFF03543F);
        text = 'Hoàn thành';
        icon = Icons.check;
        break;
      case 'DRAFT':
        bgColor = const Color(0xFFE5E7EB);
        textColor = const Color(0xFF374151);
        text = 'Bản nháp (Draft)';
        icon = Icons.edit;
        break;
      case 'CANCELLED':
        bgColor = const Color(0xFFFDE8E8);
        textColor = const Color(0xFF9B1C1C);
        text = 'Đã huỷ';
        icon = Icons.close;
        break;
      default:
        bgColor = const Color(0xFFE5E7EB);
        textColor = const Color(0xFF374151);
        text = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text,
            style: TextStyle(
              color: textColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (icon != null) ...[
            const SizedBox(width: 4),
            Icon(icon, size: 14, color: textColor),
          ]
        ],
      ),
    );
  }
}
