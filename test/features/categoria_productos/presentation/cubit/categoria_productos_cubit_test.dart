import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cubamap/core/errors/failures.dart';
import 'package:cubamap/features/busqueda/domain/entities/resultado_busqueda.dart';
import 'package:cubamap/features/categoria_productos/domain/usecases/get_productos_por_categoria_usecase.dart';
import 'package:cubamap/features/categoria_productos/presentation/cubit/categoria_productos_cubit.dart';
import 'package:cubamap/features/categoria_productos/presentation/cubit/categoria_productos_state.dart';

class MockGetProductosPorCategoriaUseCase extends Mock
    implements GetProductosPorCategoriaUseCase {}

void main() {
  late CategoriaProductosCubit cubit;
  late MockGetProductosPorCategoriaUseCase mockUseCase;

  const tProducto = ResultadoBusqueda(
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

  setUpAll(() {
    registerFallbackValue(
      const CategoriaParams(categoriaId: '', categoriaNombre: ''),
    );
  });

  setUp(() {
    mockUseCase = MockGetProductosPorCategoriaUseCase();
    cubit = CategoriaProductosCubit(getProductosPorCategoriaUseCase: mockUseCase);
  });

  tearDown(() => cubit.close());

  test('estado inicial es CategoriaProductosInitial', () {
    expect(cubit.state, isA<CategoriaProductosInitial>());
  });

  group('loadProductos', () {
    blocTest<CategoriaProductosCubit, CategoriaProductosState>(
      'emite [Loading, Loaded] cuando el use case tiene éxito',
      build: () {
        when(() => mockUseCase(any()))
            .thenAnswer((_) async => const Right([tProducto]));
        return cubit;
      },
      act: (c) => c.loadProductos('cat-001', 'Panadería'),
      expect: () => [
        isA<CategoriaProductosLoading>(),
        isA<CategoriaProductosLoaded>(),
      ],
      verify: (_) => verify(() => mockUseCase(any())).called(1),
    );

    blocTest<CategoriaProductosCubit, CategoriaProductosState>(
      'el estado Loaded contiene los productos correctos',
      build: () {
        when(() => mockUseCase(any()))
            .thenAnswer((_) async => const Right([tProducto]));
        return cubit;
      },
      act: (c) => c.loadProductos('cat-001'),
      expect: () => [
        isA<CategoriaProductosLoading>(),
        predicate<CategoriaProductosState>((s) =>
            s is CategoriaProductosLoaded &&
            s.productos.length == 1 &&
            s.productos.first.productoNombre == 'Pan Criollo'),
      ],
    );

    blocTest<CategoriaProductosCubit, CategoriaProductosState>(
      'emite [Loading, Error] cuando el use case falla',
      build: () {
        when(() => mockUseCase(any())).thenAnswer(
            (_) async => const Left(ServerFailure('Sin conexión')));
        return cubit;
      },
      act: (c) => c.loadProductos('cat-001'),
      expect: () => [
        isA<CategoriaProductosLoading>(),
        isA<CategoriaProductosError>(),
      ],
    );

    blocTest<CategoriaProductosCubit, CategoriaProductosState>(
      'el estado Error contiene el mensaje correcto',
      build: () {
        when(() => mockUseCase(any())).thenAnswer(
            (_) async => const Left(ServerFailure('Error de red')));
        return cubit;
      },
      act: (c) => c.loadProductos('cat-001'),
      expect: () => [
        isA<CategoriaProductosLoading>(),
        predicate<CategoriaProductosState>((s) =>
            s is CategoriaProductosError &&
            s.message.contains('Error de red')),
      ],
    );

    blocTest<CategoriaProductosCubit, CategoriaProductosState>(
      'retry recarga los productos usando el último categoriaId',
      build: () {
        var llamadas = 0;
        when(() => mockUseCase(any())).thenAnswer((_) async {
          llamadas++;
          if (llamadas == 1) {
            return const Left(ServerFailure('Error temporal'));
          }
          return const Right([tProducto]);
        });
        return cubit;
      },
      act: (c) async {
        await c.loadProductos('cat-001');
        await c.retry();
      },
      expect: () => [
        isA<CategoriaProductosLoading>(),
        isA<CategoriaProductosError>(),
        isA<CategoriaProductosLoading>(),
        isA<CategoriaProductosLoaded>(),
      ],
    );
  });
}
