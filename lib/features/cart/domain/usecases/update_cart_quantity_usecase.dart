import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/cart_item_entity.dart';
import '../repositories/cart_repository.dart';

class UpdateCartQuantityUseCase implements UseCase<void, UpdateCartQuantityParams> {
  final CartRepository repository;

  UpdateCartQuantityUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(UpdateCartQuantityParams params) async {
    return await repository.updateCartItem(params.item, params.userId);
  }
}

class UpdateCartQuantityParams {
  final CartItemEntity item;
  final String? userId;

  UpdateCartQuantityParams({
    required this.item,
    this.userId,
  });
}