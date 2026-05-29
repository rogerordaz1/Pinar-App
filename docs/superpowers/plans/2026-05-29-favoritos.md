# Favoritos Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a Favoritos feature so users can save/unsave favorite businesses and products, with optimistic UI updates and persistence in Supabase.

**Architecture:** Two global cubits (`NegociosFavoritosCubit` and `ProductosFavoritosCubit`) each hold a `Set<String>` of IDs for O(1) lookups and a list of full entities for the FavoritosPage. Optimistic toggle: flip the Set immediately, call Supabase, revert on error. Both cubits are provided in `main.dart` so any screen can read/toggle favorites.

**Tech Stack:** Flutter BLoC (flutter_bloc), Supabase (supabase_flutter), dartz, get_it, mocktail (tests), bloc_test (tests), equatable.

---

## File Map

### New files
```
supabase/migrations/20260529000001_favoritos_tables.sql

lib/features/favoritos/
  domain/
    entities/negocio_favorito.dart
    entities/producto_favorito.dart
    repositories/negocios_favoritos_repository.dart
    repositories/productos_favoritos_repository.dart
    usecases/get_negocios_favoritos_usecase.dart
    usecases/toggle_negocio_favorito_usecase.dart
    usecases/get_productos_favoritos_usecase.dart
    usecases/toggle_producto_favorito_usecase.dart
  data/
    models/negocio_favorito_model.dart
    models/producto_favorito_model.dart
    datasources/favoritos_datasource.dart
    datasources/supabase_favoritos_datasource.dart
    repositories/negocios_favoritos_repository_impl.dart
    repositories/productos_favoritos_repository_impl.dart
  presentation/
    cubit/negocios_favoritos_state.dart
    cubit/negocios_favoritos_cubit.dart
    cubit/productos_favoritos_state.dart
    cubit/productos_favoritos_cubit.dart
    pages/favoritos_page.dart
    widgets/negocio_favorito_card.dart
    widgets/producto_favorito_card.dart
  favoritos.dart

test/features/favoritos/
  data/repositories/negocios_favoritos_repository_impl_test.dart
  data/repositories/productos_favoritos_repository_impl_test.dart
  presentation/cubit/negocios_favoritos_cubit_test.dart
  presentation/cubit/productos_favoritos_cubit_test.dart
```

### Modified files
```
lib/injection_container.dart           — register favoritos DI
lib/main.dart                          — add cubits to MultiBlocProvider
lib/core/router/app_router.dart        — replace _PlaceholderPage('Favoritos') with FavoritosPage
lib/features/busqueda/presentation/widgets/resultado_card.dart  — wire heart to ProductosFavoritosCubit
lib/features/negocio_detalle/presentation/pages/negocio_detalle_page.dart — add heart in AppBar
lib/features/auth/presentation/pages/profile_page.dart  — wire navigation
```

---

## Task 1: SQL Migration

**Files:**
- Create: `supabase/migrations/20260529000001_favoritos_tables.sql`

- [ ] **Step 1: Create the migration file**

```sql
-- supabase/migrations/20260529000001_favoritos_tables.sql

create table public.negocios_favoritos (
  id         uuid primary key default gen_random_uuid(),
  user_id    uuid not null references auth.users(id) on delete cascade,
  negocio_id uuid not null,
  created_at timestamptz default now(),
  unique (user_id, negocio_id)
);
alter table public.negocios_favoritos enable row level security;
create policy "usuario ve sus favoritos" on public.negocios_favoritos
  for all using (auth.uid() = user_id);

create table public.productos_favoritos (
  id          uuid primary key default gen_random_uuid(),
  user_id     uuid not null references auth.users(id) on delete cascade,
  producto_id uuid not null,
  negocio_id  uuid not null,
  created_at  timestamptz default now(),
  unique (user_id, producto_id)
);
alter table public.productos_favoritos enable row level security;
create policy "usuario ve sus favoritos" on public.productos_favoritos
  for all using (auth.uid() = user_id);
```

- [ ] **Step 2: Run the migration in Supabase Dashboard**

Go to Supabase Dashboard → SQL Editor → paste and run the file contents. Verify both tables appear under Table Editor.

- [ ] **Step 3: Commit**

```bash
git add supabase/migrations/20260529000001_favoritos_tables.sql
git commit -m "chore(db): add negocios_favoritos and productos_favoritos tables with RLS"
```

---

## Task 2: Domain Entities

**Files:**
- Create: `lib/features/favoritos/domain/entities/negocio_favorito.dart`
- Create: `lib/features/favoritos/domain/entities/producto_favorito.dart`

- [ ] **Step 1: Create `negocio_favorito.dart`**

```dart
import 'package:equatable/equatable.dart';

class NegocioFavorito extends Equatable {
  final String id;
  final String negocioId;
  final String negocioNombre;
  final String? logoUrl;
  final bool negocioAbierto;
  final double calificacion;
  final bool negocioVerificado;
  final DateTime createdAt;

  const NegocioFavorito({
    required this.id,
    required this.negocioId,
    required this.negocioNombre,
    this.logoUrl,
    required this.negocioAbierto,
    required this.calificacion,
    required this.negocioVerificado,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id, negocioId, negocioNombre, logoUrl,
        negocioAbierto, calificacion, negocioVerificado, createdAt,
      ];
}
```

- [ ] **Step 2: Create `producto_favorito.dart`**

```dart
import 'package:equatable/equatable.dart';

class ProductoFavorito extends Equatable {
  final String id;
  final String productoId;
  final String productoNombre;
  final String negocioId;
  final String negocioNombre;
  final double precio;
  final String? imageUrl;
  final bool negocioAbierto;
  final DateTime createdAt;

  const ProductoFavorito({
    required this.id,
    required this.productoId,
    required this.productoNombre,
    required this.negocioId,
    required this.negocioNombre,
    required this.precio,
    this.imageUrl,
    required this.negocioAbierto,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id, productoId, productoNombre, negocioId, negocioNombre,
        precio, imageUrl, negocioAbierto, createdAt,
      ];
}
```

- [ ] **Step 3: Commit**

```bash
git add lib/features/favoritos/domain/entities/
git commit -m "feat(favoritos): add NegocioFavorito and ProductoFavorito domain entities"
```

---

## Task 3: Domain Repositories (Abstract) + Use Cases

**Files:**
- Create: `lib/features/favoritos/domain/repositories/negocios_favoritos_repository.dart`
- Create: `lib/features/favoritos/domain/repositories/productos_favoritos_repository.dart`
- Create: `lib/features/favoritos/domain/usecases/get_negocios_favoritos_usecase.dart`
- Create: `lib/features/favoritos/domain/usecases/toggle_negocio_favorito_usecase.dart`
- Create: `lib/features/favoritos/domain/usecases/get_productos_favoritos_usecase.dart`
- Create: `lib/features/favoritos/domain/usecases/toggle_producto_favorito_usecase.dart`

- [ ] **Step 1: Create `negocios_favoritos_repository.dart`**

