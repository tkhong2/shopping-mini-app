import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/cart_repository.dart';

class RemoveFromCartUseCase implements UseCase<void, RemoveFromCartParams> {
  final CartRepository repository;

  RemoveFromCartUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(RemoveFromCartParams params) async {
    return await repository.removeFromCart(params.itemId, params.userId);
  }
}

class RemoveFromCartParams {
  final String itemId;
  final String? userId;

  RemoveFromCartParams({
    required this.itemId,
    this.userId,
  });
}