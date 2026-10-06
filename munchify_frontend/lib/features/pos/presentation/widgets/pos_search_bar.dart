import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/ColorPalette.dart';
import '../bloc/pos_catalog_bloc.dart';
import '../bloc/pos_catalog_event.dart';

/// Thanh tìm kiếm sản phẩm (debounce 300ms) + nút quét mã QR.
class PosSearchBar extends StatefulWidget {
  const PosSearchBar({Key? key}) : super(key: key);

  @override
  State<PosSearchBar> createState() => _PosSearchBarState();
}

class _PosSearchBarState extends State<PosSearchBar> {
  Timer? _debounce;
  final TextEditingController _searchController = TextEditingController();

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      context.read<PosCatalogBloc>().add(SearchProductEvent(query));
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                decoration: const InputDecoration(
                  icon: Icon(Icons.search, color: ColorPalette.textHint),
                  hintText: 'Tìm theo tên hoặc mã SP...',
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Material(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () {},
              child: const SizedBox(
                width: 48,
                height: 48,
                child: Icon(Icons.qr_code_scanner, color: ColorPalette.appetizingOrange),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
