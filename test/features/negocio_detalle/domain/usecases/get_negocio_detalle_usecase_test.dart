import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cubamap/core/errors/failures.dart';
import 'package:cubamap/features/negocio_detalle/domain/entities/negocio_detalle.dart';
import 'package:cubamap/features/negocio_detalle/domain/repositories/negocio_detalle_repository.dart';
import 'package:cubamap/features/negocio_detalle/domain/usecases/get_negocio_detalle_usecase.dart';

class MockNegocioDetalleRepository extends Mock
    implements NegocioDetalleRepository {}

void main() {
  late GetNegocioDetalleUseCase useCase;
  late MockNegocioDetalleRepository mockRepo;

  const tId = 'a0000000-0000-0000-0000-000000000001';
  const tNegocio = NegocioDetalle(
    id: tId,
    nombre: 'La Panadería Elena',
    categoria: 'Panadería',
    abierto: true,
    distanciaKm: 0.3,
    calificacion: 4.9,
    totalResenas: 12,
    direccion: 'Calle Martí 23',
  );

  setUp(() {
    mockRepo = MockNegocioDetalleRepository();
    useCase = GetNegocioDetalleUseCase(mockRepo);
  });

  test('delega la llamada al repositorio con el id correcto', () async {
    when(() => mockRepo.getNegocioDetalle(tId))
        .thenAnswer((_) async => const Right(tNegocio));

    final result = await useCase(tId);

    expect(result, const Right(tNegocio));
    verify(() => mockRepo.getNegocioDetalle(tId)).called(1);
    verifyNoMoreInteractions(mockRepo);
  });

  test('propaga el Failure del repositorio', () async {
    when(() => mockRepo.getNegocioDetalle(tId))
        .thenAnswer((_) async => const Left(ServerFailure('Sin conexión')));

    final result = await useCase(tId);

    expect(result, const Left(ServerFailure('Sin conexión')));
  });
}