```dart
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/negocio_favorito.dart';

abstract class NegociosFavoritosRepository {
  Future<Either<Failure, List<NegocioFavorito>>> getNegocios();
  Future<Either<Failure, void>> addNegocio(String negocioId);
  Future<Either<Failure, void>> removeNegocio(String negocioId);
}
```

- [ ] **Step 2: Create `productos_favoritos_repository.dart`**

```dart
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/producto_favorito.dart';

abstract class ProductosFavoritosRepository {
  Future<Either<Failure, List<ProductoFavorito>>> getProductos();
  Future<Either<Failure, void>> addProducto(String productoId, String negocioId);
  Future<Either<Failure, void>> removeProducto(String productoId);
}
```

- [ ] **Step 3: Create `get_negocios_favoritos_usecase.dart`**

```dart
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/negocio_favorito.dart';
import '../repositories/negocios_favoritos_repository.dart';

class GetNegociosFavoritosUseCase
    extends UseCase<List<NegocioFavorito>, NoParams> {
  final NegociosFavoritosRepository repository;

  GetNegociosFavoritosUseCase(this.repository);

  @override
  Future<Either<Failure, List<NegocioFavorito>>> call(NoParams params) =>
      repository.getNegocios();
}
```

- [ ] **Step 4: Create `toggle_negocio_favorito_usecase.dart`**

```dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/negocios_favoritos_repository.dart';

class ToggleNegocioFavoritoParams extends Equatable {
  final String negocioId;
  final bool add;

  const ToggleNegocioFavoritoParams({
    required this.negocioId,
    required this.add,
  });

  @override
  List<Object> get props => [negocioId, add];
}

class ToggleNegocioFavoritoUseCase
    extends UseCase<void, ToggleNegocioFavoritoParams> {
  final NegociosFavoritosRepository repository;

  ToggleNegocioFavoritoUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(ToggleNegocioFavoritoParams params) =>
      params.add
          ? repository.addNegocio(params.negocioId)
          : repository.removeNegocio(params.negocioId);
}
```

- [ ] **Step 5: Create `get_productos_favoritos_usecase.dart`**

```dart
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/producto_favorito.dart';
import '../repositories/productos_favoritos_repository.dart';

class GetProductosFavoritosUseCase
    extends UseCase<List<ProductoFavorito>, NoParams> {
  final ProductosFavoritosRepository repository;

  GetProductosFavoritosUseCase(this.repository);

  @override
  Future<Either<Failure, List<ProductoFavorito>>> call(NoParams params) =>
      repository.getProductos();
}
```

- [ ] **Step 6: Create `toggle_producto_favorito_usecase.dart`**

```dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/productos_favoritos_repository.dart';

class ToggleProductoFavoritoParams extends Equatable {
  final String productoId;
  final String negocioId;
  final bool add;

  const ToggleProductoFavoritoParams({
    required this.productoId,
    required this.negocioId,
    required this.add,
  });

  @override
  List<Object> get props => [productoId, negocioId, add];
}

class ToggleProductoFavoritoUseCase
    extends UseCase<void, ToggleProductoFavoritoParams> {
  final ProductosFavoritosRepository repository;

  ToggleProductoFavoritoUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(ToggleProductoFavoritoParams params) =>
      params.add
          ? repository.addProducto(params.productoId, params.negocioId)
          : repository.removeProducto(params.productoId);
}
```

- [ ] **Step 7: Commit**

```bash
git add lib/features/favoritos/domain/
git commit -m "feat(favoritos): add domain repositories and use cases"
```

---

## Task 4: Data Models

**Files:**
- Create: `lib/features/favoritos/data/models/negocio_favorito_model.dart`
- Create: `lib/features/favoritos/data/models/producto_favorito_model.dart`

- [ ] **Step 1: Create `negocio_favorito_model.dart`**

The Supabase query uses `select('*, negocios(nombre, logo_url, abierto, calificacion_cache, verificado)')`, which returns a nested `negocios` map.

```dart
import '../../domain/entities/negocio_favorito.dart';

class NegocioFavoritoModel {
  final String id;
  final String negocioId;
  final String negocioNombre;
  final String? logoUrl;
  final bool negocioAbierto;
  final double calificacion;
  final bool negocioVerificado;
  final DateTime createdAt;

  const NegocioFavoritoModel({
    required this.id,
    required this.negocioId,
    required this.negocioNombre,
    this.logoUrl,
    required this.negocioAbierto,
    required this.calificacion,
    required this.negocioVerificado,
    required this.createdAt,
  });

  factory NegocioFavoritoModel.fromMap(Map<String, dynamic> map) {
    final negocio = map['negocios'] as Map<String, dynamic>;
    return NegocioFavoritoModel(
      id: map['id'] as String,
      negocioId: map['negocio_id'] as String,
      negocioNombre: negocio['nombre'] as String,
      logoUrl: negocio['logo_url'] as String?,
      negocioAbierto: negocio['abierto'] as bool? ?? false,
      calificacion:
          (negocio['calificacion_cache'] as num?)?.toDouble() ?? 0.0,
      negocioVerificado: negocio['verificado'] as bool? ?? false,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  NegocioFavorito toEntity() => NegocioFavorito(
        id: id,
        negocioId: negocioId,
        negocioNombre: negocioNombre,
        logoUrl: logoUrl,
        negocioAbierto: negocioAbierto,
        calificacion: calificacion,
        negocioVerificado: negocioVerificado,
        createdAt: createdAt,
      );
}
```

- [ ] **Step 2: Create `producto_favorito_model.dart`**

The Supabase query uses `select('*, productos(nombre, precio, imagen_url, negocios(nombre, abierto))')`.

```dart
import '../../domain/entities/producto_favorito.dart';

class ProductoFavoritoModel {
  final String id;
  final String productoId;
  final String productoNombre;
  final String negocioId;
  final String negocioNombre;
  final double precio;
  final String? imageUrl;
  final bool negocioAbierto;
  final DateTime createdAt;

  const ProductoFavoritoModel({
    required this.id,
    required this.productoId,
    required this.productoNombre,
    required this.negocioId,
    required this.negocioNombre,
    required this.precio,
    this.imageUrl,
    required this.negocioAbierto,
    required this.createdAt,
  });

  factory ProductoFavoritoModel.fromMap(Map<String, dynamic> map) {
    final producto = map['productos'] as Map<String, dynamic>;
    final negocio = producto['negocios'] as Map<String, dynamic>;
    return ProductoFavoritoModel(
      id: map['id'] as String,
      productoId: map['producto_id'] as String,
      productoNombre: producto['nombre'] as String,
      negocioId: map['negocio_id'] as String,
      negocioNombre: negocio['nombre'] as String,
      precio: (producto['precio'] as num).toDouble(),
      imageUrl: producto['imagen_url'] as String?,
      negocioAbierto: negocio['abierto'] as bool? ?? false,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  ProductoFavorito toEntity() => ProductoFavorito(
        id: id,
        productoId: productoId,
        productoNombre: productoNombre,
        negocioId: negocioId,
        negocioNombre: negocioNombre,
        precio: precio,
        imageUrl: imageUrl,
        negocioAbierto: negocioAbierto,
        createdAt: createdAt,
      );
}
```

