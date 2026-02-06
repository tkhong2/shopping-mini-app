import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/order_entity.dart';

abstract class OrderRepository {
  Future<Either<Failure, OrderEntity>> createOrder(OrderEntity order);
  Future<Either<Failure, List<OrderEntity>>> getOrderHistory(String userId);
  Future<Either<Failure, void>> cancelOrder(String orderId);
}