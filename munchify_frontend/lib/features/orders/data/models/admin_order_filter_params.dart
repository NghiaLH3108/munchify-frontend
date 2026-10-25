import 'package:intl/intl.dart';

class AdminOrderFilterParams {
  final String? searchQuery;
  final String? orderStatus;
  final String? paymentMethod;
  final DateTime? fromDate;
  final DateTime? toDate;
  final int page;
  final int pageSize;

  const AdminOrderFilterParams({
    this.searchQuery,
    this.orderStatus,
    this.paymentMethod,
    this.fromDate,
    this.toDate,
    this.page = 1,
    this.pageSize = 10,
  });

  AdminOrderFilterParams copyWith({
    String? searchQuery,
    bool clearSearch = false,
    String? orderStatus,
    bool clearStatus = false,
    String? paymentMethod,
    bool clearMethod = false,
    DateTime? fromDate,
    DateTime? toDate,
    bool clearDate = false,
    int? page,
    int? pageSize,
  }) {
    final bool shouldClearSearch = clearSearch || (searchQuery != null && searchQuery.trim().isEmpty);
    final bool shouldClearStatus = clearStatus || (orderStatus != null && (orderStatus == 'ALL' || orderStatus.trim().isEmpty));
    final bool shouldClearMethod = clearMethod || (paymentMethod != null && (paymentMethod == 'ALL' || paymentMethod.trim().isEmpty));

    return AdminOrderFilterParams(
      searchQuery: shouldClearSearch ? null : (searchQuery ?? this.searchQuery),
      orderStatus: shouldClearStatus ? null : (orderStatus ?? this.orderStatus),
      paymentMethod: shouldClearMethod ? null : (paymentMethod ?? this.paymentMethod),
      fromDate: clearDate ? null : (fromDate ?? this.fromDate),
      toDate: clearDate ? null : (toDate ?? this.toDate),
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
    );
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'page': page,
      'pageSize': pageSize,
    };

    if (searchQuery != null && searchQuery!.trim().isNotEmpty) {
      map['searchQuery'] = searchQuery!.trim();
    }

    if (orderStatus != null && orderStatus != 'ALL' && orderStatus!.isNotEmpty) {
      map['orderStatus'] = orderStatus;
    }

    if (paymentMethod != null && paymentMethod != 'ALL' && paymentMethod!.isNotEmpty) {
      map['paymentMethod'] = paymentMethod;
    }

    final df = DateFormat('yyyy-MM-dd');
    if (fromDate != null) {
      map['fromDate'] = df.format(fromDate!);
    }
    if (toDate != null) {
      map['toDate'] = df.format(toDate!);
    }

    return map;
  }
}
