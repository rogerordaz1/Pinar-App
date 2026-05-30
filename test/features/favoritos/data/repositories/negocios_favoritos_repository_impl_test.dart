// test/features/favoritos/data/repositories/negocios_favoritos_repository_impl_test.dart
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cubamap/core/errors/failures.dart';
import 'package:cubamap/features/favoritos/data/datasources/favoritos_datasource.dart';
import 'package:cubamap/features/favoritos/data/models/negocio_favorito_model.dart';
import 'package:cubamap/features/favoritos/data/repositories/negocios_favoritos_repository_impl.dart';
import 'package:cubamap/features/favoritos/domain/entities/negocio_favorito.dart';

class MockFavoritosDataSource extends Mock implements FavoritosDataSource {}

void main() {
  late NegociosFavoritosRepositoryImpl repo;
  late MockFavoritosDataSource mockDs;

  final tModel = NegocioFavoritoModel(
    id: 'fav001',
    negocioId: 'n001',
    negocioNombre: 'Panadería Elena',
    logoUrl: null,
    negocioAbierto: true,
    calificacion: 4.8,
    negocioVerificado: true,
    createdAt: DateTime(2026, 5, 29),
  );

  setUp(() {
    mockDs = MockFavoritosDataSource();
    repo = NegociosFavoritosRepositoryImpl(mockDs);
  });

  group('getNegocios', () {
    test('devuelve Right(List<NegocioFavorito>) cuando el datasource tiene éxito',
        () async {
      when(() => mockDs.getNegocios()).thenAnswer((_) async => [tModel]);

      final result = await repo.getNegocios();

      expect(result, isA<Right<Failure, List<NegocioFavorito>>>());
      result.fold(
        (_) => fail('debería ser Right'),
        (list) {
          expect(list.length, 1);
          expect(list.first.negocioNombre, 'Panadería Elena');
        },
      );
    });

    test('devuelve Left(ServerFailure) cuando el datasource lanza Exception',
        () async {
      when(() => mockDs.getNegocios()).thenThrow(Exception('error de red'));

      final result = await repo.getNegocios();

      expect(result, isA<Left<Failure, List<NegocioFavorito>>>());
      result.fold(
        (f) => expect(f, isA<ServerFailure>()),
        (_) => fail('debería ser Left'),
      );
    });

    test('llama al datasource una vez', () async {
      when(() => mockDs.getNegocios()).thenAnswer((_) async => [tModel]);
      await repo.getNegocios();
      verify(() => mockDs.getNegocios()).called(1);
    });
  });

  group('addNegocio', () {
    test('devuelve Right(void) cuando el datasource tiene éxito', () async {
      when(() => mockDs.addNegocio('n001')).thenAnswer((_) async {});

      final result = await repo.addNegocio('n001');

      expect(result, isA<Right<Failure, void>>());
    });

    test('devuelve Left(ServerFailure) cuando el datasource lanza Exception',
        () async {
      when(() => mockDs.addNegocio('n001')).thenThrow(Exception('error'));

      final result = await repo.addNegocio('n001');

      expect(result, isA<Left<Failure, void>>());
    });
  });

  group('removeNegocio', () {
    test('devuelve Right(void) cuando el datasource tiene éxito', () async {
      when(() => mockDs.removeNegocio('n001')).thenAnswer((_) async {});

      final result = await repo.removeNegocio('n001');

      expect(result, isA<Right<Failure, void>>());
    });

    test('devuelve Left(ServerFailure) cuando el datasource lanza Exception',
        () async {
      when(() => mockDs.removeNegocio('n001')).thenThrow(Exception('error'));

      final result = await repo.removeNegocio('n001');

      expect(result, isA<Left<Failure, void>>());
    });
  });
}
