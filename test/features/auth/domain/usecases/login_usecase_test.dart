import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pinar_app/core/errors/failures.dart';
import 'package:pinar_app/features/auth/domain/entities/user_entity.dart';
import 'package:pinar_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:pinar_app/features/auth/domain/usecases/login_usecase.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late LoginUseCase useCase;
  late MockAuthRepository mockRepo;

  const tUser = UserEntity(id: 'uid-1', email: 'test@test.com');

  setUp(() {
    mockRepo = MockAuthRepository();
    useCase = LoginUseCase(mockRepo);
    registerFallbackValue(const LoginParams(email: '', password: ''));
  });

  group('LoginUseCase', () {
    test('devuelve UserEntity cuando el login es exitoso', () async {
      when(() => mockRepo.login(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer((_) async => const Right(tUser));

      final result = await useCase(
          const LoginParams(email: 'test@test.com', password: 'pass123'));

      expect(result, const Right(tUser));
      verify(() => mockRepo.login(
          email: 'test@test.com', password: 'pass123')).called(1);
    });

    test('devuelve AuthFailure con credenciales inválidas', () async {
      when(() => mockRepo.login(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer(
              (_) async => const Left(AuthFailure('Credenciales inválidas')));

      final result = await useCase(
          const LoginParams(email: 'x@x.com', password: 'wrong'));

      expect(result, const Left(AuthFailure('Credenciales inválidas')));
    });

    test('LoginParams con mismo email y password son iguales', () {
      const p1 = LoginParams(email: 'a@a.com', password: '123');
      const p2 = LoginParams(email: 'a@a.com', password: '123');
      expect(p1, equals(p2));
    });
  });
}
