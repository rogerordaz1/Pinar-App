import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cubamap/core/errors/failures.dart';
import 'package:cubamap/features/busqueda/data/models/resultado_busqueda_model.dart';
import 'package:cubamap/features/busqueda/domain/entities/resultado_busqueda.dart';
import 'package:cubamap/features/categoria_productos/data/datasources/categoria_productos_datasource.dart';
import 'package:cubamap/features/categoria_productos/data/repositories/categoria_productos_repository_impl.dart';
import 'package:cubamap/features/categoria_productos/domain/usecases/get_productos_por_categoria_usecase.dart';

class MockCategoriaProductosDataSource extends Mock
    implements CategoriaProductosDataSource {}

void main() {
  late CategoriaProductosRepositoryImpl repo;
  late MockCategoriaProductosDataSource mockDataSource;

  const tParams = CategoriaParams(
    categoriaId: 'cat-001',
    categoriaNombre: 'Panadería',
  );

  final tModel = ResultadoBusquedaModel(
    negocioId: 'n001',
    negocioNombre: 'Panadería Elena',
    negocioDireccion: 'Calle Martí 23',
    negocioAbierto: true,
    negocioVerificado: true,
    productoId: 'p001',
    productoNombre: 'Pan Criollo',
    precio: 25.0,
    disponible: true,
    actualizadoHace: 'Reciente',
    distanciaMetros: 300.0,
    calificacion: 4.8,
  );

  setUp(() {
    mockDataSource = MockCategoriaProductosDataSource();
    repo = CategoriaProductosRepositoryImpl(mockDataSource);
  });

  group('getProductosPorCategoria', () {
    test('devuelve Right(List<ResultadoBusqueda>) cuando el datasource tiene éxito',
        () async {
      when(() => mockDataSource.getProductosPorCategoria(tParams))
          .thenAnswer((_) async => [tModel]);

      final result = await repo.getProductosPorCategoria(tParams);

      expect(result, isA<Right<Failure, List<ResultadoBusqueda>>>());
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
      when(() => mockDataSource.getProductosPorCategoria(tParams))
          .thenThrow(Exception('Error de red'));

      final result = await repo.getProductosPorCategoria(tParams);

      expect(result, isA<Left<Failure, List<ResultadoBusqueda>>>());
      result.fold(
        (f) => expect(f, isA<ServerFailure>()),
        (_) => fail('debería ser Left'),
      );
    });

    test('llama al datasource con los params correctos', () async {
      when(() => mockDataSource.getProductosPorCategoria(tParams))
          .thenAnswer((_) async => []);

      await repo.getProductosPorCategoria(tParams);

      verify(() => mockDataSource.getProductosPorCategoria(tParams)).called(1);
    });
  });
}
