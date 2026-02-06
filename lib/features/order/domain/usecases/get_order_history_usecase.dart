import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/order_entity.dart';
import '../repositories/order_repository.dart';

class GetOrderHistoryUseCase implements UseCase<List<OrderEntity>, GetOrderHistoryParams> {
  final OrderRepository repository;

  GetOrderHistoryUseCase(this.repository);

  @override
  Future<Either<Failure, List<OrderEntity>>> call(GetOrderHistoryParams params) async {
    return await repository.getOrderHistory(params.userId);
  }
}

class GetOrderHistoryParams extends Equatable {
  final String userId;

  const GetOrderHistoryParams({required this.userId});

  @override
  List<Object?> get props => [userId];
}