# Home Screen & Navigation Shell Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement the navigation shell (StatefulShellRoute, 4-tab NavigationBar) and the Home screen (header, search, categories, promotions, nearby businesses) with full Clean Architecture and mock data.

**Architecture:** StatefulShellRoute wraps 4 branches. Home feature: MockHomeDataSource → HomeRepositoryImpl → 3 UseCases → HomeCubit → HomePage. Swapping to Supabase = change one line in injection_container.dart. AuthCubit provided once at the shell level; logout listener lives in MainShell.

**Tech Stack:** Flutter, go_router 14 (StatefulShellRoute), flutter_bloc, bloc_test, mocktail, dartz (Either/fold/getOrElse), get_it, Material 3 NavigationBar.

---

## File Map

**New files — feature/home domain:**
- `lib/features/home/domain/entities/negocio_preview.dart`
- `lib/features/home/domain/entities/categoria_negocio.dart`
- `lib/features/home/domain/entities/promocion.dart`
- `lib/features/home/domain/repositories/home_repository.dart`
- `lib/features/home/domain/usecases/get_negocios_cercanos_usecase.dart`
- `lib/features/home/domain/usecases/get_categorias_usecase.dart`
- `lib/features/home/domain/usecases/get_promociones_usecase.dart`

**New files — feature/home data:**
- `lib/features/home/data/models/negocio_preview_model.dart`
- `lib/features/home/data/models/categoria_negocio_model.dart`
- `lib/features/home/data/models/promocion_model.dart`
- `lib/features/home/data/datasources/home_datasource.dart`
- `lib/features/home/data/datasources/mock_home_datasource.dart`
- `lib/features/home/data/repositories/home_repository_impl.dart`

**New files — feature/home presentation:**
- `lib/features/home/presentation/cubit/home_state.dart`
- `lib/features/home/presentation/cubit/home_cubit.dart`
- `lib/features/home/presentation/pages/home_page.dart`
- `lib/features/home/presentation/widgets/home_header.dart`
- `lib/features/home/presentation/widgets/search_bar_tap.dart`
- `lib/features/home/presentation/widgets/category_chip.dart`
- `lib/features/home/presentation/widgets/promo_banner.dart`
- `lib/features/home/presentation/widgets/negocio_card.dart`

**New files — core:**
- `lib/core/shell/main_shell.dart`

**New files — tests:**
- `test/features/home/presentation/cubit/home_cubit_test.dart`

**Modified files:**
- `lib/injection_container.dart` — add home feature registrations
- `lib/core/router/app_router.dart` — replace flat routes with StatefulShellRoute

---

### Task 1: Domain Entities

**Files:**
- Create: `lib/features/home/domain/entities/negocio_preview.dart`
- Create: `lib/features/home/domain/entities/categoria_negocio.dart`
- Create: `lib/features/home/domain/entities/promocion.dart`

- [ ] **Step 1: Create NegocioPreview entity**

```dart
// lib/features/home/domain/entities/negocio_preview.dart
import 'package:equatable/equatable.dart';

class NegocioPreview extends Equatable {
  final String id;
  final String nombre;
  final String categoria;
  final double distanciaKm;
  final bool abierto;
  final String? logoUrl;
  final bool verificado;

  const NegocioPreview({
    required this.id,
    required this.nombre,
    required this.categoria,
    required this.distanciaKm,
    required this.abierto,
    this.logoUrl,
    this.verificado = false,
  });

  @override
  List<Object?> get props =>
      [id, nombre, categoria, distanciaKm, abierto, logoUrl, verificado];
}
```

- [ ] **Step 2: Create CategoriaNegocio entity**

```dart
// lib/features/home/domain/entities/categoria_negocio.dart
import 'package:equatable/equatable.dart';

class CategoriaNegocio extends Equatable {
  final String id;
  final String nombre;
  final String icono;

  const CategoriaNegocio({
    required this.id,
    required this.nombre,
    required this.icono,
  });

  @override
  List<Object> get props => [id, nombre, icono];
}
```

- [ ] **Step 3: Create Promocion entity**

```dart
// lib/features/home/domain/entities/promocion.dart
import 'package:equatable/equatable.dart';

class Promocion extends Equatable {
  final String id;
  final String titulo;
  final String nombreNegocio;
  final String negocioId;
  final String? imagenUrl;

  const Promocion({
    required this.id,
    required this.titulo,
    required this.nombreNegocio,
    required this.negocioId,
    this.imagenUrl,
  });

  @override
  List<Object?> get props => [id, titulo, nombreNegocio, negocioId, imagenUrl];
}
```

- [ ] **Step 4: Commit**

