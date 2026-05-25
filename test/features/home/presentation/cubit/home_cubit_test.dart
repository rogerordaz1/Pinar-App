import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:cubamap/core/errors/failures.dart';
import 'package:cubamap/core/usecases/usecase.dart';
import 'package:cubamap/features/home/domain/entities/categoria_negocio.dart';
import 'package:cubamap/features/home/domain/entities/negocio_preview.dart';
import 'package:cubamap/features/home/domain/entities/promocion.dart';
import 'package:cubamap/features/home/domain/usecases/get_categorias_usecase.dart';
import 'package:cubamap/features/home/domain/usecases/get_negocios_cercanos_usecase.dart';
import 'package:cubamap/features/home/domain/usecases/get_promociones_usecase.dart';
import 'package:cubamap/features/home/presentation/cubit/home_cubit.dart';
import 'package:cubamap/features/home/presentation/cubit/home_state.dart';

class MockGetNegociosCercanosUseCase extends Mock
    implements GetNegociosCercanosUseCase {}

class MockGetCategoriasUseCase extends Mock implements GetCategoriasUseCase {}

class MockGetPromocionesUseCase extends Mock implements GetPromocionesUseCase {}

void main() {
  late HomeCubit cubit;
  late MockGetNegociosCercanosUseCase mockGetNegocios;
  late MockGetCategoriasUseCase mockGetCategorias;
  late MockGetPromocionesUseCase mockGetPromociones;

  const tNegocios = [
    NegocioPreview(
      id: '1',
      nombre: 'Test Negocio',
      categoria: 'Cafetería',
      distanciaKm: 0.5,
      abierto: true,
    ),
  ];
  const tCategorias = [
    CategoriaNegocio(id: 'cat-1', nombre: 'Cafetería', icono: 'coffee'),
  ];
  const tPromociones = [
    Promocion(
      id: 'promo-1',
      titulo: 'Test Promo',
      nombreNegocio: 'Test Negocio',
      negocioId: '1',
    ),
  ];

  setUpAll(() {
    registerFallbackValue(const NoParams());
  });

  setUp(() {
    mockGetNegocios = MockGetNegociosCercanosUseCase();
    mockGetCategorias = MockGetCategoriasUseCase();
    mockGetPromociones = MockGetPromocionesUseCase();
    cubit = HomeCubit(
      getNegociosCercanosUseCase: mockGetNegocios,
      getCategoriasUseCase: mockGetCategorias,
      getPromocionesUseCase: mockGetPromociones,
    );
  });

  tearDown(() => cubit.close());

  test('initial state is HomeInitial', () {
    expect(cubit.state, isA<HomeInitial>());
  });

  group('loadHome', () {
    blocTest<HomeCubit, HomeState>(
      'emits [HomeLoading, HomeLoaded] when all use cases succeed',
      build: () {
        when(() => mockGetNegocios(any()))
            .thenAnswer((_) async => const Right(tNegocios));
        when(() => mockGetCategorias(any()))
            .thenAnswer((_) async => const Right(tCategorias));
        when(() => mockGetPromociones(any()))
            .thenAnswer((_) async => const Right(tPromociones));
        return cubit;
      },
      act: (cubit) => cubit.loadHome(),
      expect: () => [
        isA<HomeLoading>(),
        const HomeLoaded(
          negocios: tNegocios,
          categorias: tCategorias,
          promociones: tPromociones,
        ),
      ],
    );

    blocTest<HomeCubit, HomeState>(
      'emits [HomeLoading, HomeError] when getNegociosCercanos fails',
      build: () {
        when(() => mockGetNegocios(any())).thenAnswer(
            (_) async => const Left(ServerFailure('Error de servidor')));
        when(() => mockGetCategorias(any()))
            .thenAnswer((_) async => const Right(tCategorias));
        when(() => mockGetPromociones(any()))
            .thenAnswer((_) async => const Right(tPromociones));
        return cubit;
      },
      act: (cubit) => cubit.loadHome(),
      expect: () => [
        isA<HomeLoading>(),
        const HomeError('Error de servidor'),
      ],
    );

    blocTest<HomeCubit, HomeState>(
      'emits [HomeLoading, HomeError] when getCategorias fails',
      build: () {
        when(() => mockGetNegocios(any()))
            .thenAnswer((_) async => const Right(tNegocios));
        when(() => mockGetCategorias(any())).thenAnswer(
            (_) async => const Left(ServerFailure('Error categorías')));
        when(() => mockGetPromociones(any()))
            .thenAnswer((_) async => const Right(tPromociones));
        return cubit;
      },
      act: (cubit) => cubit.loadHome(),
      expect: () => [
        isA<HomeLoading>(),
        const HomeError('Error categorías'),
      ],
    );
  });
}
