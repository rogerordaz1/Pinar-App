# Cubamap — Home Screen & Navigation Shell
**Fecha:** 2026-05-25
**Estado:** Aprobado
**Feature branch:** feat/home-screen

---

## 1. Alcance

Esta feature cubre dos cosas que van juntas:

1. **Navigation Shell** — `StatefulShellRoute` con `BottomNavigationBar` de 4 tabs (Inicio, Buscar, Favoritos, Perfil). Es el marco permanente de todo el Mundo Cliente.
2. **Home Screen** — Primera tab real de la app: header, búsqueda, categorías, promociones y negocios cercanos, con mock data.

Las otras 3 tabs (Buscar, Favoritos, Perfil) quedan como placeholders navegables — se implementan en features posteriores.

---

## 2. Decisiones tomadas

| Decisión | Elección | Razón |
|---|---|---|
| Navegación bottom nav | `StatefulShellRoute` (go_router nativo) | Tabs preservan estado de scroll; sin refactoring al agregar deep links |
| Datos del home | Mock data en datasource | Desbloquea el UI sin depender del backend; swap = 1 línea en DI |
| Arquitectura | Clean Architecture completa (igual que auth) | Cero refactoring al conectar Supabase |
| Componente nav | `NavigationBar` (Material 3) | Consistente con el theme M3 del proyecto |

---

## 3. Navigation Shell

### Cambios en `app_router.dart`

Las rutas de auth (`/splash`, `/login`, `/register`, `/forgot-password`, `/verify-otp`, `/reset-password`) permanecen fuera del shell como rutas de nivel superior.

Se agrega un `StatefulShellRoute` con 4 branches:

```
StatefulShellRoute (builder → MainShell)
  ├── StatefulShellBranch  /home      → HomePage
  ├── StatefulShellBranch  /busqueda  → BusquedaPlaceholderPage
  ├── StatefulShellBranch  /favoritos → FavoritosPlaceholderPage
  └── StatefulShellBranch  /perfil    → PerfilPlaceholderPage
```

Las rutas profundas (`/negocio/:id`, `/negocio-dashboard`, etc.) se agregarán como subrutas dentro del branch correspondiente en features futuras.

### `MainShell` — `core/shell/main_shell.dart`

- Recibe `StatefulNavigationShell` como parámetro
- Arma un `Scaffold` con `NavigationBar` Material 3 de 4 ítems
- Ítems: Inicio (home), Buscar (search), Favoritos (favorite), Perfil (person)
- El tab activo se determina por `navigationShell.currentIndex`
- `onDestinationSelected` llama a `navigationShell.goBranch(index)`
- **Logout listener**: `BlocListener<AuthCubit, AuthState>` — si `AuthUnauthenticated`, navega a `/login` y reemplaza el stack

---

## 4. Home Screen

### 4.1 Layout

`HomePage` usa `CustomScrollView` con slivers para scroll nativo fluido.

Secciones de arriba a abajo:

| Sección | Widget | Descripción |
|---|---|---|
| Header | `HomeHeader` | Saludo ("Buenos días, {nombre}"), chip de ubicación ("📍 Pinar del Río"), icono de notificaciones |
| Búsqueda | `SearchBarTap` | Barra decorativa no editable, `onTap` navega a `/busqueda` |
| Categorías | `CategoryChip` × 8 | Scroll horizontal; icono + label por categoría |
| Promociones | `PromoBanner` en `PageView` | 3–4 banners horizontales con indicador de página; gradiente verde sobre imagen; badge "VIP" |
| Negocios cercanos | `NegocioCard` × 6–8 | Lista vertical; logo placeholder, nombre, categoría, distancia, badge abierto/cerrado |

### 4.2 Categorías mock (8 ítems)

```
Cafetería · Agropecuario · Farmacia · Panadería
Tienda · Salud · Ferretería · Restaurante
```

### 4.3 Negocios mock (6–8 ítems)