- [ ] **Step 3: Commit**

```bash
git add lib/features/favoritos/data/models/
git commit -m "feat(favoritos): add NegocioFavoritoModel and ProductoFavoritoModel"
```

---

## Task 5: Datasource

**Files:**
- Create: `lib/features/favoritos/data/datasources/favoritos_datasource.dart`
- Create: `lib/features/favoritos/data/datasources/supabase_favoritos_datasource.dart`

- [ ] **Step 1: Create `favoritos_datasource.dart`**

```dart
import '../models/negocio_favorito_model.dart';
import '../models/producto_favorito_model.dart';

abstract class FavoritosDataSource {
  Future<List<NegocioFavoritoModel>> getNegocios();
  Future<void> addNegocio(String negocioId);
  Future<void> removeNegocio(String negocioId);
  Future<List<ProductoFavoritoModel>> getProductos();
  Future<void> addProducto(String productoId, String negocioId);
  Future<void> removeProducto(String productoId);
}
```

- [ ] **Step 2: Create `supabase_favoritos_datasource.dart`**

```dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/negocio_favorito_model.dart';
import '../models/producto_favorito_model.dart';
import 'favoritos_datasource.dart';

class SupabaseFavoritosDataSource implements FavoritosDataSource {
  final SupabaseClient _client;

  SupabaseFavoritosDataSource(this._client);

  @override
  Future<List<NegocioFavoritoModel>> getNegocios() async {
    final data = await _client
        .from('negocios_favoritos')
        .select('*, negocios(nombre, logo_url, abierto, calificacion_cache, verificado)')
        .order('created_at', ascending: false) as List<dynamic>;
    return data
        .cast<Map<String, dynamic>>()
        .map(NegocioFavoritoModel.fromMap)
        .toList();
  }

  @override
  Future<void> addNegocio(String negocioId) async {
    final userId = _client.auth.currentUser!.id;
    await _client.from('negocios_favoritos').insert({
      'user_id': userId,
      'negocio_id': negocioId,
    });
  }

  @override
  Future<void> removeNegocio(String negocioId) async {
    await _client
        .from('negocios_favoritos')
        .delete()
        .eq('negocio_id', negocioId);
  }

  @override
  Future<List<ProductoFavoritoModel>> getProductos() async {
    final data = await _client
        .from('productos_favoritos')
        .select('*, productos(nombre, precio, imagen_url, negocios(nombre, abierto))')
        .order('created_at', ascending: false) as List<dynamic>;
    return data
        .cast<Map<String, dynamic>>()
        .map(ProductoFavoritoModel.fromMap)
        .toList();
  }

  @override
  Future<void> addProducto(String productoId, String negocioId) async {
    final userId = _client.auth.currentUser!.id;
    await _client.from('productos_favoritos').insert({
      'user_id': userId,
      'producto_id': productoId,
      'negocio_id': negocioId,
    });
  }

  @override
  Future<void> removeProducto(String productoId) async {
    await _client
        .from('productos_favoritos')
        .delete()
        .eq('producto_id', productoId);
  }
}
```

- [ ] **Step 3: Commit**

```bash
git add lib/features/favoritos/data/datasources/
git commit -m "feat(favoritos): add FavoritosDataSource and Supabase implementation"
```

---

## Task 6: Repository Implementations + Tests (TDD)

**Files:**
- Create: `test/features/favoritos/data/repositories/negocios_favoritos_repository_impl_test.dart`
- Create: `lib/features/favoritos/data/repositories/negocios_favoritos_repository_impl.dart`
- Create: `test/features/favoritos/data/repositories/productos_favoritos_repository_impl_test.dart`
- Create: `lib/features/favoritos/data/repositories/productos_favoritos_repository_impl.dart`

- [ ] **Step 1: Write failing test for `NegociosFavoritosRepositoryImpl`**

```dart
// test/features/favoritos/data/repositories/negocios_favoritos_repository_impl_test.dart
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cubamap/core/errors/failures.dart';
import 'package:cubamap/features/favoritos/data/datasources/favoritos_datasource.dart';
import 'package:cubamap/features/favoritos/data/models/negocio_favorito_model.dart';
import 'package:cubamap/features/favoritos/data/repositories/negocios_favoritos_repository_impl.dart';
import 'package:cubamap/features/favoritos/domain/entities/negocio_favorito.dart';

class MockFavoritosDataSource extends Mock implements FavoritosDataSource {}

void main() {
  late NegociosFavoritosRepositoryImpl repo;
  late MockFavoritosDataSource mockDs;

  final tModel = NegocioFavoritoModel(
    id: 'fav001',
    negocioId: 'n001',
    negocioNombre: 'Panadería Elena',
    logoUrl: null,
    negocioAbierto: true,
    calificacion: 4.8,
    negocioVerificado: true,
    createdAt: DateTime(2026, 5, 29),
  );

  setUp(() {
    mockDs = MockFavoritosDataSource();
    repo = NegociosFavoritosRepositoryImpl(mockDs);
  });

  group('getNegocios', () {
    test('devuelve Right(List<NegocioFavorito>) cuando el datasource tiene éxito',
        () async {
      when(() => mockDs.getNegocios()).thenAnswer((_) async => [tModel]);

      final result = await repo.getNegocios();

      expect(result, isA<Right<Failure, List<NegocioFavorito>>>());
      result.fold(
        (_) => fail('debería ser Right'),
        (list) {
          expect(list.length, 1);
          expect(list.first.negocioNombre, 'Panadería Elena');
        },
      );
    });

    test('devuelve Left(ServerFailure) cuando el datasource lanza Exception',
        () async {
      when(() => mockDs.getNegocios()).thenThrow(Exception('error de red'));

      final result = await repo.getNegocios();

      expect(result, isA<Left<Failure, List<NegocioFavorito>>>());
      result.fold(
        (f) => expect(f, isA<ServerFailure>()),
        (_) => fail('debería ser Left'),
      );
    });

    test('llama al datasource una vez', () async {
      when(() => mockDs.getNegocios()).thenAnswer((_) async => [tModel]);
      await repo.getNegocios();
      verify(() => mockDs.getNegocios()).called(1);
    });
  });

  group('addNegocio', () {
    test('devuelve Right(void) cuando el datasource tiene éxito', () async {
      when(() => mockDs.addNegocio('n001')).thenAnswer((_) async {});

      final result = await repo.addNegocio('n001');

      expect(result, isA<Right<Failure, void>>());
    });

    test('devuelve Left(ServerFailure) cuando el datasource lanza Exception',
        () async {
      when(() => mockDs.addNegocio('n001')).thenThrow(Exception('error'));

      final result = await repo.addNegocio('n001');

      expect(result, isA<Left<Failure, void>>());
    });
  });

  group('removeNegocio', () {
    test('devuelve Right(void) cuando el datasource tiene éxito', () async {
      when(() => mockDs.removeNegocio('n001')).thenAnswer((_) async {});

      final result = await repo.removeNegocio('n001');

      expect(result, isA<Right<Failure, void>>());
    });

    test('devuelve Left(ServerFailure) cuando el datasource lanza Exception',
        () async {
      when(() => mockDs.removeNegocio('n001')).thenThrow(Exception('error'));

      final result = await repo.removeNegocio('n001');

      expect(result, isA<Left<Failure, void>>());
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

```bash
flutter test test/features/favoritos/data/repositories/negocios_favoritos_repository_impl_test.dart
```

Expected: error `Target of URI doesn't exist 'package:cubamap/features/favoritos/data/repositories/negocios_favoritos_repository_impl.dart'`

