import 'package:equatable/equatable.dart';
import '../../domain/entities/order_entity.dart';

abstract class OrderState extends Equatable {
  const OrderState();
  @override
  List<Object?> get props => [];
}

class OrderInitial extends OrderState {}

class OrderLoading extends OrderState {}

class OrderCreated extends OrderState {
  final OrderEntity order;
  const OrderCreated(this.order);
  @override
  List<Object?> get props => [order];
}

class OrderError extends OrderState {
  final String message;
  const OrderError(this.message);
  @override
  List<Object?> get props => [message];
}

class OrdersLoaded extends OrderState {
  final List<OrderEntity> orders;
  final bool isLoadingMore;

  const OrdersLoaded({required this.orders, this.isLoadingMore = false});

  @override
  List<Object?> get props => [orders, isLoadingMore];
}
