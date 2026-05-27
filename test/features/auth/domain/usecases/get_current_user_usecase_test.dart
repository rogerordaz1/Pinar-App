import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cubamap/core/errors/failures.dart';
import 'package:cubamap/core/usecases/usecase.dart';
import 'package:cubamap/features/auth/domain/entities/user_entity.dart';
import 'package:cubamap/features/auth/domain/repositories/auth_repository.dart';
import 'package:cubamap/features/auth/domain/usecases/get_current_user_usecase.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late GetCurrentUserUseCase useCase;
  late MockAuthRepository mockRepo;

  const tUser = UserEntity(id: 'uid-1', email: 'test@test.com');

  setUp(() {
    mockRepo = MockAuthRepository();
    useCase = GetCurrentUserUseCase(mockRepo);
  });

  group('GetCurrentUserUseCase', () {
    test('devuelve UserEntity cuando hay sesión activa', () async {
      when(() => mockRepo.getCurrentUser())
          .thenAnswer((_) async => const Right(tUser));

      final result = await useCase(const NoParams());

      expect(result, const Right(tUser));
    });

    test('devuelve Right(null) cuando no hay sesión', () async {
      when(() => mockRepo.getCurrentUser())
          .thenAnswer((_) async => const Right(null));

      final result = await useCase(const NoParams());

      expect(result, const Right(null));
    });

    test('devuelve ServerFailure si ocurre un error', () async {
      when(() => mockRepo.getCurrentUser()).thenAnswer(
          (_) async => const Left(ServerFailure('Error de sesión')));

      final result = await useCase(const NoParams());

      expect(result, const Left(ServerFailure('Error de sesión')));
    });
  });
}
