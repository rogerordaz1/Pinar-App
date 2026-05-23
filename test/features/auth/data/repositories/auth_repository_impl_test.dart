import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pinar_app/core/errors/exceptions.dart';
import 'package:pinar_app/core/errors/failures.dart';
import 'package:pinar_app/features/auth/data/datasources/auth_datasource.dart';
import 'package:pinar_app/features/auth/data/models/user_model.dart';
import 'package:pinar_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:pinar_app/features/auth/domain/entities/user_entity.dart';

class MockAuthDataSource extends Mock implements AuthDataSource {}

void main() {
  late AuthRepositoryImpl repo;
  late MockAuthDataSource mockDataSource;

  const tModel = UserModel(id: 'uid-1', email: 'test@test.com');
  const tEntity = UserEntity(id: 'uid-1', email: 'test@test.com');

  setUp(() {
    mockDataSource = MockAuthDataSource();
    repo = AuthRepositoryImpl(mockDataSource);
  });

  group('login', () {
    test('devuelve UserEntity cuando el datasource tiene éxito', () async {
      when(() => mockDataSource.login(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer((_) async => tModel);

      final result =
          await repo.login(email: 'test@test.com', password: 'pass123');

      expect(result, const Right(tEntity));
    });

    test('devuelve AuthFailure cuando el datasource lanza AuthException',
        () async {
      when(() => mockDataSource.login(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenThrow(const AuthException('Credenciales inválidas'));

      final result = await repo.login(email: 'x@x.com', password: 'wrong');

      expect(result, const Left(AuthFailure('Credenciales inválidas')));
    });

    test('devuelve ServerFailure cuando el datasource lanza Exception genérica',
        () async {
      when(() => mockDataSource.login(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenThrow(const ServerException('Error de red'));

      final result = await repo.login(email: 'x@x.com', password: 'pass');

      expect(result, const Left(ServerFailure('Error de red')));
    });
  });

  group('register', () {
    test('devuelve UserEntity cuando el datasource tiene éxito', () async {
      when(() => mockDataSource.register(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer((_) async => tModel);

      final result =
          await repo.register(email: 'test@test.com', password: 'pass123');

      expect(result, const Right(tEntity));
    });

    test('devuelve AuthFailure cuando el datasource lanza AuthException',
        () async {
      when(() => mockDataSource.register(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenThrow(const AuthException('Email ya registrado'));

      final result =
          await repo.register(email: 'existe@test.com', password: 'pass');

      expect(result, const Left(AuthFailure('Email ya registrado')));
    });
  });

  group('logout', () {
    test('devuelve Right(null) cuando el datasource tiene éxito', () async {
      when(() => mockDataSource.logout()).thenAnswer((_) async {});

      final result = await repo.logout();

      expect(result.isRight(), true);
    });

    test('devuelve ServerFailure cuando el datasource lanza Exception',
        () async {
      when(() => mockDataSource.logout())
          .thenThrow(const ServerException('Error al cerrar sesión'));

      final result = await repo.logout();

      expect(result, const Left(ServerFailure('Error al cerrar sesión')));
    });
  });

  group('getCurrentUser', () {
    test('devuelve UserEntity cuando hay sesión activa', () async {
      when(() => mockDataSource.getCurrentUser())
          .thenAnswer((_) async => tModel);

      final result = await repo.getCurrentUser();

      expect(result, const Right(tEntity));
    });

    test('devuelve Right(null) cuando no hay sesión activa', () async {
      when(() => mockDataSource.getCurrentUser())
          .thenAnswer((_) async => null);

      final result = await repo.getCurrentUser();

      expect(result, const Right(null));
    });
  });
}