```bash
git add lib/features/home/domain/entities/
git commit -m "feat(home): add domain entities NegocioPreview, CategoriaNegocio, Promocion"
```

---

### Task 2: Domain Repository Interface + Use Cases

**Files:**
- Create: `lib/features/home/domain/repositories/home_repository.dart`
- Create: `lib/features/home/domain/usecases/get_negocios_cercanos_usecase.dart`
- Create: `lib/features/home/domain/usecases/get_categorias_usecase.dart`
- Create: `lib/features/home/domain/usecases/get_promociones_usecase.dart`

- [ ] **Step 1: Create HomeRepository abstract interface**

```dart
// lib/features/home/domain/repositories/home_repository.dart
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/negocio_preview.dart';
import '../entities/categoria_negocio.dart';
import '../entities/promocion.dart';

abstract class HomeRepository {
  Future<Either<Failure, List<NegocioPreview>>> getNegociosCercanos();
  Future<Either<Failure, List<CategoriaNegocio>>> getCategorias();
  Future<Either<Failure, List<Promocion>>> getPromociones();
}
```

- [ ] **Step 2: Create GetNegociosCercanosUseCase**

```dart
// lib/features/home/domain/usecases/get_negocios_cercanos_usecase.dart
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/negocio_preview.dart';
import '../repositories/home_repository.dart';

class GetNegociosCercanosUseCase
    extends UseCase<List<NegocioPreview>, NoParams> {
  final HomeRepository repository;
  GetNegociosCercanosUseCase(this.repository);

  @override
  Future<Either<Failure, List<NegocioPreview>>> call(NoParams params) =>
      repository.getNegociosCercanos();
}
```

- [ ] **Step 3: Create GetCategoriasUseCase**

```dart
// lib/features/home/domain/usecases/get_categorias_usecase.dart
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/categoria_negocio.dart';
import '../repositories/home_repository.dart';

class GetCategoriasUseCase extends UseCase<List<CategoriaNegocio>, NoParams> {
  final HomeRepository repository;
  GetCategoriasUseCase(this.repository);

  @override
  Future<Either<Failure, List<CategoriaNegocio>>> call(NoParams params) =>
      repository.getCategorias();
}
```

- [ ] **Step 4: Create GetPromocionesUseCase**

```dart
// lib/features/home/domain/usecases/get_promociones_usecase.dart
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/promocion.dart';
import '../repositories/home_repository.dart';

class GetPromocionesUseCase extends UseCase<List<Promocion>, NoParams> {
  final HomeRepository repository;
  GetPromocionesUseCase(this.repository);

  @override
  Future<Either<Failure, List<Promocion>>> call(NoParams params) =>
      repository.getPromociones();
}
```

- [ ] **Step 5: Commit**

```bash
git add lib/features/home/domain/repositories/ lib/features/home/domain/usecases/
git commit -m "feat(home): add HomeRepository interface and 3 use cases"
```

---

### Task 3: Data Models + Abstract DataSource

**Files:**
- Create: `lib/features/home/data/models/negocio_preview_model.dart`
- Create: `lib/features/home/data/models/categoria_negocio_model.dart`
- Create: `lib/features/home/data/models/promocion_model.dart`
- Create: `lib/features/home/data/datasources/home_datasource.dart`

- [ ] **Step 1: Create NegocioPreviewModel**

```dart
// lib/features/home/data/models/negocio_preview_model.dart
import '../../domain/entities/negocio_preview.dart';

class NegocioPreviewModel {
  final String id;
  final String nombre;
  final String categoria;
  final double distanciaKm;
  final bool abierto;
  final String? logoUrl;
  final bool verificado;

  const NegocioPreviewModel({
    required this.id,
    required this.nombre,
    required this.categoria,
    required this.distanciaKm,
    required this.abierto,
    this.logoUrl,
    this.verificado = false,
  });

  factory NegocioPreviewModel.fromMap(Map<String, dynamic> map) {
    return NegocioPreviewModel(
      id: map['id'] as String,
      nombre: map['nombre'] as String,
      categoria: map['categoria'] as String,
      distanciaKm: (map['distancia_km'] as num).toDouble(),
      abierto: map['abierto'] as bool,
      logoUrl: map['logo_url'] as String?,
      verificado: map['verificado'] as bool? ?? false,
    );
  }

  NegocioPreview toEntity() => NegocioPreview(
        id: id,
        nombre: nombre,
        categoria: categoria,
        distanciaKm: distanciaKm,
        abierto: abierto,
        logoUrl: logoUrl,
        verificado: verificado,
      );
}
```

- [ ] **Step 2: Create CategoriaNegocioModel**

