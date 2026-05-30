import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cubamap/core/errors/failures.dart';
import 'package:cubamap/core/usecases/usecase.dart';
import 'package:cubamap/features/favoritos/domain/entities/producto_favorito.dart';
import 'package:cubamap/features/favoritos/domain/usecases/get_productos_favoritos_usecase.dart';
import 'package:cubamap/features/favoritos/domain/usecases/toggle_producto_favorito_usecase.dart';
import 'package:cubamap/features/favoritos/presentation/cubit/productos_favoritos_cubit.dart';
import 'package:cubamap/features/favoritos/presentation/cubit/productos_favoritos_state.dart';

class MockGetProductosFavoritosUseCase extends Mock
    implements GetProductosFavoritosUseCase {}

class MockToggleProductoFavoritoUseCase extends Mock
    implements ToggleProductoFavoritoUseCase {}

void main() {
  setUpAll(() {
    registerFallbackValue(const NoParams());
    registerFallbackValue(const ToggleProductoFavoritoParams(
        productoId: 'p001', negocioId: 'n001', add: true));
  });

  late ProductosFavoritosCubit cubit;
  late MockGetProductosFavoritosUseCase mockGet;
  late MockToggleProductoFavoritoUseCase mockToggle;

  final tFavorito = ProductoFavorito(
    id: 'fav002',
    productoId: 'p001',
    productoNombre: 'Pan Criollo',
    negocioId: 'n001',
    negocioNombre: 'Panadería Elena',
    precio: 25.0,
    negocioAbierto: true,
    createdAt: DateTime(2026, 5, 29),
  );

  ProductosFavoritosCubit buildCubit() => ProductosFavoritosCubit(
        getProductosFavoritosUseCase: mockGet,
        toggleProductoFavoritoUseCase: mockToggle,
      );

  setUp(() {
    mockGet = MockGetProductosFavoritosUseCase();
    mockToggle = MockToggleProductoFavoritoUseCase();
  });

  tearDown(() => cubit.close());

  test('estado inicial es ProductosFavoritosInitial', () {
    cubit = buildCubit();
    expect(cubit.state, isA<ProductosFavoritosInitial>());
  });

  group('loadFavoritos', () {
    blocTest<ProductosFavoritosCubit, ProductosFavoritosState>(
      'emite Loading luego Loaded cuando tiene éxito',
      build: () {
        when(() => mockGet(const NoParams()))
            .thenAnswer((_) async => Right([tFavorito]));
        return buildCubit();
      },
      act: (c) => c.loadFavoritos(),
      expect: () => [
        isA<ProductosFavoritosLoading>(),
        isA<ProductosFavoritosLoaded>(),
      ],
    );

    blocTest<ProductosFavoritosCubit, ProductosFavoritosState>(
      'Loaded contiene la lista y el Set de IDs correctos',
      build: () {
        when(() => mockGet(const NoParams()))
            .thenAnswer((_) async => Right([tFavorito]));
        return buildCubit();
      },
      act: (c) => c.loadFavoritos(),
      verify: (c) {
        final loaded = c.state as ProductosFavoritosLoaded;
        expect(loaded.productos.length, 1);
        expect(loaded.productoIds.contains('p001'), isTrue);
      },
    );

    blocTest<ProductosFavoritosCubit, ProductosFavoritosState>(
      'emite Loading luego Error cuando falla',
      build: () {
        when(() => mockGet(const NoParams()))
            .thenAnswer((_) async => Left(const ServerFailure('error')));
        return buildCubit();
      },
      act: (c) => c.loadFavoritos(),
      expect: () => [
        isA<ProductosFavoritosLoading>(),
        isA<ProductosFavoritosError>(),
      ],
    );
  });

  group('toggleFavorito', () {
    blocTest<ProductosFavoritosCubit, ProductosFavoritosState>(
      'llama al toggle con add:true cuando el producto no es favorito',
      build: () {
        when(() => mockGet(const NoParams()))
            .thenAnswer((_) async => const Right([]));
        when(() => mockToggle(any()))
            .thenAnswer((_) async => const Right(null));
        return buildCubit();
      },
      act: (c) async {
        await c.loadFavoritos();
        when(() => mockGet(const NoParams()))
            .thenAnswer((_) async => Right([tFavorito]));
        await c.toggleFavorito('p001', 'n001');
      },
      verify: (c) {
        verify(() => mockToggle(const ToggleProductoFavoritoParams(
              productoId: 'p001',
              negocioId: 'n001',
              add: true,
            ))).called(1);
      },
    );

    blocTest<ProductosFavoritosCubit, ProductosFavoritosState>(
      'revierte el estado cuando falla el toggle',
      build: () {
        when(() => mockGet(const NoParams()))
            .thenAnswer((_) async => const Right([]));
        when(() => mockToggle(any()))
            .thenAnswer((_) async => Left(const ServerFailure('error')));
        return buildCubit();
      },
      act: (c) async {
        await c.loadFavoritos();
        await c.toggleFavorito('p001', 'n001');
      },
      verify: (c) {
        final loaded = c.state as ProductosFavoritosLoaded;
        expect(loaded.productoIds.contains('p001'), isFalse);
      },
    );
  });
}
