import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cubamap/core/errors/failures.dart';
import 'package:cubamap/core/usecases/usecase.dart';
import 'package:cubamap/features/busqueda/domain/entities/negocio_recomendado.dart';
import 'package:cubamap/features/busqueda/domain/entities/resultado_busqueda.dart';
import 'package:cubamap/features/busqueda/domain/usecases/buscar_productos_usecase.dart';
import 'package:cubamap/features/busqueda/domain/usecases/get_negocios_recomendados_usecase.dart';
import 'package:cubamap/features/busqueda/presentation/cubit/busqueda_cubit.dart';
import 'package:cubamap/features/busqueda/presentation/cubit/busqueda_state.dart';

class MockBuscarProductosUseCase extends Mock
    implements BuscarProductosUseCase {}

class MockGetNegociosRecomendadosUseCase extends Mock
    implements GetNegociosRecomendadosUseCase {}

void main() {
  setUpAll(() {
    registerFallbackValue(const BusquedaParams(termino: ''));
    registerFallbackValue(const NoParams());
  });
  late BusquedaCubit cubit;
  late MockBuscarProductosUseCase mockBuscar;
  late MockGetNegociosRecomendadosUseCase mockRecomendados;

  const tRecomendado = NegocioRecomendado(
    id: 'n001',
    nombre: 'Panadería Elena',
    calificacion: 4.8,
    distanciaKm: 0.3,
  );

  const tResultado = ResultadoBusqueda(
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

  BusquedaCubit buildCubit() => BusquedaCubit(
        buscarProductosUseCase: mockBuscar,
        getRecomendadosUseCase: mockRecomendados,
      );

  setUp(() {
    mockBuscar = MockBuscarProductosUseCase();
    mockRecomendados = MockGetNegociosRecomendadosUseCase();
  });

  tearDown(() => cubit.close());

  test('estado inicial es BusquedaState.initial con status idle', () {
    cubit = buildCubit();
    expect(cubit.state.status, BusquedaStatus.idle);
    expect(cubit.state.termino, '');
    expect(cubit.state.resultados, isEmpty);
    expect(cubit.state.recomendados, isEmpty);
  });

  group('init', () {
    blocTest<BusquedaCubit, BusquedaState>(
      'emite loadingRecomendados luego idle con recomendados cuando tiene éxito',
      build: () {
        when(() => mockRecomendados(const NoParams()))
            .thenAnswer((_) async => const Right([tRecomendado]));
        return buildCubit();
      },
      act: (c) => c.init(),
      expect: () => [
        predicate<BusquedaState>(
            (s) => s.status == BusquedaStatus.loadingRecomendados),
        predicate<BusquedaState>((s) =>
            s.status == BusquedaStatus.idle &&
            s.recomendados.length == 1),
      ],
      tearDown: () => cubit = buildCubit(),
    );

    blocTest<BusquedaCubit, BusquedaState>(
      'emite idle vacío cuando falla la carga de recomendados',
      build: () {
        when(() => mockRecomendados(const NoParams()))
            .thenAnswer((_) async =>
                const Left(ServerFailure('Error de red')));
        return buildCubit();
      },
      act: (c) => c.init(),
      expect: () => [
        predicate<BusquedaState>(
            (s) => s.status == BusquedaStatus.loadingRecomendados),
        predicate<BusquedaState>(
            (s) => s.status == BusquedaStatus.idle && s.recomendados.isEmpty),
      ],
      tearDown: () => cubit = buildCubit(),
    );
  });

  group('onTerminoChanged', () {
    blocTest<BusquedaCubit, BusquedaState>(
      'emite idle con resultados vacíos cuando el termino es vacío',
      build: () => buildCubit(),
      act: (c) => c.onTerminoChanged(''),
      expect: () => [
        predicate<BusquedaState>((s) =>
            s.status == BusquedaStatus.idle && s.resultados.isEmpty),
      ],
      tearDown: () => cubit = buildCubit(),
    );

    blocTest<BusquedaCubit, BusquedaState>(
      'emite loading cuando se escribe un termino',
      build: () {
        when(() => mockBuscar(any()))
            .thenAnswer((_) async => const Right([]));
        return buildCubit();
      },
      act: (c) async {
        c.onTerminoChanged('pan');
        await Future<void>.delayed(const Duration(milliseconds: 500));
      },
      expect: () => [
        predicate<BusquedaState>((s) =>
            s.status == BusquedaStatus.loading && s.termino == 'pan'),
        predicate<BusquedaState>(
            (s) => s.status == BusquedaStatus.loaded),
      ],
      tearDown: () => cubit = buildCubit(),
    );

    blocTest<BusquedaCubit, BusquedaState>(
      'emite loaded con resultados cuando la búsqueda tiene éxito',
      build: () {
        when(() => mockBuscar(any()))
            .thenAnswer((_) async => const Right([tResultado]));
        return buildCubit();
      },
      act: (c) async {
        c.onTerminoChanged('pan');
        await Future<void>.delayed(const Duration(milliseconds: 500));
      },
      expect: () => [
        predicate<BusquedaState>((s) => s.status == BusquedaStatus.loading),
        predicate<BusquedaState>((s) =>
            s.status == BusquedaStatus.loaded &&
            s.resultados.length == 1),
      ],
      tearDown: () => cubit = buildCubit(),
    );

    blocTest<BusquedaCubit, BusquedaState>(
      'emite error cuando la búsqueda falla',
      build: () {
        when(() => mockBuscar(any())).thenAnswer(
            (_) async => const Left(ServerFailure('Sin conexión')));
        return buildCubit();
      },
      act: (c) async {
        c.onTerminoChanged('pan');
        await Future<void>.delayed(const Duration(milliseconds: 500));
      },
      expect: () => [
        predicate<BusquedaState>((s) => s.status == BusquedaStatus.loading),
        predicate<BusquedaState>((s) =>
            s.status == BusquedaStatus.error &&
            s.errorMessage!.contains('Sin conexión')),
      ],
      tearDown: () => cubit = buildCubit(),
    );
  });

  group('setOrden', () {
    blocTest<BusquedaCubit, BusquedaState>(
      'actualiza el orden en el estado',
      build: () {
        when(() => mockBuscar(any()))
            .thenAnswer((_) async => const Right([]));
        return buildCubit();
      },
      seed: () => BusquedaState.initial().copyWith(
          termino: 'pan', status: BusquedaStatus.loaded),
      act: (c) => c.setOrden(OrdenBusqueda.precio),
      verify: (c) => expect(c.state.orden, OrdenBusqueda.precio),
      tearDown: () => cubit = buildCubit(),
    );

    blocTest<BusquedaCubit, BusquedaState>(
      'no dispara búsqueda cuando el termino está vacío',
      build: () => buildCubit(),
      act: (c) => c.setOrden(OrdenBusqueda.calificacion),
      verify: (_) => verifyNever(() => mockBuscar(any())),
      tearDown: () => cubit = buildCubit(),
    );
  });

  group('toggleSoloAbiertos', () {
    blocTest<BusquedaCubit, BusquedaState>(
      'invierte el valor de soloAbiertos',
      build: () {
        when(() => mockBuscar(any()))
            .thenAnswer((_) async => const Right([]));
        return buildCubit();
      },
      seed: () => BusquedaState.initial().copyWith(
          termino: 'pan', status: BusquedaStatus.loaded),
      act: (c) => c.toggleSoloAbiertos(),
      verify: (c) => expect(c.state.soloAbiertos, true),
      tearDown: () => cubit = buildCubit(),
    );
  });
}