```dart
// lib/features/home/data/models/categoria_negocio_model.dart
import '../../domain/entities/categoria_negocio.dart';

class CategoriaNegocioModel {
  final String id;
  final String nombre;
  final String icono;

  const CategoriaNegocioModel({
    required this.id,
    required this.nombre,
    required this.icono,
  });

  factory CategoriaNegocioModel.fromMap(Map<String, dynamic> map) {
    return CategoriaNegocioModel(
      id: map['id'] as String,
      nombre: map['nombre'] as String,
      icono: map['icono'] as String,
    );
  }

  CategoriaNegocio toEntity() =>
      CategoriaNegocio(id: id, nombre: nombre, icono: icono);
}
```

- [ ] **Step 3: Create PromocionModel**

```dart
// lib/features/home/data/models/promocion_model.dart
import '../../domain/entities/promocion.dart';

class PromocionModel {
  final String id;
  final String titulo;
  final String nombreNegocio;
  final String negocioId;
  final String? imagenUrl;

  const PromocionModel({
    required this.id,
    required this.titulo,
    required this.nombreNegocio,
    required this.negocioId,
    this.imagenUrl,
  });

  factory PromocionModel.fromMap(Map<String, dynamic> map) {
    return PromocionModel(
      id: map['id'] as String,
      titulo: map['titulo'] as String,
      nombreNegocio: map['nombre_negocio'] as String,
      negocioId: map['negocio_id'] as String,
      imagenUrl: map['imagen_url'] as String?,
    );
  }

  Promocion toEntity() => Promocion(
        id: id,
        titulo: titulo,
        nombreNegocio: nombreNegocio,
        negocioId: negocioId,
        imagenUrl: imagenUrl,
      );
}
```

- [ ] **Step 4: Create abstract HomeDataSource**

```dart
// lib/features/home/data/datasources/home_datasource.dart
import '../models/negocio_preview_model.dart';
import '../models/categoria_negocio_model.dart';
import '../models/promocion_model.dart';

abstract class HomeDataSource {
  Future<List<NegocioPreviewModel>> getNegociosCercanos();
  Future<List<CategoriaNegocioModel>> getCategorias();
  Future<List<PromocionModel>> getPromociones();
}
```

- [ ] **Step 5: Commit**

```bash
git add lib/features/home/data/models/ lib/features/home/data/datasources/home_datasource.dart
git commit -m "feat(home): add data models and abstract HomeDataSource"
```

---

### Task 4: Mock DataSource

**Files:**
- Create: `lib/features/home/data/datasources/mock_home_datasource.dart`

- [ ] **Step 1: Implement MockHomeDataSource with hardcoded data**

```dart
// lib/features/home/data/datasources/mock_home_datasource.dart
import 'home_datasource.dart';
import '../models/negocio_preview_model.dart';
import '../models/categoria_negocio_model.dart';
import '../models/promocion_model.dart';

class MockHomeDataSource implements HomeDataSource {
  @override
  Future<List<NegocioPreviewModel>> getNegociosCercanos() async => const [
        NegocioPreviewModel(
          id: '1',
          nombre: 'La Panadería Elena',
          categoria: 'Panadería',
          distanciaKm: 0.3,
          abierto: true,
          verificado: true,
        ),
        NegocioPreviewModel(
          id: '2',
          nombre: 'Agro San Cristóbal',
          categoria: 'Agropecuario',
          distanciaKm: 0.8,
          abierto: false,
        ),
        NegocioPreviewModel(
          id: '3',
          nombre: 'Farmacia Vida',
          categoria: 'Farmacia',
          distanciaKm: 1.2,
          abierto: true,
          verificado: true,
        ),
        NegocioPreviewModel(
          id: '4',
          nombre: 'Cafetería El Patio',
          categoria: 'Cafetería',
          distanciaKm: 1.5,
          abierto: true,
        ),
        NegocioPreviewModel(
          id: '5',
          nombre: 'Tienda La Esquina',
          categoria: 'Tienda',
          distanciaKm: 2.0,
          abierto: true,
        ),
        NegocioPreviewModel(
          id: '6',
          nombre: 'Ferretería Central',
          categoria: 'Ferretería',
          distanciaKm: 2.3,
          abierto: false,
        ),
      ];

  @override
  Future<List<CategoriaNegocioModel>> getCategorias() async => const [
        CategoriaNegocioModel(id: 'cat-1', nombre: 'Cafetería', icono: 'coffee'),
        CategoriaNegocioModel(
            id: 'cat-2', nombre: 'Agropecuario', icono: 'grass'),
        CategoriaNegocioModel(
            id: 'cat-3', nombre: 'Farmacia', icono: 'local_pharmacy'),
        CategoriaNegocioModel(
            id: 'cat-4', nombre: 'Panadería', icono: 'bakery_dining'),
        CategoriaNegocioModel(id: 'cat-5', nombre: 'Tienda', icono: 'store'),
        CategoriaNegocioModel(
            id: 'cat-6', nombre: 'Salud', icono: 'health_and_safety'),
        CategoriaNegocioModel(
            id: 'cat-7', nombre: 'Ferretería', icono: 'hardware'),
        CategoriaNegocioModel(
            id: 'cat-8', nombre: 'Restaurante', icono: 'restaurant'),
      ];

  @override
  Future<List<PromocionModel>> getPromociones() async => const [
        PromocionModel(
          id: 'promo-1',
          titulo: 'Ofertas de temporada',
          nombreNegocio: 'La Panadería Elena',
          negocioId: '1',
        ),
        PromocionModel(
          id: 'promo-2',
          titulo: 'Productos frescos hoy',
          nombreNegocio: 'Agro San Cristóbal',
          negocioId: '2',
        ),
        PromocionModel(
          id: 'promo-3',
          titulo: 'Medicamentos disponibles',
          nombreNegocio: 'Farmacia Vida',
          negocioId: '3',
        ),
      ];
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/features/home/data/datasources/mock_home_datasource.dart
git commit -m "feat(home): add MockHomeDataSource with hardcoded test data"
```

