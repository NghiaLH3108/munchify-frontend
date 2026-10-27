import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/AppTypography.dart';
import '../../../../core/theme/ColorPalette.dart';
import '../../domain/entities/top_selling_entity.dart';

class TopSellingTableWidget extends StatelessWidget {
  final List<TopSellingEntity> items;

  const TopSellingTableWidget({super.key, required this.items});

  static final NumberFormat _vnd =
      NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ColorPalette.surfaceWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ColorPalette.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sản phẩm & Combo bán chạy',
            style: AppTypography.plusJakarta(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: ColorPalette.onSurfaceDark,
            ),
          ),
          const SizedBox(height: 12),
          if (items.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(
                'Chưa có dữ liệu',
                style: AppTypography.inter(
                    fontSize: 13, color: ColorPalette.textMuted),
              ),
            )
          else
            LayoutBuilder(
              builder: (context, c) => SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: c.maxWidth.isFinite && c.maxWidth > 520
                        ? c.maxWidth
                        : 520,
                  ),
                  child: DataTable(
                    headingRowHeight: 40,
                    columnSpacing: 24,
                    horizontalMargin: 8,
                    columns: const [
                      DataColumn(label: Text('#')),
                      DataColumn(label: Text('Tên')),
                      DataColumn(label: Text('Loại')),
                      DataColumn(label: Text('SL bán'), numeric: true),
                      DataColumn(label: Text('Doanh thu'), numeric: true),
                    ],
                    rows: [
                      for (var i = 0; i < items.length; i++)
                        DataRow(cells: [
                          DataCell(Text('${i + 1}')),
                          DataCell(Text(items[i].productName)),
                          DataCell(Text(items[i].isCombo ? 'Combo' : 'Sản phẩm')),
                          DataCell(Text('${items[i].totalQuantity}')),
                          DataCell(Text(_vnd.format(items[i].totalRevenue))),
                        ]),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
