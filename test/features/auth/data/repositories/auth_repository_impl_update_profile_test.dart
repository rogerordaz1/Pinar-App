import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cubamap/core/errors/exceptions.dart';
import 'package:cubamap/core/errors/failures.dart';
import 'package:cubamap/features/auth/data/datasources/auth_datasource.dart';
import 'package:cubamap/features/auth/data/models/user_model.dart';
import 'package:cubamap/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:cubamap/features/auth/domain/usecases/update_profile_usecase.dart';

class MockAuthDataSource extends Mock implements AuthDataSource {}

void main() {
  late AuthRepositoryImpl repository;
  late MockAuthDataSource mockDataSource;

  setUpAll(() {
    registerFallbackValue(const UpdateProfileParams(nombre: ''));
  });

  setUp(() {
    mockDataSource = MockAuthDataSource();
    repository = AuthRepositoryImpl(mockDataSource);
  });

  const tParams = UpdateProfileParams(
    nombre: 'Roger',
    direccion: 'Calle 10, Pinar del Río',
    lat: 22.4167,
    lng: -83.6833,
  );

  final tUserModel = UserModel(
    id: 'user-id',
    email: 'roger@test.com',
    nombre: 'Roger',
    direccion: 'Calle 10, Pinar del Río',
    lat: 22.4167,
    lng: -83.6833,
  );

  group('updateProfile', () {
    test('devuelve Right(UserEntity) cuando el datasource tiene éxito',
        () async {
      when(() => mockDataSource.updateProfile(tParams))
          .thenAnswer((_) async => tUserModel);

      final result = await repository.updateProfile(tParams);

      expect(result, Right(tUserModel.toEntity()));
    });

    test('llama al datasource con los params correctos', () async {
      when(() => mockDataSource.updateProfile(tParams))
          .thenAnswer((_) async => tUserModel);

      await repository.updateProfile(tParams);

      verify(() => mockDataSource.updateProfile(tParams)).called(1);
    });

    test('devuelve Left(ServerFailure) cuando datasource lanza ServerException',
        () async {
      when(() => mockDataSource.updateProfile(any()))
          .thenThrow(const ServerException('Error de servidor'));

      final result = await repository.updateProfile(tParams);

      expect(result, const Left(ServerFailure('Error de servidor')));
    });

    test('devuelve Left(ServerFailure) cuando datasource lanza Exception genérica',
        () async {
      when(() => mockDataSource.updateProfile(any()))
          .thenThrow(Exception('Error desconocido'));

      final result = await repository.updateProfile(tParams);

      expect(result.isLeft(), true);
    });
  });
}