Cada `NegocioPreviews` incluye: `id`, `nombre`, `categoría`, `distanciaKm`, `abierto`, `logoUrl` (null en mock), `verificado`.

Ejemplos:
- La Panadería Elena — Panadería — 0.3 km — abierto
- Agro San Cristóbal — Agropecuario — 0.8 km — cerrado
- Farmacia Vida — Farmacia — 1.2 km — abierto
- Cafetería El Patio — Cafetería — 1.5 km — abierto
- Tienda La Esquina — Tienda — 2.0 km — abierto
- Ferretería Central — Ferretería — 2.3 km — cerrado

### 4.4 Promociones mock (3 ítems)

Cada `Promocion` incluye: `id`, `titulo`, `nombreNegocio`, `imagenUrl` (null en mock → color sólido de fondo).

---

## 5. Clean Architecture — feature `home`

```
lib/features/home/
  data/
    datasources/
      home_datasource.dart          ← abstract HomeDataSource
      mock_home_datasource.dart     ← implementación con datos hardcodeados
    models/
      negocio_preview_model.dart
      categoria_negocio_model.dart
      promocion_model.dart
    repositories/
      home_repository_impl.dart
  domain/
    entities/
      negocio_preview.dart
      categoria_negocio.dart
      promocion.dart
    repositories/
      home_repository.dart          ← abstract HomeRepository
    usecases/
      get_negocios_cercanos_usecase.dart
      get_categorias_usecase.dart
      get_promociones_usecase.dart
  presentation/
    cubit/
      home_cubit.dart
      home_state.dart
    pages/
      home_page.dart
    widgets/
      home_header.dart
      search_bar_tap.dart
      category_chip.dart
      promo_banner.dart
      negocio_card.dart
```

### Estados del `HomeCubit`

```dart
sealed class HomeState
  HomeInitial
  HomeLoading
  HomeLoaded(categorias, promociones, negocios)
  HomeError(message)
```

`HomeCubit.loadHome()` llama los 3 use cases en paralelo con `Future.wait`.

---

## 6. Swap a Supabase (cuando esté listo)

1. Crear `SupabaseHomeDataSource implements HomeDataSource`
2. En `injection_container.dart`: cambiar `MockHomeDataSource` por `SupabaseHomeDataSource`
3. El UI, el cubit y los use cases **no se tocan**

---

## 7. Registro en DI (`injection_container.dart`)

```dart
// DataSources
sl.registerLazySingleton<HomeDataSource>(() => MockHomeDataSource());

// Repositories
sl.registerLazySingleton<HomeRepository>(() => HomeRepositoryImpl(sl()));

// Use Cases
sl.registerLazySingleton(() => GetNegociosCercanosUseCase(sl()));
sl.registerLazySingleton(() => GetCategoriasUseCase(sl()));
sl.registerLazySingleton(() => GetPromocionesUseCase(sl()));

// Cubit (factory — nueva instancia por pantalla)
sl.registerFactory(() => HomeCubit(sl(), sl(), sl()));
```

---

## 8. Navegación desde el Home

| Acción | Destino |
|---|---|
| Tap en `SearchBarTap` | `context.go(RouteNames.busqueda)` |
| Tap en `CategoryChip` | `context.go(RouteNames.busqueda, extra: categoriaId)` |
| Tap en `NegocioCard` | `context.go('/negocio/${negocio.id}')` |
| Tap en `PromoBanner` | `context.go('/negocio/${promo.negocioId}')` |

---

## 9. Tests

Siguiendo el mismo patrón de `auth`:

- `HomeCubit` unit tests con `bloc_test` + `mocktail`
- Estados a cubrir: `HomeLoaded` con datos mock, `HomeError` si un use case falla
- No se testean widgets en esta fase (igual que auth)

---

## 10. Fuera de alcance (esta feature)

- Geolocalización real (la distancia en mock es hardcodeada)
- Queries a Supabase
- Implementación real de Buscar, Favoritos, Perfil
- Push notifications
- Pantalla de Notificaciones (el ícono en header es decorativo por ahora)
