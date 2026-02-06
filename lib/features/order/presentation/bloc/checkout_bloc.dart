import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/usecases/create_order_usecase.dart';

// Events
abstract class CheckoutEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class CreateOrderEvent extends CheckoutEvent {
  final OrderEntity order;

  CreateOrderEvent({required this.order});

  @override
  List<Object?> get props => [order];
}

class ResetCheckoutEvent extends CheckoutEvent {}

// States
abstract class CheckoutState extends Equatable {
  @override
  List<Object?> get props => [];
}

class CheckoutInitial extends CheckoutState {}

class CheckoutLoading extends CheckoutState {}

class CheckoutSuccess extends CheckoutState {
  final OrderEntity order;

  CheckoutSuccess({required this.order});

  @override
  List<Object?> get props => [order];
}

class CheckoutError extends CheckoutState {
  final String message;

  CheckoutError({required this.message});

  @override
  List<Object?> get props => [message];
}

// BLoC
class CheckoutBloc extends Bloc<CheckoutEvent, CheckoutState> {
  final CreateOrderUseCase createOrderUseCase;

  CheckoutBloc({
    required this.createOrderUseCase,
  }) : super(CheckoutInitial()) {
    on<CreateOrderEvent>(_onCreateOrder);
    on<ResetCheckoutEvent>(_onResetCheckout);
  }

  Future<void> _onCreateOrder(
    CreateOrderEvent event,
    Emitter<CheckoutState> emit,
  ) async {
    emit(CheckoutLoading());

    final result = await createOrderUseCase(CreateOrderParams(order: event.order));

    result.fold(
      (failure) => emit(CheckoutError(message: failure.message)),
      (order) => emit(CheckoutSuccess(order: order)),
    );
  }

  void _onResetCheckout(
    ResetCheckoutEvent event,
    Emitter<CheckoutState> emit,
  ) {
    emit(CheckoutInitial());
  }
}