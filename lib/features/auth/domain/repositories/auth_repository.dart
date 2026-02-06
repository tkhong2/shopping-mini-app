import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, UserEntity>> login({
    required String email,
    required String password,
  });

  Future<Either<Failure, UserEntity>> register({
    required String email,
    required String password,
    required String displayName,
    String? phoneNumber,
  });

  Future<Either<Failure, void>> logout();

  Future<Either<Failure, void>> forgotPassword({
    required String email,
  });

  Future<Either<Failure, UserEntity?>> getCurrentUser();

  Future<Either<Failure, UserEntity>> updateProfile({
    required String userId,
    String? displayName,
    String? phoneNumber,
    String? photoURL,
  });

  Future<Either<Failure, void>> changePassword({
    required String currentPassword,
    required String newPassword,
  });

  Future<Either<Failure, void>> sendEmailVerification();

  Stream<UserEntity?> get authStateChanges;
}