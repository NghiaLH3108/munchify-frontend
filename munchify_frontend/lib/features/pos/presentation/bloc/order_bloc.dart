import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/create_order_usecase.dart';
import '../../domain/usecases/get_orders_usecase.dart';
import 'order_event.dart';
import 'order_state.dart';

class OrderBloc extends Bloc<OrderEvent, OrderState> {
  final CreateOrderUseCase createOrderUseCase;
  final GetOrdersUseCase getOrdersUseCase;

  OrderBloc({
    required this.createOrderUseCase,
    required this.getOrdersUseCase,
  }) : super(OrderInitial()) {
    on<CreateOrderEvent>(_onCreateOrder);
    on<LoadOrdersEvent>(_onLoadOrders);
  }

  Future<void> _onCreateOrder(
    CreateOrderEvent event,
    Emitter<OrderState> emit,
  ) async {
    emit(OrderLoading());

    final result = await createOrderUseCase.execute(
      customerId: event.customerId,
      promotionCode: event.promotionCode,
      paymentMethod: event.paymentMethod,
      pointsToRedeem: event.pointsToRedeem,
      cashGiven: event.cashGiven,
      items: event.items,
    );

    result.fold(
      (failure) => emit(OrderError(failure.message)),
      (order) => emit(OrderCreated(order)),
    );
  }

  Future<void> _onLoadOrders(
    LoadOrdersEvent event,
    Emitter<OrderState> emit,
  ) async {
    emit(OrderLoading());

    final result = await getOrdersUseCase.execute(
      page: event.page,
      pageSize: event.pageSize,
    );

    result.fold(
      (failure) => emit(OrderError(failure.message)),
      (orders) => emit(OrdersLoaded(orders: orders)),
    );
  }
}
