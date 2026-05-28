import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cubamap/core/errors/failures.dart';
import 'package:cubamap/features/busqueda/data/datasources/busqueda_datasource.dart';
import 'package:cubamap/features/busqueda/data/models/negocio_recomendado_model.dart';
import 'package:cubamap/features/busqueda/data/models/resultado_busqueda_model.dart';
import 'package:cubamap/features/busqueda/data/repositories/busqueda_repository_impl.dart';
import 'package:cubamap/features/busqueda/domain/entities/negocio_recomendado.dart';
import 'package:cubamap/features/busqueda/domain/entities/resultado_busqueda.dart';
import 'package:cubamap/features/busqueda/domain/usecases/buscar_productos_usecase.dart';

class MockBusquedaDataSource extends Mock implements BusquedaDataSource {}

void main() {
  late BusquedaRepositoryImpl repo;
  late MockBusquedaDataSource mockDataSource;

  const tParams = BusquedaParams(termino: 'pan');

  final tResultadoModel = ResultadoBusquedaModel(
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

  final tRecomendadoModel = NegocioRecomendadoModel(
    id: 'n001',
    nombre: 'Panadería Elena',
    calificacion: 4.8,
    distanciaKm: 0.3,
  );

  setUp(() {
    mockDataSource = MockBusquedaDataSource();
    repo = BusquedaRepositoryImpl(mockDataSource);
  });

  group('buscarProductos', () {
    test('devuelve Right(List<ResultadoBusqueda>) cuando el datasource tiene éxito',
        () async {
      when(() => mockDataSource.buscarProductos(tParams))
          .thenAnswer((_) async => [tResultadoModel]);

      final result = await repo.buscarProductos(tParams);

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
      when(() => mockDataSource.buscarProductos(tParams))
          .thenThrow(Exception('Error de red'));

      final result = await repo.buscarProductos(tParams);

      expect(result, isA<Left<Failure, List<ResultadoBusqueda>>>());
      result.fold(
        (f) => expect(f, isA<ServerFailure>()),
        (_) => fail('debería ser Left'),
      );
    });

    test('llama al datasource con los params correctos', () async {
      when(() => mockDataSource.buscarProductos(tParams))
          .thenAnswer((_) async => []);

      await repo.buscarProductos(tParams);

      verify(() => mockDataSource.buscarProductos(tParams)).called(1);
    });
  });

  group('getNegociosRecomendados', () {
    test('devuelve Right(List<NegocioRecomendado>) cuando el datasource tiene éxito',
        () async {
      when(() => mockDataSource.getNegociosRecomendados())
          .thenAnswer((_) async => [tRecomendadoModel]);

      final result = await repo.getNegociosRecomendados();

      expect(result, isA<Right<Failure, List<NegocioRecomendado>>>());
      result.fold(
        (_) => fail('debería ser Right'),
        (list) => expect(list.first.nombre, 'Panadería Elena'),
      );
    });

    test('devuelve Left(ServerFailure) cuando el datasource lanza Exception',
        () async {
      when(() => mockDataSource.getNegociosRecomendados())
          .thenThrow(Exception('Sin conexión'));

      final result = await repo.getNegociosRecomendados();

      expect(result, isA<Left<Failure, List<NegocioRecomendado>>>());
    });
  });
}
