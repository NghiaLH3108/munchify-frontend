import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/ApiEndpoints.dart';
import '../../../../core/network/DioClient.dart';

// ─── Models ────────────────────────────────────────────────────────────────

class DashboardTrendPoint extends Equatable {
  final String label;
  final double revenue;
  final int orderCount;
  final bool isPeak;

  const DashboardTrendPoint({
    required this.label,
    required this.revenue,
    required this.orderCount,
    required this.isPeak,
  });

  factory DashboardTrendPoint.fromJson(Map<String, dynamic> json) {
    return DashboardTrendPoint(
      label: (json['label'] as String?) ?? '',
      revenue: (json['revenue'] as num?)?.toDouble() ?? 0,
      orderCount: (json['orderCount'] as num?)?.toInt() ?? 0,
      isPeak: (json['isPeak'] as bool?) ?? false,
    );
  }

  @override
  List<Object?> get props => [label, revenue, orderCount, isPeak];
}

class DashboardPaymentMethod extends Equatable {
  final String methodKey;
  final String methodName;
  final int orderCount;
  final double totalAmount;
  final double sharePercent;

  const DashboardPaymentMethod({
    required this.methodKey,
    required this.methodName,
    required this.orderCount,
    required this.totalAmount,
    required this.sharePercent,
  });

  factory DashboardPaymentMethod.fromJson(Map<String, dynamic> json) {
    return DashboardPaymentMethod(
      methodKey: (json['methodKey'] as String?) ?? '',
      methodName: (json['methodName'] as String?) ?? '',
      orderCount: (json['orderCount'] as num?)?.toInt() ?? 0,
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0,
      sharePercent: (json['sharePercent'] as num?)?.toDouble() ?? 0,
    );
  }

  @override
  List<Object?> get props => [
        methodKey,
        methodName,
        orderCount,
        totalAmount,
        sharePercent,
      ];
}

class DashboardTopProduct extends Equatable {
  final int productId;
  final String productCode;
  final String productName;
  final String? description;
  final String categoryName;
  final String unitName;
  final bool isCombo;
  final double unitPrice;
  final int quantitySold;
  final double totalRevenue;
  final double revenueSharePercent;
  final int stockQuantity;
  final int minStockLevel;
  final bool isOutOfStock;

  const DashboardTopProduct({
    required this.productId,
    required this.productCode,
    required this.productName,
    this.description,
    required this.categoryName,
    required this.unitName,
    required this.isCombo,
    required this.unitPrice,
    required this.quantitySold,
    required this.totalRevenue,
    required this.revenueSharePercent,
    required this.stockQuantity,
    required this.minStockLevel,
    required this.isOutOfStock,
  });

  factory DashboardTopProduct.fromJson(Map<String, dynamic> json) {
    return DashboardTopProduct(
      productId: (json['productId'] as num?)?.toInt() ?? 0,
      productCode: (json['productCode'] as String?) ?? '',
      productName: (json['productName'] as String?) ?? '',
      description: json['description'] as String?,
      categoryName: (json['categoryName'] as String?) ?? '',
      unitName: (json['unitName'] as String?) ?? '',
      isCombo: (json['isCombo'] as bool?) ?? false,
      unitPrice: (json['unitPrice'] as num?)?.toDouble() ?? 0,
      quantitySold: (json['quantitySold'] as num?)?.toInt() ?? 0,
      totalRevenue: (json['totalRevenue'] as num?)?.toDouble() ?? 0,
      revenueSharePercent:
          (json['revenueSharePercent'] as num?)?.toDouble() ?? 0,
      stockQuantity: (json['stockQuantity'] as num?)?.toInt() ?? 0,
      minStockLevel: (json['minStockLevel'] as num?)?.toInt() ?? 0,
      isOutOfStock: (json['isOutOfStock'] as bool?) ?? false,
    );
  }

  @override
  List<Object?> get props => [
        productId,
        productCode,
        productName,
        description,
        categoryName,
        unitName,
        isCombo,
        unitPrice,
        quantitySold,
        totalRevenue,
        revenueSharePercent,
        stockQuantity,
        minStockLevel,
        isOutOfStock,
      ];
}

class DashboardSummary extends Equatable {
  final double todayRevenue;
  final double yesterdayRevenue;
  final double? revenueChangePercent;
  final int todayOrderCount;
  final int yesterdayOrderCount;
  final double averageOrderValue;
  final int lowStockProductCount;
  final int totalMenuProductsCount;
  final int totalCustomerCount;
  final int newCustomersTodayCount;
  final int loyaltyCustomerCount;
  final double loyaltyCustomerPercent;
  final String peakHourLabel;
  final double peakHourRevenue;
  final int peakHourOrderCount;
  final List<DashboardTrendPoint> hourlyTrend;
  final List<DashboardTrendPoint> weeklyTrend;
  final List<DashboardTrendPoint> monthlyTrend;
  final int paymentTotalOrderCount;
  final List<DashboardPaymentMethod> paymentMethods;
  final List<DashboardTopProduct> topProducts;

  const DashboardSummary({
    required this.todayRevenue,
    required this.yesterdayRevenue,
    this.revenueChangePercent,
    required this.todayOrderCount,
    required this.yesterdayOrderCount,
    required this.averageOrderValue,
    required this.lowStockProductCount,
    this.totalMenuProductsCount = 0,
    required this.totalCustomerCount,
    required this.newCustomersTodayCount,
    this.loyaltyCustomerCount = 0,
    this.loyaltyCustomerPercent = 0,
    this.peakHourLabel = '',
    this.peakHourRevenue = 0,
    this.peakHourOrderCount = 0,
    this.hourlyTrend = const [],
    this.weeklyTrend = const [],
    this.monthlyTrend = const [],
    this.paymentTotalOrderCount = 0,
    this.paymentMethods = const [],
    this.topProducts = const [],
  });