- [ ] **Step 3: Implement `NegociosFavoritosRepositoryImpl`**

```dart
// lib/features/favoritos/data/repositories/negocios_favoritos_repository_impl.dart
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/negocio_favorito.dart';
import '../../domain/repositories/negocios_favoritos_repository.dart';
import '../datasources/favoritos_datasource.dart';

class NegociosFavoritosRepositoryImpl implements NegociosFavoritosRepository {
  final FavoritosDataSource _dataSource;

  NegociosFavoritosRepositoryImpl(this._dataSource);

  @override
  Future<Either<Failure, List<NegocioFavorito>>> getNegocios() async {
    try {
      final models = await _dataSource.getNegocios();
      return Right(models.map((m) => m.toEntity()).toList());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> addNegocio(String negocioId) async {
    try {
      await _dataSource.addNegocio(negocioId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> removeNegocio(String negocioId) async {
    try {
      await _dataSource.removeNegocio(negocioId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

```bash
flutter test test/features/favoritos/data/repositories/negocios_favoritos_repository_impl_test.dart
```

Expected: All tests pass.

- [ ] **Step 5: Write failing test for `ProductosFavoritosRepositoryImpl`**

```dart
// test/features/favoritos/data/repositories/productos_favoritos_repository_impl_test.dart
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cubamap/core/errors/failures.dart';
import 'package:cubamap/features/favoritos/data/datasources/favoritos_datasource.dart';
import 'package:cubamap/features/favoritos/data/models/producto_favorito_model.dart';
import 'package:cubamap/features/favoritos/data/repositories/productos_favoritos_repository_impl.dart';
import 'package:cubamap/features/favoritos/domain/entities/producto_favorito.dart';

class MockFavoritosDataSource extends Mock implements FavoritosDataSource {}

void main() {
  late ProductosFavoritosRepositoryImpl repo;
  late MockFavoritosDataSource mockDs;

  final tModel = ProductoFavoritoModel(
    id: 'fav002',
    productoId: 'p001',
    productoNombre: 'Pan Criollo',
    negocioId: 'n001',
    negocioNombre: 'Panadería Elena',
    precio: 25.0,
    imageUrl: null,
    negocioAbierto: true,
    createdAt: DateTime(2026, 5, 29),
  );

  setUp(() {
    mockDs = MockFavoritosDataSource();
    repo = ProductosFavoritosRepositoryImpl(mockDs);
  });

  group('getProductos', () {
    test('devuelve Right(List<ProductoFavorito>) cuando el datasource tiene éxito',
        () async {
      when(() => mockDs.getProductos()).thenAnswer((_) async => [tModel]);

      final result = await repo.getProductos();

      expect(result, isA<Right<Failure, List<ProductoFavorito>>>());
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
      when(() => mockDs.getProductos()).thenThrow(Exception('error de red'));

      final result = await repo.getProductos();

      expect(result, isA<Left<Failure, List<ProductoFavorito>>>());
      result.fold(
        (f) => expect(f, isA<ServerFailure>()),
        (_) => fail('debería ser Left'),
      );
    });
  });

  group('addProducto', () {
    test('devuelve Right(void) cuando el datasource tiene éxito', () async {
      when(() => mockDs.addProducto('p001', 'n001'))
          .thenAnswer((_) async {});

      final result = await repo.addProducto('p001', 'n001');

      expect(result, isA<Right<Failure, void>>());
    });

    test('devuelve Left(ServerFailure) cuando el datasource lanza Exception',
        () async {
      when(() => mockDs.addProducto('p001', 'n001'))
          .thenThrow(Exception('error'));

      final result = await repo.addProducto('p001', 'n001');

      expect(result, isA<Left<Failure, void>>());
    });
  });

  group('removeProducto', () {
    test('devuelve Right(void) cuando el datasource tiene éxito', () async {
      when(() => mockDs.removeProducto('p001')).thenAnswer((_) async {});

      final result = await repo.removeProducto('p001');

      expect(result, isA<Right<Failure, void>>());
    });

    test('devuelve Left(ServerFailure) cuando el datasource lanza Exception',
        () async {
      when(() => mockDs.removeProducto('p001')).thenThrow(Exception('error'));

      final result = await repo.removeProducto('p001');

      expect(result, isA<Left<Failure, void>>());
    });
  });
}
```

- [ ] **Step 6: Run test to verify it fails**

```bash
flutter test test/features/favoritos/data/repositories/productos_favoritos_repository_impl_test.dart
```

Expected: error `Target of URI doesn't exist 'package:cubamap/features/favoritos/data/repositories/productos_favoritos_repository_impl.dart'`

- [ ] **Step 7: Implement `ProductosFavoritosRepositoryImpl`**

```dart
// lib/features/favoritos/data/repositories/productos_favoritos_repository_impl.dart
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/producto_favorito.dart';
import '../../domain/repositories/productos_favoritos_repository.dart';
import '../datasources/favoritos_datasource.dart';

class ProductosFavoritosRepositoryImpl implements ProductosFavoritosRepository {
  final FavoritosDataSource _dataSource;

  ProductosFavoritosRepositoryImpl(this._dataSource);

  @override
  Future<Either<Failure, List<ProductoFavorito>>> getProductos() async {
    try {
      final models = await _dataSource.getProductos();
      return Right(models.map((m) => m.toEntity()).toList());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> addProducto(
      String productoId, String negocioId) async {
    try {
      await _dataSource.addProducto(productoId, negocioId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> removeProducto(String productoId) async {
    try {
      await _dataSource.removeProducto(productoId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
```

- [ ] **Step 8: Run all repository tests**

```bash
flutter test test/features/favoritos/data/repositories/
```

Expected: All 12 tests pass.

- [ ] **Step 9: Commit**

```bash
git add lib/features/favoritos/data/repositories/ test/features/favoritos/data/
git commit -m "feat(favoritos): add repository implementations with tests"
```

---

## Task 7: Cubit States

**Files:**
- Create: `lib/features/favoritos/presentation/cubit/negocios_favoritos_state.dart`
- Create: `lib/features/favoritos/presentation/cubit/productos_favoritos_state.dart`

- [ ] **Step 1: Create `negocios_favoritos_state.dart`**

```dart
import '../../../domain/entities/negocio_favorito.dart';

sealed class NegociosFavoritosState {
  const NegociosFavoritosState();
}

final class NegociosFavoritosInitial extends NegociosFavoritosState {
  const NegociosFavoritosInitial();
}

final class NegociosFavoritosLoading extends NegociosFavoritosState {
  const NegociosFavoritosLoading();
}

final class NegociosFavoritosLoaded extends NegociosFavoritosState {
  final List<NegocioFavorito> negocios;
  final Set<String> negocioIds;

  const NegociosFavoritosLoaded({
    required this.negocios,
    required this.negocioIds,
  });
}

final class NegociosFavoritosError extends NegociosFavoritosState {
  final String message;
  const NegociosFavoritosError(this.message);
}
```

