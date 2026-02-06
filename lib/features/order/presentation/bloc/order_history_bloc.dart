import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/usecases/get_order_history_usecase.dart';
import '../../domain/usecases/cancel_order_usecase.dart';

// Events
abstract class OrderHistoryEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadOrderHistoryEvent extends OrderHistoryEvent {
  final String userId;

  LoadOrderHistoryEvent({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class CancelOrderEvent extends OrderHistoryEvent {
  final String orderId;

  CancelOrderEvent({required this.orderId});

  @override
  List<Object?> get props => [orderId];
}

class RefreshOrderHistoryEvent extends OrderHistoryEvent {
  final String userId;

  RefreshOrderHistoryEvent({required this.userId});

  @override
  List<Object?> get props => [userId];
}

// States
abstract class OrderHistoryState extends Equatable {
  @override
  List<Object?> get props => [];
}

class OrderHistoryInitial extends OrderHistoryState {}

class OrderHistoryLoading extends OrderHistoryState {}

class OrderHistoryLoaded extends OrderHistoryState {
  final List<OrderEntity> orders;

  OrderHistoryLoaded({required this.orders});

  @override
  List<Object?> get props => [orders];
}

class OrderHistoryError extends OrderHistoryState {
  final String message;

  OrderHistoryError({required this.message});

  @override
  List<Object?> get props => [message];
}

class OrderCancelling extends OrderHistoryState {
  final String orderId;

  OrderCancelling({required this.orderId});

  @override
  List<Object?> get props => [orderId];
}

class OrderCancelled extends OrderHistoryState {
  final String orderId;
  final List<OrderEntity> orders;

  OrderCancelled({required this.orderId, required this.orders});

  @override
  List<Object?> get props => [orderId, orders];
}

// BLoC
class OrderHistoryBloc extends Bloc<OrderHistoryEvent, OrderHistoryState> {
  final GetOrderHistoryUseCase getOrderHistoryUseCase;
  final CancelOrderUseCase cancelOrderUseCase;

  OrderHistoryBloc({
    required this.getOrderHistoryUseCase,
    required this.cancelOrderUseCase,
  }) : super(OrderHistoryInitial()) {
    on<LoadOrderHistoryEvent>(_onLoadOrderHistory);
    on<CancelOrderEvent>(_onCancelOrder);
    on<RefreshOrderHistoryEvent>(_onRefreshOrderHistory);
  }

  Future<void> _onLoadOrderHistory(
    LoadOrderHistoryEvent event,
    Emitter<OrderHistoryState> emit,
  ) async {
    emit(OrderHistoryLoading());

    final result = await getOrderHistoryUseCase(GetOrderHistoryParams(userId: event.userId));

    result.fold(
      (failure) => emit(OrderHistoryError(message: failure.message)),
      (orders) => emit(OrderHistoryLoaded(orders: orders)),
    );
  }

  Future<void> _onCancelOrder(
    CancelOrderEvent event,
    Emitter<OrderHistoryState> emit,
  ) async {
    final currentState = state;
    if (currentState is OrderHistoryLoaded) {
      emit(OrderCancelling(orderId: event.orderId));

      final result = await cancelOrderUseCase(CancelOrderParams(orderId: event.orderId));

      result.fold(
        (failure) => emit(OrderHistoryError(message: failure.message)),
        (_) {
          final updatedOrders = currentState.orders.map((order) {
            if (order.id == event.orderId) {
              return order.copyWith(status: OrderStatus.cancelled);
            }
            return order;
          }).toList();
          emit(OrderCancelled(orderId: event.orderId, orders: updatedOrders));
        },
      );
    }
  }

  Future<void> _onRefreshOrderHistory(
    RefreshOrderHistoryEvent event,
    Emitter<OrderHistoryState> emit,
  ) async {
    final result = await getOrderHistoryUseCase(GetOrderHistoryParams(userId: event.userId));

    result.fold(
      (failure) => emit(OrderHistoryError(message: failure.message)),
      (orders) => emit(OrderHistoryLoaded(orders: orders)),
    );
  }
}