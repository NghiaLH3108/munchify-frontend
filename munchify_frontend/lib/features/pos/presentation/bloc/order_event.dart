import 'package:equatable/equatable.dart';

abstract class OrderEvent extends Equatable {
  const OrderEvent();
  @override
  List<Object?> get props => [];
}

class CreateOrderEvent extends OrderEvent {
  final int? customerId;
  final String? promotionCode;
  final String paymentMethod;
  final int pointsToRedeem;
  final List<Map<String, int>> items;

  const CreateOrderEvent({
    this.customerId,
    this.promotionCode,
    required this.paymentMethod,
    this.pointsToRedeem = 0,
    required this.items,
  });

  @override
  List<Object?> get props => [
        customerId,
        promotionCode,
        paymentMethod,
        pointsToRedeem,
        items,
      ];
}

class LoadOrdersEvent extends OrderEvent {
  final int page;
  final int pageSize;

  const LoadOrdersEvent({this.page = 1, this.pageSize = 20});

  @override
  List<Object?> get props => [page, pageSize];
}
