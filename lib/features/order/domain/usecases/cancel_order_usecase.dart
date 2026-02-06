import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/order_repository.dart';

class CancelOrderUseCase implements UseCase<void, CancelOrderParams> {
  final OrderRepository repository;

  CancelOrderUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(CancelOrderParams params) async {
    return await repository.cancelOrder(params.orderId);
  }
}

class CancelOrderParams extends Equatable {
  final String orderId;

  const CancelOrderParams({required this.orderId});

  @override
  List<Object?> get props => [orderId];
}