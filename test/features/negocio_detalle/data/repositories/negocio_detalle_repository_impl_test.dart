import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cubamap/core/errors/failures.dart';
import 'package:cubamap/features/negocio_detalle/data/datasources/negocio_detalle_datasource.dart';
import 'package:cubamap/features/negocio_detalle/data/models/negocio_detalle_model.dart';
import 'package:cubamap/features/negocio_detalle/data/repositories/negocio_detalle_repository_impl.dart';
import 'package:cubamap/features/negocio_detalle/domain/entities/negocio_detalle.dart';

class MockNegocioDetalleDataSource extends Mock
    implements NegocioDetalleDataSource {}

void main() {
  late NegocioDetalleRepositoryImpl repo;
  late MockNegocioDetalleDataSource mockDataSource;

  const tId = 'a0000000-0000-0000-0000-000000000001';

  final tModel = NegocioDetalleModel(
    id: tId,
    nombre: 'La Panadería Elena',
    categoria: 'Panadería',
    abierto: true,
    verificado: true,
    calificacion: 4.9,
    totalResenas: 12,
    direccion: 'Calle Martí 23',
    distanciaKm: 0.3,
    productos: const [],
  );

  setUp(() {
    mockDataSource = MockNegocioDetalleDataSource();
    repo = NegocioDetalleRepositoryImpl(mockDataSource);
  });

  group('getNegocioDetalle', () {
    test('devuelve Right(NegocioDetalle) cuando el datasource tiene éxito',
        () async {
      when(() => mockDataSource.getNegocioDetalle(tId))
          .thenAnswer((_) async => tModel);

      final result = await repo.getNegocioDetalle(tId);

      expect(result, isA<Right<Failure, NegocioDetalle>>());
      result.fold(
        (_) => fail('debería ser Right'),
        (negocio) {
          expect(negocio.id, tId);
          expect(negocio.nombre, 'La Panadería Elena');
          expect(negocio.calificacion, 4.9);
        },
      );
    });

    test('devuelve Left(ServerFailure) cuando el datasource lanza Exception',
        () async {
      when(() => mockDataSource.getNegocioDetalle(tId))
          .thenThrow(Exception('Negocio no encontrado'));

      final result = await repo.getNegocioDetalle(tId);

      expect(result, isA<Left<Failure, NegocioDetalle>>());
      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (_) => fail('debería ser Left'),
      );
    });

    test('llama al datasource con el id correcto', () async {
      when(() => mockDataSource.getNegocioDetalle(tId))
          .thenAnswer((_) async => tModel);

      await repo.getNegocioDetalle(tId);

      verify(() => mockDataSource.getNegocioDetalle(tId)).called(1);
    });
  });
}