---

### Task 5: Home Repository Implementation

**Files:**
- Create: `lib/features/home/data/repositories/home_repository_impl.dart`

- [ ] **Step 1: Implement HomeRepositoryImpl**

```dart
// lib/features/home/data/repositories/home_repository_impl.dart
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/negocio_preview.dart';
import '../../domain/entities/categoria_negocio.dart';
import '../../domain/entities/promocion.dart';
import '../../domain/repositories/home_repository.dart';
import '../datasources/home_datasource.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeDataSource dataSource;

  HomeRepositoryImpl(this.dataSource);

  @override
  Future<Either<Failure, List<NegocioPreview>>> getNegociosCercanos() async {
    try {
      final models = await dataSource.getNegociosCercanos();
      return Right(models.map((m) => m.toEntity()).toList());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<CategoriaNegocio>>> getCategorias() async {
    try {
      final models = await dataSource.getCategorias();
      return Right(models.map((m) => m.toEntity()).toList());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Promocion>>> getPromociones() async {
    try {
      final models = await dataSource.getPromociones();
      return Right(models.map((m) => m.toEntity()).toList());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/features/home/data/repositories/
git commit -m "feat(home): add HomeRepositoryImpl with exception-to-failure translation"
```

---

### Task 6: HomeCubit — TDD (tests first, then implement)

**Files:**
- Create: `test/features/home/presentation/cubit/home_cubit_test.dart`
- Create: `lib/features/home/presentation/cubit/home_state.dart`
- Create: `lib/features/home/presentation/cubit/home_cubit.dart`

- [ ] **Step 1: Write the failing tests**

```dart
// test/features/home/presentation/cubit/home_cubit_test.dart
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

  setUpAll(() {
    registerFallbackValue(const NoParams());
  });

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
```

