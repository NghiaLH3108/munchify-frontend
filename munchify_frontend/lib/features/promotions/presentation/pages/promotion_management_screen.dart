import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/ColorPalette.dart';
import '../../../../core/widgets/admin/admin_widgets.dart';
import '../../../../injection_container.dart';
import '../../domain/entities/promotion_entity.dart';
import '../../domain/usecases/get_promotion_by_id_usecase.dart';
import '../bloc/promotion_admin_bloc.dart';
import '../bloc/promotion_admin_event.dart';
import '../bloc/promotion_admin_state.dart';
import '../bloc/promotion_form_bloc.dart';
import '../widgets/promotion_data_table.dart';
import '../widgets/promotion_filter_bar.dart';
import '../widgets/promotion_form_dialog.dart';
import '../widgets/promotion_stat_cards.dart';
import '../../../../core/widgets/app_toast.dart';

class PromotionManagementScreen extends StatefulWidget {
  final bool embedInShell;
  const PromotionManagementScreen({super.key, this.embedInShell = false});

  @override
  State<PromotionManagementScreen> createState() =>
      _PromotionManagementScreenState();
}

class _PromotionManagementScreenState extends State<PromotionManagementScreen> {
  int _currentPage = 1;
  static const int _pageSize = 10;
  String _searchQuery = '';
  bool? _selectedStatus;
  String? _selectedDiscountType;
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
          child: CircularProgressIndicator(
            color: ColorPalette.appetizingOrange,
          ),
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
            AppToast.error(failure.message, context: context);
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
          BlocProvider<PromotionFormBloc>(
            create: (_) => sl<PromotionFormBloc>(),
          ),
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
    return BlocProvider.value(
      value: _adminBloc,
      child: BlocConsumer<PromotionAdminBloc, PromotionAdminState>(
        listener: (context, state) {
          if (state is PromotionAdminError) {
            AppToast.error(state.message, context: context);
          } else if (state is PromotionsLoaded &&
              state.successMessage != null) {
            AppToast.success(state.successMessage!, context: context);
          }
        },
        builder: (context, state) {
          Widget? stateView;
          List<Widget> kpis = const [];
          Widget? table;

          if (state is PromotionAdminLoading) {
            stateView = const AdminLoadingView(
              message: 'Đang đồng bộ chương trình khuyến mãi...',
            );
          } else if (state is PromotionAdminError) {
            stateView = AdminErrorView(
              message: state.message,
              onRetry: _loadData,
            );
          } else if (state is PromotionsLoaded) {
            final allItems = state.promotionsData.items;
            final kpiItems = state.kpiPromotions ?? allItems;
            final kpiTotal =
                state.kpiTotalCount ?? state.promotionsData.totalCount;

            final items = allItems.where((p) {
              if (_selectedStatus != null && p.isActive != _selectedStatus) {
                return false;
              }
              if (_selectedDiscountType != null &&
                  p.discountType != _selectedDiscountType) {
                return false;
              }
              return true;
            }).toList();

            kpis = PromotionStatCards.cards(
              promotions: kpiItems,
              totalCount: kpiTotal,
            );
            table = PromotionDataTable(
              promotions: items,
              totalPages: state.promotionsData.totalPages,
              currentPage: state.promotionsData.pageNumber,
              totalCount: items.length != allItems.length
                  ? items.length
                  : state.promotionsData.totalCount,
              pageSize: _pageSize,
              isRefreshing: state.isRefreshing,
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
            );
          } else {
            stateView = const SizedBox.shrink();
          }

          return AdminListScaffold(
            embedInShell: widget.embedInShell,
            stickyHeader: AdminStickyHeader(
              breadcrumb: 'Khuyến mãi',
              onRefresh: _loadData,
            ),
            header: AdminPageHeader(
              icon: Icons.local_offer_rounded,
              title: 'Quản lý Khuyến mãi',
              subtitle:
                  'Quản lý các chương trình ưu đãi, mã giảm giá và voucher',
              addButtonText: 'Thêm Khuyến mãi',
              onAddPressed: () => _openFormDialog(),
            ),
            filterBar: PromotionFilterBar(
              searchController: _searchController,
              onSearchChanged: (val) {
                setState(() {
                  _searchQuery = val.trim();
                  _currentPage = 1;
                });
                _loadData();
              },
              selectedStatus: _selectedStatus,
              onStatusChanged: (val) {
                setState(() {
                  _selectedStatus = val;
                  _currentPage = 1;
                });
              },
              selectedDiscountType: _selectedDiscountType,
              onDiscountTypeChanged: (val) {
                setState(() {
                  _selectedDiscountType = val;
                  _currentPage = 1;
                });
              },
              onReset: () {
                _searchController.clear();
                setState(() {
                  _searchQuery = '';
                  _selectedStatus = null;
                  _selectedDiscountType = null;
                  _currentPage = 1;
                });
                _loadData();
              },
            ),
            kpiCards: kpis,
            table: table,
            stateView: stateView,
          );
        },
      ),
    );
  }
}
