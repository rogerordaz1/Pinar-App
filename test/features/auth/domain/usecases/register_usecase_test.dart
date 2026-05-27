import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cubamap/core/errors/failures.dart';
import 'package:cubamap/features/auth/domain/entities/user_entity.dart';
import 'package:cubamap/features/auth/domain/repositories/auth_repository.dart';
import 'package:cubamap/features/auth/domain/usecases/register_usecase.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late RegisterUseCase useCase;
  late MockAuthRepository mockRepo;

  const tUser = UserEntity(id: 'uid-2', email: 'nuevo@test.com');

  setUp(() {
    mockRepo = MockAuthRepository();
    useCase = RegisterUseCase(mockRepo);
    registerFallbackValue(const RegisterParams(email: '', password: ''));
  });

  group('RegisterUseCase', () {
    test('devuelve UserEntity cuando el registro es exitoso', () async {
      when(() => mockRepo.register(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer((_) async => const Right(tUser));

      final result = await useCase(
          const RegisterParams(email: 'nuevo@test.com', password: 'pass123'));

      expect(result, const Right(tUser));
    });

    test('devuelve AuthFailure cuando el email ya está registrado', () async {
      when(() => mockRepo.register(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer(
              (_) async => const Left(AuthFailure('Email ya registrado')));

      final result = await useCase(
          const RegisterParams(email: 'existe@test.com', password: 'pass'));

      expect(result, const Left(AuthFailure('Email ya registrado')));
    });

    test('RegisterParams con mismo email y password son iguales', () {
      const p1 = RegisterParams(email: 'a@a.com', password: '123');
      const p2 = RegisterParams(email: 'a@a.com', password: '123');
      expect(p1, equals(p2));
    });
  });
}
