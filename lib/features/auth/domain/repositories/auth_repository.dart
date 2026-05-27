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
    String? fullName,
  });

  Future<Either<Failure, void>> logout();

  Future<Either<Failure, UserEntity?>> getCurrentUser();

  Future<Either<Failure, void>> loginWithGoogle();
  Future<Either<Failure, void>> forgotPassword({required String email});

  Future<Either<Failure, void>> verifyResetOtp({
    required String email,
    required String token,
  });

  Future<Either<Failure, void>> resetPassword({required String newPassword});
}