  factory DashboardSummary.fromJson(Map<String, dynamic> json) {
    List<DashboardTrendPoint> parseTrend(dynamic raw) {
      if (raw is List) {
        return raw
            .whereType<Map<String, dynamic>>()
            .map(DashboardTrendPoint.fromJson)
            .toList();
      }
      return const [];
    }

    List<DashboardPaymentMethod> parsePayments(dynamic raw) {
      if (raw is List) {
        return raw
            .whereType<Map<String, dynamic>>()
            .map(DashboardPaymentMethod.fromJson)
            .toList();
      }
      return const [];
    }

    List<DashboardTopProduct> parseTopProducts(dynamic raw) {
      if (raw is List) {
        return raw
            .whereType<Map<String, dynamic>>()
            .map(DashboardTopProduct.fromJson)
            .toList();
      }
      return const [];
    }

    return DashboardSummary(
      todayRevenue: (json['todayRevenue'] as num?)?.toDouble() ?? 0,
      yesterdayRevenue: (json['yesterdayRevenue'] as num?)?.toDouble() ?? 0,
      revenueChangePercent: (json['revenueChangePercent'] as num?)?.toDouble(),
      todayOrderCount: (json['todayOrderCount'] as num?)?.toInt() ?? 0,
      yesterdayOrderCount: (json['yesterdayOrderCount'] as num?)?.toInt() ?? 0,
      averageOrderValue: (json['averageOrderValue'] as num?)?.toDouble() ?? 0,
      lowStockProductCount:
          (json['lowStockProductCount'] as num?)?.toInt() ?? 0,
      totalMenuProductsCount:
          (json['totalMenuProductsCount'] as num?)?.toInt() ?? 0,
      totalCustomerCount: (json['totalCustomerCount'] as num?)?.toInt() ?? 0,
      newCustomersTodayCount:
          (json['newCustomersTodayCount'] as num?)?.toInt() ?? 0,
      loyaltyCustomerCount:
          (json['loyaltyCustomerCount'] as num?)?.toInt() ?? 0,
      loyaltyCustomerPercent:
          (json['loyaltyCustomerPercent'] as num?)?.toDouble() ?? 0,
      peakHourLabel: (json['peakHourLabel'] as String?) ?? '',
      peakHourRevenue: (json['peakHourRevenue'] as num?)?.toDouble() ?? 0,
      peakHourOrderCount: (json['peakHourOrderCount'] as num?)?.toInt() ?? 0,
      hourlyTrend: parseTrend(json['hourlyTrend']),
      weeklyTrend: parseTrend(json['weeklyTrend']),
      monthlyTrend: parseTrend(json['monthlyTrend']),
      paymentTotalOrderCount:
          (json['paymentTotalOrderCount'] as num?)?.toInt() ?? 0,
      paymentMethods: parsePayments(json['paymentMethods']),
      topProducts: parseTopProducts(json['topProducts']),
    );
  }

  @override
  List<Object?> get props => [
        todayRevenue,
        yesterdayRevenue,
        revenueChangePercent,
        todayOrderCount,
        yesterdayOrderCount,
        averageOrderValue,
        lowStockProductCount,
        totalMenuProductsCount,
        totalCustomerCount,
        newCustomersTodayCount,
        loyaltyCustomerCount,
        loyaltyCustomerPercent,
        peakHourLabel,
        peakHourRevenue,
        peakHourOrderCount,
        hourlyTrend,
        weeklyTrend,
        monthlyTrend,
        paymentTotalOrderCount,
        paymentMethods,
        topProducts,
      ];
}

// ─── State ─────────────────────────────────────────────────────────────────

abstract class DashboardState extends Equatable {
  const DashboardState();
  @override
  List<Object?> get props => [];
}

class DashboardInitial extends DashboardState {}

class DashboardLoading extends DashboardState {}

class DashboardLoaded extends DashboardState {
  final DashboardSummary summary;
  final DateTime fetchedAt;
  final bool isRefreshing;

  DashboardLoaded({
    required this.summary,
    DateTime? fetchedAt,
    this.isRefreshing = false,
  }) : fetchedAt = fetchedAt ?? DateTime.now();

  @override
  List<Object?> get props => [summary, fetchedAt, isRefreshing];
}

class DashboardError extends DashboardState {
  final String message;
  const DashboardError(this.message);
  @override
  List<Object?> get props => [message];
}

// ─── Cubit ─────────────────────────────────────────────────────────────────

class DashboardCubit extends Cubit<DashboardState> {
  final DioClient _dioClient;

  DashboardCubit({required DioClient dioClient})
      : _dioClient = dioClient,
        super(DashboardInitial());

  Future<void> loadSummary() async {
    final current = state;
    if (current is DashboardLoaded) {
      emit(DashboardLoaded(
        summary: current.summary,
        fetchedAt: current.fetchedAt,
        isRefreshing: true,
      ));
    } else {
      emit(DashboardLoading());
    }

    try {
      final response = await _dioClient.dio.get(ApiEndpoints.dashboardSummary);
      if (response.data != null && response.data['success'] == true) {
        final summary = DashboardSummary.fromJson(
            response.data['data'] as Map<String, dynamic>);
        emit(DashboardLoaded(summary: summary));
      } else {
        emit(DashboardError(
            response.data?['message'] ?? 'Không thể tải dữ liệu dashboard'));
      }
    } catch (e) {
      emit(DashboardError('Lỗi kết nối: $e'));
    }
  }
}
