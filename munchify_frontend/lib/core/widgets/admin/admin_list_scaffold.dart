import 'package:flutter/material.dart';

import '../../theme/ColorPalette.dart';

/// Khung trang danh sách Admin dùng chung.
///
/// Thứ tự cố định: [header] → [filterBar] → [kpiCards] → [table].
/// Nếu [stateView] khác null (Loading / Error) thì thay toàn bộ nội dung.
/// Khi [embedInShell] = false sẽ bọc thêm [stickyHeader] ở trên cùng.
class AdminListScaffold extends StatelessWidget {
  final Widget header;
  final Widget? filterBar;
  final List<Widget> kpiCards;
  final Widget? table;
  final Widget? stateView;
  final bool embedInShell;
  final Widget? stickyHeader;

  const AdminListScaffold({
    super.key,
    required this.header,
    this.filterBar,
    this.kpiCards = const [],
    this.table,
    this.stateView,
    this.embedInShell = false,
    this.stickyHeader,
  });

  @override
  Widget build(BuildContext context) {
    final body =
        stateView ??
        SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              header,
              if (filterBar != null) ...[
                const SizedBox(height: 18),
                filterBar!,
              ],
              if (kpiCards.isNotEmpty) ...[
                const SizedBox(height: 20),
                AdminKpiRow(cards: kpiCards),
              ],
              if (table != null) ...[const SizedBox(height: 24), table!],
            ],
          ),
        );

    if (embedInShell) {
      return ColoredBox(
        color: ColorPalette.webBgAdmin,
        child: SizedBox.expand(child: body),
      );
    }

    return Scaffold(
      backgroundColor: ColorPalette.webBgAdmin,
      body: SafeArea(
        child: Column(
          children: [
            ?stickyHeader,
            Expanded(child: body),
          ],
        ),
      ),
    );
  }
}

/// Hàng KPI responsive: 4 cột (>1050px), 2 cột (>550px), 1 cột.
///
/// Các thẻ con nên là AdminKpiCard; chiều rộng được set qua SizedBox.
class AdminKpiRow extends StatelessWidget {
  final List<Widget> cards;
  final double gap;

  const AdminKpiRow({super.key, required this.cards, this.gap = 16});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxCols = cards.length.clamp(1, 4);
        final cols = constraints.maxWidth > 1050
            ? maxCols
            : (constraints.maxWidth > 550 ? maxCols.clamp(1, 2) : 1);
        final w = (constraints.maxWidth - ((cols - 1) * gap)) / cols;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [for (final c in cards) SizedBox(width: w, child: c)],
        );
      },
    );
  }
}