- [ ] **Step 2: Create `productos_favoritos_state.dart`**

```dart
import '../../../domain/entities/producto_favorito.dart';

sealed class ProductosFavoritosState {
  const ProductosFavoritosState();
}

final class ProductosFavoritosInitial extends ProductosFavoritosState {
  const ProductosFavoritosInitial();
}

final class ProductosFavoritosLoading extends ProductosFavoritosState {
  const ProductosFavoritosLoading();
}

final class ProductosFavoritosLoaded extends ProductosFavoritosState {
  final List<ProductoFavorito> productos;
  final Set<String> productoIds;

  const ProductosFavoritosLoaded({
    required this.productos,
    required this.productoIds,
  });
}

final class ProductosFavoritosError extends ProductosFavoritosState {
  final String message;
  const ProductosFavoritosError(this.message);
}
```

- [ ] **Step 3: Commit**

```bash
git add lib/features/favoritos/presentation/cubit/*_state.dart
git commit -m "feat(favoritos): add NegociosFavoritosState and ProductosFavoritosState"
```

---

## Task 8: Cubits + Tests (TDD)

**Files:**
- Create: `test/features/favoritos/presentation/cubit/negocios_favoritos_cubit_test.dart`
- Create: `lib/features/favoritos/presentation/cubit/negocios_favoritos_cubit.dart`
- Create: `test/features/favoritos/presentation/cubit/productos_favoritos_cubit_test.dart`
- Create: `lib/features/favoritos/presentation/cubit/productos_favoritos_cubit.dart`

- [ ] **Step 1: Write failing test for `NegociosFavoritosCubit`**

```dart
// test/features/favoritos/presentation/cubit/negocios_favoritos_cubit_test.dart
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
```

- [ ] **Step 2: Run test to verify it fails**

```bash
flutter test test/features/favoritos/presentation/cubit/negocios_favoritos_cubit_test.dart
```

Expected: error about missing `NegociosFavoritosCubit`.

- [ ] **Step 3: Implement `NegociosFavoritosCubit`**

```dart
// lib/features/favoritos/presentation/cubit/negocios_favoritos_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/get_negocios_favoritos_usecase.dart';
import '../../domain/usecases/toggle_negocio_favorito_usecase.dart';
import 'negocios_favoritos_state.dart';

class NegociosFavoritosCubit extends Cubit<NegociosFavoritosState> {
  final GetNegociosFavoritosUseCase _get;
  final ToggleNegocioFavoritoUseCase _toggle;

  NegociosFavoritosCubit({
    required GetNegociosFavoritosUseCase getNegociosFavoritosUseCase,
    required ToggleNegocioFavoritoUseCase toggleNegocioFavoritoUseCase,
  })  : _get = getNegociosFavoritosUseCase,
        _toggle = toggleNegocioFavoritoUseCase,
        super(const NegociosFavoritosInitial());

  Future<void> loadFavoritos() async {
    emit(const NegociosFavoritosLoading());
    final result = await _get(const NoParams());
    if (isClosed) return;
    result.fold(
      (failure) => emit(NegociosFavoritosError(failure.message)),
      (negocios) => emit(NegociosFavoritosLoaded(
        negocios: negocios,
        negocioIds: negocios.map((n) => n.negocioId).toSet(),
      )),
    );
  }

  Future<void> toggleFavorito(String negocioId) async {
    final current = state;
    if (current is! NegociosFavoritosLoaded) return;

    final isAdding = !current.negocioIds.contains(negocioId);
    final optimisticIds = Set<String>.from(current.negocioIds);
    if (isAdding) {
      optimisticIds.add(negocioId);
    } else {
      optimisticIds.remove(negocioId);
    }
    final optimisticNegocios = isAdding
        ? current.negocios
        : current.negocios.where((n) => n.negocioId != negocioId).toList();
    emit(NegociosFavoritosLoaded(
        negocios: optimisticNegocios, negocioIds: optimisticIds));

    final result = await _toggle(ToggleNegocioFavoritoParams(
      negocioId: negocioId,
      add: isAdding,
    ));
    if (isClosed) return;
    result.fold(
      (_) => emit(current),
      (_) => loadFavoritos(),
    );
  }

  bool isFavorito(String negocioId) {
    final s = state;
    return s is NegociosFavoritosLoaded && s.negocioIds.contains(negocioId);
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

```bash
flutter test test/features/favoritos/presentation/cubit/negocios_favoritos_cubit_test.dart
```

Expected: All tests pass.

- [ ] **Step 5: Write failing test for `ProductosFavoritosCubit`**

```dart
// test/features/favoritos/presentation/cubit/productos_favoritos_cubit_test.dart
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
```

- [ ] **Step 6: Run test to verify it fails**

```bash
flutter test test/features/favoritos/presentation/cubit/productos_favoritos_cubit_test.dart
```

Expected: error about missing `ProductosFavoritosCubit`.

- [ ] **Step 7: Implement `ProductosFavoritosCubit`**

```dart
// lib/features/favoritos/presentation/cubit/productos_favoritos_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/get_productos_favoritos_usecase.dart';
import '../../domain/usecases/toggle_producto_favorito_usecase.dart';
import 'productos_favoritos_state.dart';

class ProductosFavoritosCubit extends Cubit<ProductosFavoritosState> {
  final GetProductosFavoritosUseCase _get;
  final ToggleProductoFavoritoUseCase _toggle;

  ProductosFavoritosCubit({
    required GetProductosFavoritosUseCase getProductosFavoritosUseCase,
    required ToggleProductoFavoritoUseCase toggleProductoFavoritoUseCase,
  })  : _get = getProductosFavoritosUseCase,
        _toggle = toggleProductoFavoritoUseCase,
        super(const ProductosFavoritosInitial());

  Future<void> loadFavoritos() async {
    emit(const ProductosFavoritosLoading());
    final result = await _get(const NoParams());
    if (isClosed) return;
    result.fold(
      (failure) => emit(ProductosFavoritosError(failure.message)),
      (productos) => emit(ProductosFavoritosLoaded(
        productos: productos,
        productoIds: productos.map((p) => p.productoId).toSet(),
      )),
    );
  }

  Future<void> toggleFavorito(String productoId, String negocioId) async {
    final current = state;
    if (current is! ProductosFavoritosLoaded) return;

    final isAdding = !current.productoIds.contains(productoId);
    final optimisticIds = Set<String>.from(current.productoIds);
    if (isAdding) {
      optimisticIds.add(productoId);
    } else {
      optimisticIds.remove(productoId);
    }
    final optimisticProductos = isAdding
        ? current.productos
        : current.productos
            .where((p) => p.productoId != productoId)
            .toList();
    emit(ProductosFavoritosLoaded(
        productos: optimisticProductos, productoIds: optimisticIds));

    final result = await _toggle(ToggleProductoFavoritoParams(
      productoId: productoId,
      negocioId: negocioId,
      add: isAdding,
    ));
    if (isClosed) return;
    result.fold(
      (_) => emit(current),
      (_) => loadFavoritos(),
    );
  }

