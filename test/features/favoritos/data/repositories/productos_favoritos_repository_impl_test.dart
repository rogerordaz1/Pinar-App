// test/features/favoritos/data/repositories/productos_favoritos_repository_impl_test.dart
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cubamap/core/errors/failures.dart';
import 'package:cubamap/features/favoritos/data/datasources/favoritos_datasource.dart';
import 'package:cubamap/features/favoritos/data/models/producto_favorito_model.dart';
import 'package:cubamap/features/favoritos/data/repositories/productos_favoritos_repository_impl.dart';
import 'package:cubamap/features/favoritos/domain/entities/producto_favorito.dart';

class MockFavoritosDataSource extends Mock implements FavoritosDataSource {}

void main() {
  late ProductosFavoritosRepositoryImpl repo;
  late MockFavoritosDataSource mockDs;

  final tModel = ProductoFavoritoModel(
    id: 'fav002',
    productoId: 'p001',
    productoNombre: 'Pan Criollo',
    negocioId: 'n001',
    negocioNombre: 'Panadería Elena',
    precio: 25.0,
    imageUrl: null,
    negocioAbierto: true,
    createdAt: DateTime(2026, 5, 29),
  );

  setUp(() {
    mockDs = MockFavoritosDataSource();
    repo = ProductosFavoritosRepositoryImpl(mockDs);
  });

  group('getProductos', () {
    test('devuelve Right(List<ProductoFavorito>) cuando el datasource tiene éxito',
        () async {
      when(() => mockDs.getProductos()).thenAnswer((_) async => [tModel]);

      final result = await repo.getProductos();

      expect(result, isA<Right<Failure, List<ProductoFavorito>>>());
      result.fold(
        (_) => fail('debería ser Right'),
        (list) {
          expect(list.length, 1);
          expect(list.first.productoNombre, 'Pan Criollo');
        },
      );
    });

    test('devuelve Left(ServerFailure) cuando el datasource lanza Exception',
        () async {
      when(() => mockDs.getProductos()).thenThrow(Exception('error de red'));

      final result = await repo.getProductos();

      expect(result, isA<Left<Failure, List<ProductoFavorito>>>());
      result.fold(
        (f) => expect(f, isA<ServerFailure>()),
        (_) => fail('debería ser Left'),
      );
    });
  });

  group('addProducto', () {
    test('devuelve Right(void) cuando el datasource tiene éxito', () async {
      when(() => mockDs.addProducto('p001', 'n001'))
          .thenAnswer((_) async {});

      final result = await repo.addProducto('p001', 'n001');

      expect(result, isA<Right<Failure, void>>());
    });

    test('devuelve Left(ServerFailure) cuando el datasource lanza Exception',
        () async {
      when(() => mockDs.addProducto('p001', 'n001'))
          .thenThrow(Exception('error'));

      final result = await repo.addProducto('p001', 'n001');

      expect(result, isA<Left<Failure, void>>());
    });
  });

  group('removeProducto', () {
    test('devuelve Right(void) cuando el datasource tiene éxito', () async {
      when(() => mockDs.removeProducto('p001')).thenAnswer((_) async {});

      final result = await repo.removeProducto('p001');

      expect(result, isA<Right<Failure, void>>());
    });

    test('devuelve Left(ServerFailure) cuando el datasource lanza Exception',
        () async {
      when(() => mockDs.removeProducto('p001')).thenThrow(Exception('error'));

      final result = await repo.removeProducto('p001');

      expect(result, isA<Left<Failure, void>>());
    });
  });
}
