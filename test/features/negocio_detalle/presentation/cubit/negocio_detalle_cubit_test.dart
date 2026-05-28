import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cubamap/core/errors/failures.dart';
import 'package:cubamap/features/negocio_detalle/domain/entities/negocio_detalle.dart';
import 'package:cubamap/features/negocio_detalle/domain/usecases/get_negocio_detalle_usecase.dart';
import 'package:cubamap/features/negocio_detalle/presentation/cubit/negocio_detalle_cubit.dart';
import 'package:cubamap/features/negocio_detalle/presentation/cubit/negocio_detalle_state.dart';

class MockGetNegocioDetalleUseCase extends Mock
    implements GetNegocioDetalleUseCase {}

void main() {
  late NegocioDetalleCubit cubit;
  late MockGetNegocioDetalleUseCase mockUseCase;

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
    mockUseCase = MockGetNegocioDetalleUseCase();
    cubit = NegocioDetalleCubit(getNegocioDetalleUseCase: mockUseCase);
  });

  tearDown(() => cubit.close());

  test('estado inicial es NegocioDetalleInitial', () {
    expect(cubit.state, isA<NegocioDetalleInitial>());
  });

  group('loadNegocio', () {
    blocTest<NegocioDetalleCubit, NegocioDetalleState>(
      'emite [NegocioDetalleLoading, NegocioDetalleLoaded] cuando el use case tiene éxito',
      build: () {
        when(() => mockUseCase(tId))
            .thenAnswer((_) async => const Right(tNegocio));
        return cubit;
      },
      act: (c) => c.loadNegocio(tId),
      expect: () => [
        isA<NegocioDetalleLoading>(),
        isA<NegocioDetalleLoaded>(),
      ],
      verify: (_) {
        verify(() => mockUseCase(tId)).called(1);
      },
    );

    blocTest<NegocioDetalleCubit, NegocioDetalleState>(
      'el estado NegocioDetalleLoaded contiene el negocio correcto',
      build: () {
        when(() => mockUseCase(tId))
            .thenAnswer((_) async => const Right(tNegocio));
        return cubit;
      },
      act: (c) => c.loadNegocio(tId),
      expect: () => [
        isA<NegocioDetalleLoading>(),
        predicate<NegocioDetalleState>((s) =>
            s is NegocioDetalleLoaded && s.negocio.nombre == 'La Panadería Elena'),
      ],
    );

    blocTest<NegocioDetalleCubit, NegocioDetalleState>(
      'emite [NegocioDetalleLoading, NegocioDetalleError] cuando el use case falla',
      build: () {
        when(() => mockUseCase(tId)).thenAnswer(
            (_) async => const Left(ServerFailure('Error de red')));
        return cubit;
      },
      act: (c) => c.loadNegocio(tId),
      expect: () => [
        isA<NegocioDetalleLoading>(),
        isA<NegocioDetalleError>(),
      ],
    );

    blocTest<NegocioDetalleCubit, NegocioDetalleState>(
      'el estado NegocioDetalleError contiene el mensaje correcto',
      build: () {
        when(() => mockUseCase(tId)).thenAnswer(
            (_) async => const Left(ServerFailure('Negocio no encontrado')));
        return cubit;
      },
      act: (c) => c.loadNegocio(tId),
      expect: () => [
        isA<NegocioDetalleLoading>(),
        predicate<NegocioDetalleState>((s) =>
            s is NegocioDetalleError &&
            s.message.contains('Negocio no encontrado')),
      ],
    );

    blocTest<NegocioDetalleCubit, NegocioDetalleState>(
      'puede recargar después de un error',
      build: () {
        var llamadas = 0;
        when(() => mockUseCase(tId)).thenAnswer((_) async {
          llamadas++;
          if (llamadas == 1) {
            return const Left(ServerFailure('Error temporal'));
          }
          return const Right(tNegocio);
        });
        return cubit;
      },
      act: (c) async {
        await c.loadNegocio(tId);
        await c.loadNegocio(tId);
      },
      expect: () => [
        isA<NegocioDetalleLoading>(),
        isA<NegocioDetalleError>(),
        isA<NegocioDetalleLoading>(),
        isA<NegocioDetalleLoaded>(),
      ],
    );
  });
}