  bool isFavorito(String productoId) {
    final s = state;
    return s is ProductosFavoritosLoaded && s.productoIds.contains(productoId);
  }
}
```

- [ ] **Step 8: Run all cubit tests**

```bash
flutter test test/features/favoritos/presentation/cubit/
```

Expected: All tests pass.

- [ ] **Step 9: Commit**

```bash
git add lib/features/favoritos/presentation/cubit/ test/features/favoritos/presentation/
git commit -m "feat(favoritos): add NegociosFavoritosCubit and ProductosFavoritosCubit with tests"
```

---

## Task 9: Page + Widgets

**Files:**
- Create: `lib/features/favoritos/presentation/widgets/negocio_favorito_card.dart`
- Create: `lib/features/favoritos/presentation/widgets/producto_favorito_card.dart`
- Create: `lib/features/favoritos/presentation/pages/favoritos_page.dart`

- [ ] **Step 1: Create `negocio_favorito_card.dart`**

```dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/core.dart';
import '../../domain/entities/negocio_favorito.dart';
import '../cubit/negocios_favoritos_cubit.dart';

class NegocioFavoritoCard extends StatelessWidget {
  final NegocioFavorito favorito;

  const NegocioFavoritoCard({super.key, required this.favorito});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImage(),
            const SizedBox(width: 12),
            Expanded(child: _buildContent(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    if (favorito.logoUrl != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: CachedNetworkImage(
          imageUrl: favorito.logoUrl!,
          width: 72,
          height: 72,
          fit: BoxFit.cover,
          placeholder: (_, __) => _imagePlaceholder(),
          errorWidget: (_, __, ___) => _imagePlaceholder(),
        ),
      );
    }
    return _imagePlaceholder();
  }

  Widget _imagePlaceholder() {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(Icons.store_outlined,
          color: AppColors.outline, size: 28),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                favorito.negocioNombre,
                style: AppTextStyles.body
                    .copyWith(fontWeight: FontWeight.w600),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            GestureDetector(
              onTap: () => context
                  .read<NegociosFavoritosCubit>()
                  .toggleFavorito(favorito.negocioId),
              child: Icon(Icons.favorite, size: 20, color: AppColors.error),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            _OpenBadge(abierto: favorito.negocioAbierto),
            if (favorito.calificacion > 0) ...[
              const SizedBox(width: 6),
              Icon(Icons.star_rounded, size: 12, color: AppColors.warning),
              Text(
                favorito.calificacion.toStringAsFixed(1),
                style: AppTextStyles.caption
                    .copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ],
        ),
        const SizedBox(height: 6),
        SizedBox(
          height: 28,
          child: OutlinedButton(
            onPressed: () =>
                context.push('/negocio/${favorito.negocioId}'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              textStyle: AppTextStyles.caption
                  .copyWith(fontWeight: FontWeight.w600),
              side: BorderSide(color: AppColors.primary),
            ),
            child: const Text('Ver Detalles'),
          ),
        ),
      ],
    );
  }
}

