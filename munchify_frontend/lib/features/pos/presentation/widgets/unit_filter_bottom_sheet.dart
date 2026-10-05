import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/ColorPalette.dart';
import '../bloc/pos_catalog_bloc.dart';
import '../bloc/pos_catalog_event.dart';
import '../bloc/pos_catalog_state.dart';

/// Bottom sheet lọc sản phẩm theo đơn vị tính.
class UnitFilterBottomSheet extends StatelessWidget {
  final PosCatalogLoaded state;

  const UnitFilterBottomSheet({Key? key, required this.state}) : super(key: key);

  /// Mở bottom sheet. [bloc] được truyền lại vì modal route nằm ngoài cây widget gốc.
  static Future<void> show(
    BuildContext context, {
    required PosCatalogBloc bloc,
    required PosCatalogLoaded state,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => BlocProvider.value(
        value: bloc,
        child: UnitFilterBottomSheet(state: state),
      ),
    );
  }

  void _select(BuildContext context, String? unit) {
    context.read<PosCatalogBloc>().add(FilterByUnitEvent(unit));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final units = state.products.map((p) => p.unitName).toSet().toList()..sort();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Lọc theo đơn vị',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const Divider(),
              ListTile(
                title: const Text('Tất cả'),
                trailing: state.selectedUnitName == null
                    ? const Icon(Icons.check, color: ColorPalette.appetizingOrange)
                    : null,
                onTap: () => _select(context, null),
              ),
              ...units.map(
                (unit) => ListTile(
                  title: Text(unit),
                  trailing: state.selectedUnitName == unit
                      ? const Icon(Icons.check, color: ColorPalette.appetizingOrange)
                      : null,
                  onTap: () => _select(context, unit),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
