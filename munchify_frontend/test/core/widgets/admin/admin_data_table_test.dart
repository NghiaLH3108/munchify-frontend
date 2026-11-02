import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:munchify_frontend/core/widgets/admin/admin_widgets.dart';

void main() {
  Widget host(Widget child) => MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: SizedBox(width: 1200, child: child),
          ),
        ),
      );

  final columns = <AdminTableColumn<String>>[
    AdminTableColumn.index<String>(),
    AdminTableColumn(
      label: 'TÊN',
      flex: 3,
      cellBuilder: (_, item, _) => Text('name:$item'),
    ),
    AdminTableColumn(
      label: 'THAO TÁC',
      width: 80,
      cellBuilder: (_, _, _) => const SizedBox(),
    ),
  ];

  testWidgets('renders header, rows and index with offset', (tester) async {
    await tester.pumpWidget(host(AdminDataTable<String>(
      title: 'Danh sách test',
      countLabel: '2 mục',
      items: const ['a', 'b'],
      columns: columns,
      indexOffset: 10,
    )));

    expect(find.text('Danh sách test'), findsOneWidget);
    expect(find.text('2 mục'), findsOneWidget);
    expect(find.text('TÊN'), findsOneWidget);
    expect(find.text('THAO TÁC'), findsOneWidget);
    expect(find.text('name:a'), findsOneWidget);
    expect(find.text('name:b'), findsOneWidget);
    expect(find.text('11'), findsOneWidget);
    expect(find.text('12'), findsOneWidget);
  });

  testWidgets('hides view toggle when cardBuilder is null', (tester) async {
    await tester.pumpWidget(host(AdminDataTable<String>(
      title: 'T',
      countLabel: '1',
      items: const ['a'],
      columns: columns,
      onToggleView: (_) {},
    )));
    expect(find.byIcon(Icons.grid_view_rounded), findsNothing);
  });

  testWidgets('toggle switches to card view', (tester) async {
    var isCard = false;
    await tester.pumpWidget(StatefulBuilder(
      builder: (context, setState) => host(AdminDataTable<String>(
        title: 'T',
        countLabel: '1',
        items: const ['a'],
        columns: columns,
        isCardView: isCard,
        onToggleView: (v) => setState(() => isCard = v),
        cardBuilder: (_, item, _) => Text('card:$item'),
      )),
    ));

    expect(find.text('card:a'), findsNothing);
    await tester.tap(find.byIcon(Icons.grid_view_rounded));
    await tester.pump();
    expect(find.text('card:a'), findsOneWidget);
    expect(find.text('TÊN'), findsNothing);
  });

  testWidgets('shows empty state when items empty', (tester) async {
    await tester.pumpWidget(host(AdminDataTable<String>(
      title: 'T',
      countLabel: '0',
      items: const [],
      columns: columns,
      emptyState: const AdminEmptyState(title: 'Trống rồi'),
    )));
    expect(find.text('Trống rồi'), findsOneWidget);
    expect(find.text('TÊN'), findsNothing);
  });

  testWidgets('onRowTap is called with the item', (tester) async {
    String? tapped;
    await tester.pumpWidget(host(AdminDataTable<String>(
      title: 'T',
      countLabel: '1',
      items: const ['x'],
      columns: columns,
      onRowTap: (v) => tapped = v,
    )));
    await tester.tap(find.text('name:x'));
    expect(tapped, 'x');
  });

  testWidgets('AdminListScaffold renders header, filterBar, KPIs and table in shell mode', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: 1200,
          height: 800,
          child: AdminListScaffold(
            embedInShell: true,
            header: const AdminPageHeader(
              icon: Icons.category_rounded,
              title: 'Tiêu đề trang',
              subtitle: 'Mô tả trang',
            ),
            filterBar: const Text('FILTER_BAR_SLOT'),
            kpiCards: const [
              AdminKpiCard(
                title: 'KPI 1',
                value: '10',
                subtitle: 'sub',
                icon: Icons.star,
              ),
            ],
            table: AdminDataTable<String>(
              title: 'Bảng dữ liệu',
              countLabel: '1 mục',
              items: const ['item1'],
              columns: [
                AdminTableColumn.index<String>(),
                AdminTableColumn(
                  label: 'CỘT 1',
                  cellBuilder: (_, v, _) => Text(v),
                ),
              ],
            ),
          ),
        ),
      ),
    ));

    expect(find.text('Tiêu đề trang'), findsOneWidget);
    expect(find.text('FILTER_BAR_SLOT'), findsOneWidget);
    expect(find.text('KPI 1'), findsOneWidget);
    expect(find.text('Bảng dữ liệu'), findsOneWidget);
    expect(find.text('item1'), findsOneWidget);
  });
}