- [ ] **Step 2: Run tests — confirm they fail (HomeCubit doesn't exist yet)**

```bash
flutter test test/features/home/presentation/cubit/home_cubit_test.dart
```

Expected: compilation error — `HomeCubit`, `HomeState`, etc. not found.

- [ ] **Step 3: Create HomeState**

```dart
// lib/features/home/presentation/cubit/home_state.dart
import 'package:equatable/equatable.dart';
import '../../domain/entities/negocio_preview.dart';
import '../../domain/entities/categoria_negocio.dart';
import '../../domain/entities/promocion.dart';

abstract class HomeState extends Equatable {
  const HomeState();
}

class HomeInitial extends HomeState {
  const HomeInitial();
  @override
  List<Object> get props => [];
}

class HomeLoading extends HomeState {
  const HomeLoading();
  @override
  List<Object> get props => [];
}

class HomeLoaded extends HomeState {
  final List<CategoriaNegocio> categorias;
  final List<Promocion> promociones;
  final List<NegocioPreview> negocios;

  const HomeLoaded({
    required this.categorias,
    required this.promociones,
    required this.negocios,
  });

  @override
  List<Object> get props => [categorias, promociones, negocios];
}

class HomeError extends HomeState {
  final String message;
  const HomeError(this.message);
  @override
  List<Object> get props => [message];
}
```

- [ ] **Step 4: Create HomeCubit**

```dart
// lib/features/home/presentation/cubit/home_cubit.dart
import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/categoria_negocio.dart';
import '../../domain/entities/negocio_preview.dart';
import '../../domain/entities/promocion.dart';
import '../../domain/usecases/get_categorias_usecase.dart';
import '../../domain/usecases/get_negocios_cercanos_usecase.dart';
import '../../domain/usecases/get_promociones_usecase.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final GetNegociosCercanosUseCase getNegociosCercanosUseCase;
  final GetCategoriasUseCase getCategoriasUseCase;
  final GetPromocionesUseCase getPromocionesUseCase;

  HomeCubit({
    required this.getNegociosCercanosUseCase,
    required this.getCategoriasUseCase,
    required this.getPromocionesUseCase,
  }) : super(const HomeInitial());

  Future<void> loadHome() async {
    emit(const HomeLoading());

    final results = await Future.wait([
      getNegociosCercanosUseCase(const NoParams()),
      getCategoriasUseCase(const NoParams()),
      getPromocionesUseCase(const NoParams()),
    ]);

    final negociosEither =
        results[0] as Either<Failure, List<NegocioPreview>>;
    final categoriasEither =
        results[1] as Either<Failure, List<CategoriaNegocio>>;
    final promocionesEither =
        results[2] as Either<Failure, List<Promocion>>;

    String? errorMessage;
    negociosEither.fold((f) => errorMessage = f.message, (_) {});
    categoriasEither.fold((f) => errorMessage ??= f.message, (_) {});
    promocionesEither.fold((f) => errorMessage ??= f.message, (_) {});

    if (errorMessage != null) {
      emit(HomeError(errorMessage!));
      return;
    }

    emit(HomeLoaded(
      negocios: negociosEither.getOrElse(() => []),
      categorias: categoriasEither.getOrElse(() => []),
      promociones: promocionesEither.getOrElse(() => []),
    ));
  }
}
```

- [ ] **Step 5: Run tests — confirm they pass**

```bash
flutter test test/features/home/presentation/cubit/home_cubit_test.dart
```

Expected output:
```
00:00 +3: All tests passed!
```

- [ ] **Step 6: Commit**

```bash
git add lib/features/home/presentation/cubit/ test/features/home/
git commit -m "feat(home): add HomeCubit with HomeState — all 3 cubit tests passing"
```

---

### Task 7: DI Registration

**Files:**
- Modify: `lib/injection_container.dart`

- [ ] **Step 1: Add home feature imports and registration**

Add the following imports at the top of `injection_container.dart` (after the existing auth imports):

```dart
import 'features/home/data/datasources/home_datasource.dart';
import 'features/home/data/datasources/mock_home_datasource.dart';
import 'features/home/data/repositories/home_repository_impl.dart';
import 'features/home/domain/repositories/home_repository.dart';
import 'features/home/domain/usecases/get_categorias_usecase.dart';
import 'features/home/domain/usecases/get_negocios_cercanos_usecase.dart';
import 'features/home/domain/usecases/get_promociones_usecase.dart';
import 'features/home/presentation/cubit/home_cubit.dart';
```

- [ ] **Step 2: Add `_registerHome()` call in `_registerFeatures`**

Change `_registerFeatures` from:

```dart
Future<void> _registerFeatures() async {
  await _registerAuth();
}
```

To:

```dart
Future<void> _registerFeatures() async {
  await _registerAuth();
  _registerHome();
}
```

- [ ] **Step 3: Add `_registerHome()` method at end of file**

```dart
void _registerHome() {
  // Cubit
  sl.registerFactory(
    () => HomeCubit(
      getNegociosCercanosUseCase: sl(),
      getCategoriasUseCase: sl(),
      getPromocionesUseCase: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetNegociosCercanosUseCase(sl()));
  sl.registerLazySingleton(() => GetCategoriasUseCase(sl()));
  sl.registerLazySingleton(() => GetPromocionesUseCase(sl()));

  // Repository
  sl.registerLazySingleton<HomeRepository>(
    () => HomeRepositoryImpl(sl()),
  );

  // Data source — swap MockHomeDataSource → SupabaseHomeDataSource when ready
  sl.registerLazySingleton<HomeDataSource>(
    () => MockHomeDataSource(),
  );
}
```

- [ ] **Step 4: Run all tests to confirm DI doesn't break anything**

```bash
flutter test
```

Expected: all existing auth tests still pass.

- [ ] **Step 5: Commit**

```bash
git add lib/injection_container.dart
git commit -m "feat(home): register home feature in DI container"
```

---

### Task 8: MainShell Widget

**Files:**
- Create: `lib/core/shell/main_shell.dart`

- [ ] **Step 1: Create MainShell**

```dart
// lib/core/shell/main_shell.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../router/route_names.dart';
import '../utils/exit_dialog.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../features/auth/presentation/cubit/auth_state.dart';

class MainShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainShell({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          context.go(RouteNames.login);
        }
      },
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) showExitConfirmDialog(context);
        },
        child: Scaffold(
          body: navigationShell,
          bottomNavigationBar: NavigationBar(
            selectedIndex: navigationShell.currentIndex,
            onDestinationSelected: (index) => navigationShell.goBranch(
              index,
              initialLocation: index == navigationShell.currentIndex,
            ),
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home),
                label: 'Inicio',
              ),
              NavigationDestination(
                icon: Icon(Icons.search_outlined),
                selectedIcon: Icon(Icons.search),
                label: 'Buscar',
              ),
              NavigationDestination(
                icon: Icon(Icons.favorite_outline),
                selectedIcon: Icon(Icons.favorite),
                label: 'Favoritos',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline),
                selectedIcon: Icon(Icons.person),
                label: 'Perfil',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/core/shell/main_shell.dart
git commit -m "feat(home): add MainShell with NavigationBar and logout listener"
```

---

### Task 9: App Router Refactor

**Files:**
- Modify: `lib/core/router/app_router.dart`

Replace the entire content of `app_router.dart` with the following. Key changes: remove `_TempHomePage`, add `StatefulShellRoute` with 4 branches, add imports for `MainShell` and `HomePage`.

- [ ] **Step 1: Replace app_router.dart**

```dart
// lib/core/router/app_router.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../shell/main_shell.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/reset_password_page.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/auth/presentation/pages/verify_otp_page.dart';
import '../../features/home/presentation/cubit/home_cubit.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../injection_container.dart';
import 'route_names.dart';

class _PlaceholderPage extends StatelessWidget {
  final String name;
  const _PlaceholderPage(this.name);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(name)),
      body: Center(
        child: Text(name, style: Theme.of(context).textTheme.titleLarge),
      ),
    );
  }
}

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: RouteNames.splash,
    debugLogDiagnostics: true,
    routes: [
      // ── Auth routes (outside shell) ──────────────────────────────
      GoRoute(
        path: RouteNames.splash,
        builder: (_, __) => BlocProvider(
          create: (_) => sl<AuthCubit>(),
          child: const SplashPage(),
        ),
      ),
      GoRoute(
        path: RouteNames.login,
        builder: (_, __) => BlocProvider(
          create: (_) => sl<AuthCubit>(),
          child: const LoginPage(),
        ),
      ),
      GoRoute(
        path: RouteNames.register,
        builder: (_, __) => BlocProvider(
          create: (_) => sl<AuthCubit>(),
          child: const RegisterPage(),
        ),
      ),
      GoRoute(
        path: RouteNames.forgotPassword,
        builder: (_, __) => BlocProvider(
          create: (_) => sl<AuthCubit>(),
          child: const ForgotPasswordPage(),
        ),
      ),
      GoRoute(
        path: RouteNames.verifyOtp,
        builder: (_, state) => BlocProvider(
          create: (_) => sl<AuthCubit>(),
          child: VerifyOtpPage(email: state.extra as String),
        ),
      ),
      GoRoute(
        path: RouteNames.resetPassword,
        builder: (_, __) => BlocProvider(
          create: (_) => sl<AuthCubit>(),
          child: const ResetPasswordPage(),
        ),
      ),

      // ── Negocio detail (sin bottom nav — se implementa en feature busqueda) ──
      GoRoute(
        path: '/negocio/:id',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return _PlaceholderPage('Negocio $id');
        },
      ),

      // ── Main shell (4 tabs) ──────────────────────────────────────
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => BlocProvider(
          create: (_) => sl<AuthCubit>(),
          child: MainShell(navigationShell: navigationShell),
        ),
        branches: [
          // Tab 0: Inicio
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteNames.home,
                builder: (context, state) => BlocProvider(
                  create: (_) => sl<HomeCubit>(),
                  child: const HomePage(),
                ),
              ),
            ],
          ),

          // Tab 1: Buscar
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteNames.busqueda,
                builder: (_, __) => const _PlaceholderPage('Buscar'),
              ),
            ],
          ),

          // Tab 2: Favoritos
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteNames.favoritos,
                builder: (_, __) => const _PlaceholderPage('Favoritos'),
              ),
            ],
          ),

          // Tab 3: Perfil
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteNames.perfil,
                builder: (_, __) => const _PlaceholderPage('Perfil'),
              ),
            ],
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('Ruta no encontrada: ${state.uri}')),
    ),
  );
}
```

- [ ] **Step 2: Run all tests**

```bash
flutter test
```

Expected: all tests pass (router changes don't affect cubit tests).

- [ ] **Step 3: Commit**

```bash
git add lib/core/router/app_router.dart
git commit -m "feat(home): refactor router to StatefulShellRoute with 4-tab shell"
```

---

### Task 10: Reusable Home Widgets

**Files:**
- Create: `lib/features/home/presentation/widgets/home_header.dart`
- Create: `lib/features/home/presentation/widgets/search_bar_tap.dart`
- Create: `lib/features/home/presentation/widgets/category_chip.dart`
- Create: `lib/features/home/presentation/widgets/promo_banner.dart`
- Create: `lib/features/home/presentation/widgets/negocio_card.dart`

- [ ] **Step 1: Create HomeHeader**

```dart
// lib/features/home/presentation/widgets/home_header.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Buenos días';
    if (hour < 18) return 'Buenas tardes';
    return 'Buenas noches';
  }

  @override
  Widget build(BuildContext context) {
    final nombre = context.select<AuthCubit, String>((cubit) {
      final state = cubit.state;
      if (state is AuthAuthenticated) {
        return state.user.nombre?.split(' ').first ?? 'Usuario';
      }
      return 'Usuario';
    });

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 8, 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_greeting()}, $nombre',
                  style: AppTextStyles.heading2,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.location_on,
                        size: 14, color: AppColors.primary),
                    const SizedBox(width: 4),
                    Text('Pinar del Río',
                        style: AppTextStyles.bodySmall),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: null,
            tooltip: 'Notificaciones',
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 2: Create SearchBarTap**

```dart
// lib/features/home/presentation/widgets/search_bar_tap.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class SearchBarTap extends StatelessWidget {
  const SearchBarTap({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: GestureDetector(
        onTap: () => context.go(RouteNames.busqueda),
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: AppColors.outlineVariant),
          ),
          child: Row(
            children: [
              Icon(Icons.search, color: AppColors.onSurfaceVariant),
              const SizedBox(width: 12),
              Text(
                'Buscar productos o negocios...',
                style: AppTextStyles.body
                    .copyWith(color: AppColors.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 3: Create CategoryChip**

```dart
// lib/features/home/presentation/widgets/category_chip.dart
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/categoria_negocio.dart';

class CategoryChip extends StatelessWidget {
  final CategoriaNegocio categoria;
  final VoidCallback onTap;

  const CategoryChip({
    super.key,
    required this.categoria,
    required this.onTap,
  });

  IconData _icon() {
    return switch (categoria.icono) {
      'coffee' => Icons.coffee,
      'grass' => Icons.grass,
      'local_pharmacy' => Icons.local_pharmacy,
      'bakery_dining' => Icons.bakery_dining,
      'store' => Icons.store,
      'health_and_safety' => Icons.health_and_safety,
      'hardware' => Icons.hardware,
      'restaurant' => Icons.restaurant,
      _ => Icons.category,
    };
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 72,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(_icon(), color: AppColors.primary, size: 26),
            ),
            const SizedBox(height: 4),
            Text(
              categoria.nombre,
              style: AppTextStyles.caption,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: Create PromoBanner**

```dart
// lib/features/home/presentation/widgets/promo_banner.dart
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/promocion.dart';

class PromoBanner extends StatelessWidget {
  final Promocion promocion;
  final VoidCallback onTap;

  const PromoBanner({
    super.key,
    required this.promocion,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primary, AppColors.primaryContainer],
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.25),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'VIP',
                style: AppTextStyles.caption
                    .copyWith(color: Colors.white, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              promocion.titulo,
              style:
                  AppTextStyles.heading3.copyWith(color: Colors.white),
            ),
            const SizedBox(height: 2),
            Text(
              promocion.nombreNegocio,
              style: AppTextStyles.bodySmall
                  .copyWith(color: Colors.white.withOpacity(0.8)),
            ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 5: Create NegocioCard**

```dart
// lib/features/home/presentation/widgets/negocio_card.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/negocio_preview.dart';

class NegocioCard extends StatelessWidget {
  final NegocioPreview negocio;

  const NegocioCard({super.key, required this.negocio});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.go('/negocio/${negocio.id}'),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.store_outlined,
                    color: AppColors.onSurfaceVariant),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(negocio.nombre,
                              style: AppTextStyles.body,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                        ),
                        if (negocio.verificado) ...[
                          const SizedBox(width: 4),
                          Icon(Icons.verified,
                              size: 15, color: AppColors.secondary),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${negocio.categoria} · ${negocio.distanciaKm.toStringAsFixed(1)} km',
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: negocio.abierto
                      ? AppColors.success.withOpacity(0.12)
                      : AppColors.error.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  negocio.abierto ? 'Abierto' : 'Cerrado',
                  style: AppTextStyles.caption.copyWith(
                    color: negocio.abierto
                        ? AppColors.success
                        : AppColors.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right,
                  color: AppColors.onSurfaceVariant, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 6: Run all tests to confirm no regressions**

```bash
flutter test
```

Expected: all tests pass.

- [ ] **Step 7: Commit**

```bash
git add lib/features/home/presentation/widgets/
git commit -m "feat(home): add HomeHeader, SearchBarTap, CategoryChip, PromoBanner, NegocioCard widgets"
```

---

### Task 11: HomePage

**Files:**
- Create: `lib/features/home/presentation/pages/home_page.dart`

- [ ] **Step 1: Create HomePage**

```dart
// lib/features/home/presentation/pages/home_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/categoria_negocio.dart';
import '../../domain/entities/promocion.dart';
import '../cubit/home_cubit.dart';
import '../cubit/home_state.dart';
import '../widgets/category_chip.dart';
import '../widgets/home_header.dart';
import '../widgets/negocio_card.dart';
import '../widgets/promo_banner.dart';
import '../widgets/search_bar_tap.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    context.read<HomeCubit>().loadHome();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        if (state is HomeInitial || state is HomeLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is HomeError) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.grey),
                const SizedBox(height: 12),
                Text(state.message),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => context.read<HomeCubit>().loadHome(),
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          );
        }
        if (state is HomeLoaded) {
          return _HomeContent(state: state);
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class _HomeContent extends StatelessWidget {
  final HomeLoaded state;
  const _HomeContent({required this.state});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        const SliverToBoxAdapter(child: HomeHeader()),
        const SliverToBoxAdapter(child: SearchBarTap()),
        SliverToBoxAdapter(
          child: _CategorySection(categorias: state.categorias),
        ),
        SliverToBoxAdapter(
          child: _PromoSection(promociones: state.promociones),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: Text('Negocios cercanos', style: AppTextStyles.heading3),
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) =>
                NegocioCard(negocio: state.negocios[index]),
            childCount: state.negocios.length,
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
      ],
    );
  }
}

class _CategorySection extends StatelessWidget {
  final List<CategoriaNegocio> categorias;
  const _CategorySection({required this.categorias});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
          child: Text('Categorías', style: AppTextStyles.heading3),
        ),
        SizedBox(
          height: 88,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: categorias.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) => CategoryChip(
              categoria: categorias[index],
              onTap: () => context.go(
                RouteNames.busqueda,
                extra: categorias[index].id,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PromoSection extends StatefulWidget {
  final List<Promocion> promociones;
  const _PromoSection({required this.promociones});

  @override
  State<_PromoSection> createState() => _PromoSectionState();
}

class _PromoSectionState extends State<_PromoSection> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
          child: Text('Promociones', style: AppTextStyles.heading3),
        ),
        SizedBox(
          height: 160,
          child: PageView.builder(
            onPageChanged: (i) => setState(() => _currentIndex = i),
            itemCount: widget.promociones.length,
            itemBuilder: (context, index) => Padding(
              padding: EdgeInsets.only(
                left: index == 0 ? 16 : 8,
                right: index == widget.promociones.length - 1 ? 16 : 8,
              ),
              child: PromoBanner(
                promocion: widget.promociones[index],
                onTap: () => context
                    .go('/negocio/${widget.promociones[index].negocioId}'),
              ),
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            widget.promociones.length,
            (i) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 3, vertical: 8),
              width: _currentIndex == i ? 16 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: _currentIndex == i
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
```

- [ ] **Step 2: Run all tests**

```bash
flutter test
```

Expected: all tests pass (3 cubit tests + all auth tests).

- [ ] **Step 3: Run the app and verify the home screen**

```bash
flutter run
```

Verify:
- Splash → Login → Home navigation works
- BottomNavigationBar shows 4 tabs (Inicio, Buscar, Favoritos, Perfil)
- Home displays header with greeting and username
- Categories scroll horizontally (8 items)
- Promotions scroll horizontally with page indicator dots
- 6 business cards with open/closed badges
- Verified badge (✓) on Elena and Farmacia Vida
- Tab switching works; Inicio tab preserves scroll state
- Back gesture from Inicio tab shows exit confirmation dialog

- [ ] **Step 4: Final commit**

```bash
git add lib/features/home/presentation/pages/home_page.dart
git commit -m "feat(home): add HomePage with CustomScrollView — header, search, categories, promos, negocios"
```

---

## Post-implementation checklist

- [ ] All 3 HomeCubit tests pass
- [ ] All existing auth tests still pass
- [ ] App runs with correct navigation shell
- [ ] Home displays all mock data sections
- [ ] Back gesture shows exit dialog on Inicio tab
- [ ] Tabs switch without losing scroll state
