# Design Spec: Feature — Favoritos

**Date:** 2026-05-29
**Status:** Approved
**Branch:** feat/favoritos (to be created from dev)

---

## 1. Goal

Allow authenticated users to save/unsave favorite businesses and products. Favorites persist across sessions in Supabase and are accessible from the Favoritos tab and the Profile page.

---

## 2. Architecture

Clean Architecture following the existing pattern (domain / data / presentation per feature). Two separate global cubits — one for business favorites, one for product favorites — both provided in `main.dart` via `MultiBlocProvider`.

**Feature folder:** `lib/features/favoritos/`

---

## 3. Database (Supabase)

Two new tables with Row Level Security:

```sql
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

Migration file: `supabase/migrations/20260529000001_favoritos_tables.sql`

---

## 4. Domain

### Entities

**`negocio_favorito.dart`**
```dart
class NegocioFavorito extends Equatable {
  final String id;
  final String negocioId;
  final String userId;
  final DateTime createdAt;
}
```

**`producto_favorito.dart`**
```dart
class ProductoFavorito extends Equatable {
  final String id;
  final String productoId;
  final String negocioId;
  final String userId;
  final DateTime createdAt;
}
```

### Repositories (abstract)
- `negocios_favoritos_repository.dart` — `getNegocios()`, `toggle(negocioId)`
- `productos_favoritos_repository.dart` — `getProductos()`, `toggle(productoId, negocioId)`

Both return `Either<Failure, T>` (using `dartz`).

### Use Cases
- `GetNegociosFavoritosUseCase` — no params
- `ToggleNegocioFavoritoUseCase` — param: `negocioId`
- `GetProductosFavoritosUseCase` — no params
- `ToggleProductoFavoritoUseCase` — params: `productoId`, `negocioId`

---

## 5. Data

### Datasource
Single abstract interface `FavoritosDataSource` with concrete `SupabaseFavoritosDataSource`. Uses Supabase `.from('negocios_favoritos')` / `.from('productos_favoritos')` queries filtered by current user.

- `getNegocios()` → `List<Map<String, dynamic>>`
- `toggleNegocio(negocioId)` → upsert or delete by (user_id, negocio_id)
- `getProductos()` → `List<Map<String, dynamic>>`
- `toggleProducto(productoId, negocioId)` → upsert or delete by (user_id, producto_id)

### Repository Impls
- `NegociosFavoritosRepositoryImpl`
- `ProductosFavoritosRepositoryImpl`

Both map datasource maps to domain entities using `NegocioFavoritoModel` / `ProductoFavoritoModel`.

---

## 6. Presentation

### State (sealed, no freezed)

**Negocios:**
```dart
sealed class NegociosFavoritosState { ... }
final class NegociosFavoritosInitial extends NegociosFavoritosState { ... }
final class NegociosFavoritosLoading extends NegociosFavoritosState { ... }
final class NegociosFavoritosLoaded extends NegociosFavoritosState {
  final List<NegocioFavorito> negocios;
  final Set<String> negocioIds; // O(1) lookup
}
final class NegociosFavoritosError extends NegociosFavoritosState {
  final String message;
}
```

**Productos:** same pattern with `ProductoFavorito`.

### Cubits

**`NegociosFavoritosCubit`**
- `loadFavoritos()` — emit Loading → call use case → emit Loaded/Error
- `toggleFavorito(negocioId)` — **optimistic update**: flip the ID in the Set immediately, then call use case; revert on error

**`ProductosFavoritosCubit`** — same pattern with `productoId` + `negocioId`.

Both are **global providers** in `main.dart`, initialized with `..loadFavoritos()`.

### Page: `FavoritosPage`

- `DefaultTabController` with 2 tabs: **Negocios** | **Productos**
- `AppBar` with tab bar, white background, green "Pinar Market" title
- Each tab: `BlocBuilder` handling Loading / Loaded (empty or with items) / Error states
- Empty state: icon + "Aún no tienes favoritos" message

### Widgets
- `NegocioFavoritoCard` — shows logo, name, distance, open/closed badge, rating, red heart icon (tappable to remove), "Ver Detalles" button
- `ProductoFavoritoCard` — shows product image, name, business name, price, red heart icon (tappable to remove), "Ver Detalles" button

### Heart icon wiring (other screens)
- `ResultadoCard` (`busqueda` feature) — wire `Icons.favorite_border` / `Icons.favorite` to `ProductosFavoritosCubit`
- `NegocioDetallePage` — add heart icon in AppBar to `NegociosFavoritosCubit`
- `ProfilePage` — "Mis Favoritos" and "Productos Guardados" navigate to `FavoritosPage` (with appropriate initial tab)

---

## 7. Navigation

- **Favoritos tab** in the existing 4-tab shell navigates to `FavoritosPage` (replaces current placeholder)
- `RouteNames.favoritos = '/favoritos'` already in the shell
- "Mis Favoritos" in ProfilePage → `/favoritos` (Negocios tab)
- "Productos Guardados" in ProfilePage → `/favoritos` (Productos tab)

---

## 8. Dependency Injection

New `_registerFavoritos()` function in `injection_container.dart`:
```dart
// Cubits
sl.registerFactory(() => NegociosFavoritosCubit(getNegociosFavoritosUseCase: sl(), toggleNegocioFavoritoUseCase: sl()));
sl.registerFactory(() => ProductosFavoritosCubit(getProductosFavoritosUseCase: sl(), toggleProductoFavoritoUseCase: sl()));
// Use cases
sl.registerLazySingleton(() => GetNegociosFavoritosUseCase(sl()));
sl.registerLazySingleton(() => ToggleNegocioFavoritoUseCase(sl()));
sl.registerLazySingleton(() => GetProductosFavoritosUseCase(sl()));
sl.registerLazySingleton(() => ToggleProductoFavoritoUseCase(sl()));
// Repositories
sl.registerLazySingleton<NegociosFavoritosRepository>(() => NegociosFavoritosRepositoryImpl(sl()));
sl.registerLazySingleton<ProductosFavoritosRepository>(() => ProductosFavoritosRepositoryImpl(sl()));
// Datasource (shared)
sl.registerLazySingleton<FavoritosDataSource>(() => SupabaseFavoritosDataSource(sl()));
```

---

## 9. Barrel

`lib/features/favoritos/favoritos.dart` exports cubits, states, page, and entities.

---

## 10. Tests

- `negocios_favoritos_repository_impl_test.dart` — Right(list), Left(Failure), calls datasource correctly
- `productos_favoritos_repository_impl_test.dart` — same
- `negocios_favoritos_cubit_test.dart` — initial state, Loading→Loaded, optimistic toggle, revert on error
- `productos_favoritos_cubit_test.dart` — same

---

## 11. Visual Design

Stitch screen: **"Favoritos - Negocios Final"** (ID: `3c0b2445ea2a4921bd3ec7c0724be4bf`)
Project: Pinar Cerca App Design (`926884834730667074`)

Design follows the Resultados de Búsqueda pattern:
- White AppBar with green "Pinar Market" title
- Food photography cards
- ABIERTO/CERRADO badges
- Red filled heart icons
- Large green prices
- 5-tab bottom nav with Favoritos active

---

## 12. Acceptance Criteria

1. Tapping the heart on any product/business toggles favorite state instantly (optimistic)
2. Favorites persist after app restart
3. FavoritosPage shows two tabs with the correct lists
4. Empty state renders when no favorites exist
5. Error state renders with retry button when Supabase call fails
6. ProfilePage "Mis Favoritos" and "Productos Guardados" navigate correctly
7. All new tests pass (`flutter test`)
8. `flutter analyze` reports no new errors