class _OpenBadge extends StatelessWidget {
  final bool abierto;
  const _OpenBadge({required this.abierto});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: abierto
            ? AppColors.success.withValues(alpha: 0.12)
            : AppColors.error.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        abierto ? 'Abierto' : 'Cerrado',
        style: AppTextStyles.caption.copyWith(
          color: abierto ? AppColors.success : AppColors.error,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Create `producto_favorito_card.dart`**

```dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/core.dart';
import '../../domain/entities/producto_favorito.dart';
import '../cubit/productos_favoritos_cubit.dart';

class ProductoFavoritoCard extends StatelessWidget {
  final ProductoFavorito favorito;

  const ProductoFavoritoCard({super.key, required this.favorito});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImage(),
            const SizedBox(width: 12),
            Expanded(child: _buildContent(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    if (favorito.imageUrl != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: CachedNetworkImage(
          imageUrl: favorito.imageUrl!,
          width: 72,
          height: 72,
          fit: BoxFit.cover,
          placeholder: (_, __) => _imagePlaceholder(),
          errorWidget: (_, __, ___) => _imagePlaceholder(),
        ),
      );
    }
    return _imagePlaceholder();
  }

  Widget _imagePlaceholder() {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(Icons.fastfood_outlined,
          color: AppColors.outline, size: 28),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                favorito.productoNombre,
                style: AppTextStyles.body
                    .copyWith(fontWeight: FontWeight.w600),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            GestureDetector(
              onTap: () => context
                  .read<ProductosFavoritosCubit>()
                  .toggleFavorito(favorito.productoId, favorito.negocioId),
              child: Icon(Icons.favorite, size: 20, color: AppColors.error),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          favorito.negocioNombre,
          style: AppTextStyles.caption
              .copyWith(color: AppColors.onSurface),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Text(
              'CUP ${favorito.precio.toStringAsFixed(0)}',
              style: AppTextStyles.body.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        SizedBox(
          height: 28,
          child: OutlinedButton(
            onPressed: () =>
                context.push('/negocio/${favorito.negocioId}'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              textStyle: AppTextStyles.caption
                  .copyWith(fontWeight: FontWeight.w600),
              side: BorderSide(color: AppColors.primary),
            ),
            child: const Text('Ver Detalles'),
          ),
        ),
      ],
    );
  }
}
```

- [ ] **Step 3: Create `favoritos_page.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/core.dart';
import '../cubit/negocios_favoritos_cubit.dart';
import '../cubit/negocios_favoritos_state.dart';
import '../cubit/productos_favoritos_cubit.dart';
import '../cubit/productos_favoritos_state.dart';
import '../widgets/negocio_favorito_card.dart';
import '../widgets/producto_favorito_card.dart';

class FavoritosPage extends StatelessWidget {
  final int initialTabIndex;

  const FavoritosPage({super.key, this.initialTabIndex = 0});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      initialIndex: initialTabIndex,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.surfaceContainerLowest,
          elevation: 0,
          scrolledUnderElevation: 0,
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.storefront_outlined,
                  color: AppColors.primary,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Pinar Market',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                ),
              ),
            ],
          ),
          bottom: TabBar(
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.outline,
            indicatorColor: AppColors.primary,
            tabs: const [
              Tab(text: 'Negocios'),
              Tab(text: 'Productos'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _NegociosTab(),
            _ProductosTab(),
          ],
        ),
      ),
    );
  }
}

class _NegociosTab extends StatelessWidget {
  const _NegociosTab();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NegociosFavoritosCubit, NegociosFavoritosState>(
      builder: (context, state) => switch (state) {
        NegociosFavoritosInitial() ||
        NegociosFavoritosLoading() =>
          const Center(child: CircularProgressIndicator()),
        NegociosFavoritosLoaded(:final negocios) when negocios.isEmpty =>
          const _EmptyState(label: 'Aún no tienes negocios favoritos'),
        NegociosFavoritosLoaded(:final negocios) => ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: negocios.length,
            itemBuilder: (_, i) =>
                NegocioFavoritoCard(favorito: negocios[i]),
          ),
        NegociosFavoritosError(:final message) => _ErrorState(
            message: message,
            onRetry: () =>
                context.read<NegociosFavoritosCubit>().loadFavoritos(),
          ),
      },
    );
  }
}

class _ProductosTab extends StatelessWidget {
  const _ProductosTab();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductosFavoritosCubit, ProductosFavoritosState>(
      builder: (context, state) => switch (state) {
        ProductosFavoritosInitial() ||
        ProductosFavoritosLoading() =>
          const Center(child: CircularProgressIndicator()),
        ProductosFavoritosLoaded(:final productos) when productos.isEmpty =>
          const _EmptyState(label: 'Aún no tienes productos favoritos'),
        ProductosFavoritosLoaded(:final productos) => ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: productos.length,
            itemBuilder: (_, i) =>
                ProductoFavoritoCard(favorito: productos[i]),
          ),
        ProductosFavoritosError(:final message) => _ErrorState(
            message: message,
            onRetry: () =>
                context.read<ProductosFavoritosCubit>().loadFavoritos(),
          ),
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String label;
  const _EmptyState({required this.label});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.favorite_border, size: 64, color: AppColors.outline),
          const SizedBox(height: 16),
          Text(label,
              style: AppTextStyles.body
                  .copyWith(color: AppColors.onSurfaceVariant)),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message,
              style:
                  AppTextStyles.body.copyWith(color: AppColors.error)),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: onRetry, child: const Text('Reintentar')),
        ],
      ),
    );
  }
}
```

- [ ] **Step 4: Commit**

```bash
git add lib/features/favoritos/presentation/
git commit -m "feat(favoritos): add FavoritosPage with two tabs and favorito cards"
```

---

## Task 10: Barrel File

**Files:**
- Create: `lib/features/favoritos/favoritos.dart`

- [ ] **Step 1: Create `favoritos.dart`**

```dart
export 'domain/entities/negocio_favorito.dart';
export 'domain/entities/producto_favorito.dart';
export 'domain/usecases/toggle_negocio_favorito_usecase.dart';
export 'domain/usecases/toggle_producto_favorito_usecase.dart';
export 'presentation/cubit/negocios_favoritos_cubit.dart';
export 'presentation/cubit/negocios_favoritos_state.dart';
export 'presentation/cubit/productos_favoritos_cubit.dart';
export 'presentation/cubit/productos_favoritos_state.dart';
export 'presentation/pages/favoritos_page.dart';
```

- [ ] **Step 2: Commit**

```bash
git add lib/features/favoritos/favoritos.dart
git commit -m "feat(favoritos): add favoritos barrel file"
```

---

## Task 11: Dependency Injection

**Files:**
- Modify: `lib/injection_container.dart`

- [ ] **Step 1: Add imports to `injection_container.dart`**

Add these imports at the top of the file (after the existing imports):

```dart
import 'features/favoritos/data/datasources/favoritos_datasource.dart';
import 'features/favoritos/data/datasources/supabase_favoritos_datasource.dart';
import 'features/favoritos/data/repositories/negocios_favoritos_repository_impl.dart';
import 'features/favoritos/data/repositories/productos_favoritos_repository_impl.dart';
import 'features/favoritos/domain/repositories/negocios_favoritos_repository.dart';
import 'features/favoritos/domain/repositories/productos_favoritos_repository.dart';
import 'features/favoritos/domain/usecases/get_negocios_favoritos_usecase.dart';
import 'features/favoritos/domain/usecases/get_productos_favoritos_usecase.dart';
import 'features/favoritos/domain/usecases/toggle_negocio_favorito_usecase.dart';
import 'features/favoritos/domain/usecases/toggle_producto_favorito_usecase.dart';
import 'features/favoritos/presentation/cubit/negocios_favoritos_cubit.dart';
import 'features/favoritos/presentation/cubit/productos_favoritos_cubit.dart';
```

- [ ] **Step 2: Add `_registerFavoritos()` call inside `_registerFeatures()`**

In the `_registerFeatures()` method, add `_registerFavoritos();` after `_registerCategoriaProductos();`:

```dart
Future<void> _registerFeatures() async {
  await _registerAuth();
  _registerHome();
  _registerNegocioDetalle();
  _registerBusqueda();
  _registerCategoriaProductos();
  _registerFavoritos();          // ← add this line
}
```

- [ ] **Step 3: Add `_registerFavoritos()` function**

Add at the end of the file:

```dart
void _registerFavoritos() {
  sl.registerFactory(
    () => NegociosFavoritosCubit(
      getNegociosFavoritosUseCase: sl(),
      toggleNegocioFavoritoUseCase: sl(),
    ),
  );
  sl.registerFactory(
    () => ProductosFavoritosCubit(
      getProductosFavoritosUseCase: sl(),
      toggleProductoFavoritoUseCase: sl(),
    ),
  );
  sl.registerLazySingleton(() => GetNegociosFavoritosUseCase(sl()));
  sl.registerLazySingleton(() => ToggleNegocioFavoritoUseCase(sl()));
  sl.registerLazySingleton(() => GetProductosFavoritosUseCase(sl()));
  sl.registerLazySingleton(() => ToggleProductoFavoritoUseCase(sl()));
  sl.registerLazySingleton<NegociosFavoritosRepository>(
    () => NegociosFavoritosRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<ProductosFavoritosRepository>(
    () => ProductosFavoritosRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<FavoritosDataSource>(
    () => SupabaseFavoritosDataSource(sl()),
  );
}
```

- [ ] **Step 4: Commit**

```bash
git add lib/injection_container.dart
git commit -m "feat(favoritos): register favoritos dependencies in injection container"
```

---

## Task 12: Wire Cubits in `main.dart`

**Files:**
- Modify: `lib/main.dart`

- [ ] **Step 1: Add imports to `main.dart`**

Add these two import lines after the existing feature imports:

```dart
import 'features/favoritos/presentation/cubit/negocios_favoritos_cubit.dart';
import 'features/favoritos/presentation/cubit/productos_favoritos_cubit.dart';
```

- [ ] **Step 2: Add both cubits to `MultiBlocProvider`**

Replace the `MultiBlocProvider` `providers` list:

```dart
providers: [
  BlocProvider(create: (_) => di.sl<AuthCubit>()),
  BlocProvider(create: (_) => di.sl<HomeCubit>()..loadHome()),
  BlocProvider(create: (_) => di.sl<BusquedaCubit>()..init()),
  BlocProvider(
    create: (_) => di.sl<NegociosFavoritosCubit>()..loadFavoritos(),
  ),
  BlocProvider(
    create: (_) => di.sl<ProductosFavoritosCubit>()..loadFavoritos(),
  ),
],
```

- [ ] **Step 3: Commit**

```bash
git add lib/main.dart
git commit -m "feat(favoritos): add NegociosFavoritosCubit and ProductosFavoritosCubit to MultiBlocProvider"
```

---

## Task 13: Router — Replace Placeholder with `FavoritosPage`

**Files:**
- Modify: `lib/core/router/app_router.dart`

- [ ] **Step 1: Add import for `FavoritosPage`**

Add import after the existing feature imports at the top of `app_router.dart`:

```dart
import '../../features/favoritos/favoritos.dart';
```

- [ ] **Step 2: Replace the Favoritos shell branch**

Find this block in the shell's `StatefulShellRoute.indexedStack` (Tab 2 — Favoritos):

```dart
// Tab 2: Favoritos
StatefulShellBranch(
  routes: [
    GoRoute(
      path: RouteNames.favoritos,
      builder: (_, __) => const _PlaceholderPage('Favoritos'),
    ),
  ],
),
```

Replace it with:

```dart
// Tab 2: Favoritos
StatefulShellBranch(
  routes: [
    GoRoute(
      path: RouteNames.favoritos,
      builder: (_, state) {
        final tab = (state.extra as int?) ?? 0;
        return FavoritosPage(initialTabIndex: tab);
      },
    ),
  ],
),
```

- [ ] **Step 3: Commit**

```bash
git add lib/core/router/app_router.dart
git commit -m "feat(favoritos): replace Favoritos placeholder with FavoritosPage in router"
```

---

## Task 14: Wire Heart Icon in `ResultadoCard`

**Files:**
- Modify: `lib/features/busqueda/presentation/widgets/resultado_card.dart`

- [ ] **Step 1: Add `flutter_bloc` and `favoritos` imports**

`resultado_card.dart` is at `lib/features/busqueda/presentation/widgets/`. From there, `../../../` goes up to `lib/features/`. So the path to the favoritos barrel is `../../../favoritos/favoritos.dart`.

Add these imports at the top of `resultado_card.dart` (after the existing imports):

```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../favoritos/favoritos.dart';
```

- [ ] **Step 2: Replace the static heart icon with a reactive one**

Find this in `_buildContent`:

```dart
Icon(Icons.favorite_border,
    size: 18, color: AppColors.outline),
```

Replace with:

```dart
BlocBuilder<ProductosFavoritosCubit, ProductosFavoritosState>(
  builder: (context, state) {
    final isFav = context
        .read<ProductosFavoritosCubit>()
        .isFavorito(resultado.productoId);
    return GestureDetector(
      onTap: () => context
          .read<ProductosFavoritosCubit>()
          .toggleFavorito(resultado.productoId, resultado.negocioId),
      child: Icon(
        isFav ? Icons.favorite : Icons.favorite_border,
        size: 18,
        color: isFav ? AppColors.error : AppColors.outline,
      ),
    );
  },
),
```

- [ ] **Step 3: Commit**

```bash
git add lib/features/busqueda/presentation/widgets/resultado_card.dart
git commit -m "feat(favoritos): wire heart icon in ResultadoCard to ProductosFavoritosCubit"
```

---

## Task 15: Add Heart Icon to `NegocioDetallePage`

**Files:**
- Modify: `lib/features/negocio_detalle/presentation/pages/negocio_detalle_page.dart`

- [ ] **Step 1: Add imports**

Add these imports at the top of `negocio_detalle_page.dart`:

```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../favoritos/favoritos.dart';
```

- [ ] **Step 2: Add heart icon to AppBar actions**

Find the `actions` list in the AppBar:

```dart
actions: [
  IconButton(
    icon: const Icon(Icons.notifications_outlined, color: AppColors.primary),
    onPressed: () {},
  ),
  const SizedBox(width: 4),
],
```

Replace with:

```dart
actions: [
  BlocBuilder<NegociosFavoritosCubit, NegociosFavoritosState>(
    builder: (context, _) {
      final isFav = context
          .read<NegociosFavoritosCubit>()
          .isFavorito(negocioId);
      return IconButton(
        icon: Icon(
          isFav ? Icons.favorite : Icons.favorite_border,
          color: isFav ? AppColors.error : AppColors.primary,
        ),
        onPressed: () => context
            .read<NegociosFavoritosCubit>()
            .toggleFavorito(negocioId),
      );
    },
  ),
  IconButton(
    icon: const Icon(Icons.notifications_outlined, color: AppColors.primary),
    onPressed: () {},
  ),
  const SizedBox(width: 4),
],
```

- [ ] **Step 3: Commit**

```bash
git add lib/features/negocio_detalle/presentation/pages/negocio_detalle_page.dart
git commit -m "feat(favoritos): add heart toggle to NegocioDetallePage AppBar"
```

---

## Task 16: Wire ProfilePage Navigation

**Files:**
- Modify: `lib/features/auth/presentation/pages/profile_page.dart`

- [ ] **Step 1: Add go_router import**

The file already imports `core.dart` but needs go_router. Add:

```dart
import 'package:go_router/go_router.dart';
```

- [ ] **Step 2: Wire "Mis Favoritos" navigation (tab 0 — Negocios)**

Find:

```dart
ProfileTile(
  icon: Icons.favorite_outline,
  label: 'Mis Favoritos',
  onTap: null,
),
```

Replace with:

```dart
ProfileTile(
  icon: Icons.favorite_outline,
  label: 'Mis Favoritos',
  onTap: () => context.go(RouteNames.favoritos),
),
```

- [ ] **Step 3: Wire "Productos Guardados" navigation (tab 1 — Productos)**

Find:

```dart
ProfileTile(
  icon: Icons.bookmark_outline,
  label: 'Productos Guardados',
  onTap: null,
),
```

Replace with:

```dart
ProfileTile(
  icon: Icons.bookmark_outline,
  label: 'Productos Guardados',
  onTap: () => context.go(RouteNames.favoritos, extra: 1),
),
```

- [ ] **Step 4: Commit**

```bash
git add lib/features/auth/presentation/pages/profile_page.dart
git commit -m "feat(favoritos): wire Mis Favoritos and Productos Guardados navigation in ProfilePage"
```

---

## Task 17: Final Verification

- [ ] **Step 1: Run `flutter analyze`**

```bash
flutter analyze
```

Expected: No new errors or warnings.

- [ ] **Step 2: Run all tests**

```bash
flutter test
```

Expected: All tests pass (existing ~86 + ~16 new = ~102 total).

- [ ] **Step 3: Smoke-test checklist (manual, on simulator)**

1. Open app → tap Favoritos tab → FavoritosPage loads with two tabs
2. Both tabs show empty state ("Aún no tienes…")
3. Go to Buscar → search "pan" → tap heart on a result → heart turns red, no crash
4. Go back to Favoritos → Productos tab → saved product appears
5. In NegocioDetallePage → heart icon shows in AppBar → tap → turns red
6. Go to Favoritos → Negocios tab → negocio appears
7. Tap heart again (from Negocios list) → card disappears optimistically
8. ProfilePage → "Mis Favoritos" → navigates to Favoritos (Negocios tab)
9. ProfilePage → "Productos Guardados" → navigates to Favoritos (Productos tab)
10. Force-kill and reopen app → favorites are still saved (loaded from Supabase)
