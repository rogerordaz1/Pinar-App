import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cubamap/core/errors/failures.dart';
import 'package:cubamap/core/usecases/usecase.dart';
import 'package:cubamap/features/favoritos/domain/entities/negocio_favorito.dart';
import 'package:cubamap/features/favoritos/domain/usecases/get_negocios_favoritos_usecase.dart';
import 'package:cubamap/features/favoritos/domain/usecases/toggle_negocio_favorito_usecase.dart';
import 'package:cubamap/features/favoritos/presentation/cubit/negocios_favoritos_cubit.dart';
import 'package:cubamap/features/favoritos/presentation/cubit/negocios_favoritos_state.dart';

class MockGetNegociosFavoritosUseCase extends Mock
    implements GetNegociosFavoritosUseCase {}

class MockToggleNegocioFavoritoUseCase extends Mock
    implements ToggleNegocioFavoritoUseCase {}

void main() {
  setUpAll(() {
    registerFallbackValue(const NoParams());
    registerFallbackValue(
        const ToggleNegocioFavoritoParams(negocioId: 'n001', add: true));
  });

  late NegociosFavoritosCubit cubit;
  late MockGetNegociosFavoritosUseCase mockGet;
  late MockToggleNegocioFavoritoUseCase mockToggle;

  final tFavorito = NegocioFavorito(
    id: 'fav001',
    negocioId: 'n001',
    negocioNombre: 'Panadería Elena',
    negocioAbierto: true,
    calificacion: 4.8,
    negocioVerificado: true,
    createdAt: DateTime(2026, 5, 29),
  );

  NegociosFavoritosCubit buildCubit() => NegociosFavoritosCubit(
        getNegociosFavoritosUseCase: mockGet,
        toggleNegocioFavoritoUseCase: mockToggle,
      );

  setUp(() {
    mockGet = MockGetNegociosFavoritosUseCase();
    mockToggle = MockToggleNegocioFavoritoUseCase();
  });

  tearDown(() => cubit.close());

  test('estado inicial es NegociosFavoritosInitial', () {
    cubit = buildCubit();
    expect(cubit.state, isA<NegociosFavoritosInitial>());
  });

  group('loadFavoritos', () {
    blocTest<NegociosFavoritosCubit, NegociosFavoritosState>(
      'emite Loading luego Loaded cuando tiene éxito',
      build: () {
        when(() => mockGet(const NoParams()))
            .thenAnswer((_) async => Right([tFavorito]));
        return buildCubit();
      },
      act: (c) => c.loadFavoritos(),
      expect: () => [
        isA<NegociosFavoritosLoading>(),
        isA<NegociosFavoritosLoaded>(),
      ],
    );

    blocTest<NegociosFavoritosCubit, NegociosFavoritosState>(
      'Loaded contiene la lista y el Set de IDs correctos',
      build: () {
        when(() => mockGet(const NoParams()))
            .thenAnswer((_) async => Right([tFavorito]));
        return buildCubit();
      },
      act: (c) => c.loadFavoritos(),
      verify: (c) {
        final loaded = c.state as NegociosFavoritosLoaded;
        expect(loaded.negocios.length, 1);
        expect(loaded.negocioIds.contains('n001'), isTrue);
      },
    );

    blocTest<NegociosFavoritosCubit, NegociosFavoritosState>(
      'emite Loading luego Error cuando falla',
      build: () {
        when(() => mockGet(const NoParams()))
            .thenAnswer((_) async => Left(const ServerFailure('error')));
        return buildCubit();
      },
      act: (c) => c.loadFavoritos(),
      expect: () => [
        isA<NegociosFavoritosLoading>(),
        isA<NegociosFavoritosError>(),
      ],
    );
  });

  group('toggleFavorito', () {
    blocTest<NegociosFavoritosCubit, NegociosFavoritosState>(
      'actualiza optimisticamente el Set al agregar y recarga al tener éxito',
      build: () {
        when(() => mockGet(const NoParams()))
            .thenAnswer((_) async => Right([tFavorito]));
        when(() => mockToggle(any())).thenAnswer((_) async => const Right(null));
        return buildCubit();
      },
      act: (c) async {
        // Seed with empty loaded state (n001 NOT a favorite)
        when(() => mockGet(const NoParams()))
            .thenAnswer((_) async => const Right([]));
        await c.loadFavoritos();
        // Now toggle add n001
        when(() => mockGet(const NoParams()))
            .thenAnswer((_) async => Right([tFavorito]));
        await c.toggleFavorito('n001');
      },
      verify: (c) {
        verify(() => mockToggle(
              const ToggleNegocioFavoritoParams(negocioId: 'n001', add: true),
            )).called(1);
      },
    );

    blocTest<NegociosFavoritosCubit, NegociosFavoritosState>(
      'revierte el estado optimista cuando falla el toggle',
      build: () {
        when(() => mockGet(const NoParams()))
            .thenAnswer((_) async => const Right([]));
        when(() => mockToggle(any()))
            .thenAnswer((_) async => Left(const ServerFailure('error')));
        return buildCubit();
      },
      act: (c) async {
        await c.loadFavoritos();
        await c.toggleFavorito('n001');
      },
      verify: (c) {
        // After revert, n001 should NOT be in the Set
        final loaded = c.state as NegociosFavoritosLoaded;
        expect(loaded.negocioIds.contains('n001'), isFalse);
      },
    );
  });
}
