import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/ColorPalette.dart';
import '../../../../core/theme/AppTypography.dart';
import '../../../../injection_container.dart';
import '../../domain/entities/promotion_entity.dart';
import '../../domain/usecases/get_promotion_by_id_usecase.dart';
import '../bloc/promotion_admin_bloc.dart';
import '../bloc/promotion_admin_event.dart';
import '../bloc/promotion_admin_state.dart';
import '../bloc/promotion_form_bloc.dart';
import '../widgets/promotion_stat_cards.dart';
import '../widgets/promotion_filter_bar.dart';
import '../widgets/promotion_data_table.dart';
import '../widgets/promotion_form_dialog.dart';

class PromotionManagementScreen extends StatefulWidget {
  final bool embedInShell;
  const PromotionManagementScreen({super.key, this.embedInShell = false});

  @override
  State<PromotionManagementScreen> createState() => _PromotionManagementScreenState();
}

class _PromotionManagementScreenState extends State<PromotionManagementScreen> {
  int _currentPage = 1;
  static const int _pageSize = 10;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  late PromotionAdminBloc _adminBloc;

  @override
  void initState() {
    super.initState();
    _adminBloc = sl<PromotionAdminBloc>();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _adminBloc.close();
    super.dispose();
  }

  void _loadData() {
    _adminBloc.add(LoadPromotions(
      pageIndex: _currentPage,
      pageSize: _pageSize,
      searchKeyword: _searchQuery.isNotEmpty ? _searchQuery : null,
    ));
  }

  Future<void> _openFormDialog({PromotionEntity? promotion}) async {
    PromotionDetailEntity? detailToEdit;
    if (promotion != null) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(
          child: CircularProgressIndicator(color: ColorPalette.appetizingOrange),
        ),
      );

      final getDetail = sl<GetPromotionByIdUseCase>();
      final result = await getDetail(promotion.promotionId.toString());

      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      result.fold(
        (failure) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(failure.message), backgroundColor: ColorPalette.error),
            );
          }
        },
        (detail) {
          detailToEdit = detail;
        },
      );

      if (detailToEdit == null) return;
    }

    if (!mounted) return;
    showDialog(
      context: context,
      builder: (ctx) => MultiBlocProvider(
        providers: [
          BlocProvider<PromotionFormBloc>(create: (_) => sl<PromotionFormBloc>()),
        ],
        child: PromotionFormDialog(
          promotionToEdit: detailToEdit,
          onSuccess: _loadData,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bodyContent = BlocProvider.value(
      value: _adminBloc,
      child: BlocConsumer<PromotionAdminBloc, PromotionAdminState>(
        listener: (context, state) {
          if (state is PromotionAdminError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: ColorPalette.error),
            );
          }
        },
        builder: (context, state) {
          if (state is PromotionAdminLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is PromotionsLoaded) {
            final items = state.promotionsData.items;
            
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildPageTitleBar(context),
                  const SizedBox(height: 20),
                  PromotionStatCards(promotions: items, totalCount: state.promotionsData.totalCount),
                  const SizedBox(height: 24),
                  Container(
                    decoration: BoxDecoration(
                      color: ColorPalette.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: ColorPalette.borderSubtle),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        PromotionFilterBar(
                          searchController: _searchController,
                          hasSearchQuery: _searchQuery.isNotEmpty,
                          onSearch: () {
                            setState(() {
                              _searchQuery = _searchController.text.trim();
                              _currentPage = 1;
                            });
                            _loadData();
                          },
                          onClear: () {
                            _searchController.clear();
                            setState(() {
                              _searchQuery = '';
                              _currentPage = 1;
                            });
                            _loadData();
                          },
                        ),
                        PromotionDataTable(
                          promotions: items,
                          totalPages: state.promotionsData.totalPages,
                          currentPage: state.promotionsData.pageNumber,
                          totalCount: state.promotionsData.totalCount,
                          onPageChanged: (page) {
                            setState(() => _currentPage = page);
                            _loadData();
                          },
                          onEdit: (promo) => _openFormDialog(promotion: promo),
                          onToggleStatus: (id) {
                            _adminBloc.add(TogglePromotionStatus(
                              id: id,
                              pageIndex: _currentPage,
                              pageSize: _pageSize,
                              searchKeyword: _searchQuery.isNotEmpty ? _searchQuery : null,
                            ));
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );

    if (widget.embedInShell) {
      return bodyContent;
    }

    return Scaffold(
      backgroundColor: ColorPalette.webBgAdmin,
      body: SafeArea(child: bodyContent),
    );
  }

  Widget _buildPageTitleBar(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Quản lý Khuyến mãi', style: AppTypography.plusJakarta(fontSize: 22, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text('Quản lý các chương trình ưu đãi', style: AppTypography.inter(fontSize: 13, color: ColorPalette.textMuted)),
          ],
        ),
        ElevatedButton.icon(
          onPressed: () => _openFormDialog(),
          icon: const Icon(Icons.add_rounded, size: 18),
          label: const Text('+ Thêm Khuyến mãi'),
          style: ElevatedButton.styleFrom(
            backgroundColor: ColorPalette.primaryContainer,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }
}
