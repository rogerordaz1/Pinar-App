# Pinar App — Claude Code Guide

## Project
Flutter app to find products available in nearby businesses in Cuba.

## Tech Stack
- **State Management**: flutter_bloc / BLoC pattern
- **DI**: get_it
- **Backend**: supabase_flutter
- **Navigation**: go_router with StatefulShellRoute (4-tab shell)
- **Code Generation**: freezed + json_serializable + build_runner
- **Architecture**: Clean Architecture (domain / data / presentation per feature)

## Branching Strategy
```
main        — production-only. Never commit directly. Merge from dev when releasing.
dev         — integration branch. All feature branches merge here via PR.
feat/<name> — one branch per feature. Always branch off dev, never off main.
```

**Rules:**
- Every new feature or fix gets its own `feat/<name>` branch created from `dev`
- Commits go on the feature branch, never directly on `dev` or `main`
- Merge feature branches into `dev` first; only `dev` → `main` when shipping to production
- Branch naming: `feat/`, `fix/`, `chore/`, `docs/` prefixes

## Commands
```bash
flutter pub get                  # install dependencies
flutter run -d <device-id>       # run on device/simulator
flutter test                     # run all tests
dart run build_runner build      # regenerate freezed/json files
```

## Architecture
```
lib/
  core/
    router/       # go_router config (app_router.dart, route_names.dart)
    shell/        # StatefulShellRoute shell (main_shell.dart)
    theme/        # colors, typography
    usecases/     # base UseCase<Type, Params>
    utils/        # shared utilities
  features/
    auth/         # login, register, forgot password, OTP
    home/         # home feed, categories, negocios, promos
  injection_container.dart
  app.dart
  main.dart
```

## Barrel Files (importaciones)
Cada capa tiene un archivo barril. En páginas y widgets, usar siempre el barrel — nunca rutas profundas individuales.

| Barrel | Path | Exporta |
|---|---|---|
| Core | `lib/core/core.dart` | AppColors, AppTextStyles, AppTheme, RouteNames, ExitDialog |
| Auth | `lib/features/auth/auth.dart` | AuthCubit, AuthState, UserEntity |
| Home | `lib/features/home/home.dart` | HomeCubit, HomeState, entidades, widgets |

**Reglas:**
- Las **páginas** importan solo el barrel de su feature + `core.dart`
- Los **widgets** importan `core.dart` + barrel de otro feature si lo necesitan; **nunca importan el barrel de su propio feature** (circular)
- Los widgets mantienen importación directa de sus propias entidades
- Al agregar una nueva feature, crear `lib/features/<nombre>/<nombre>.dart` y añadirla a esta tabla

## BLoC / Cubit Providers
Todos los cubits se declaran en `main.dart` dentro del `MultiBlocProvider` que envuelve `runApp`. Esto garantiza acceso desde cualquier parte del árbol, incluyendo rutas de go_router.

```dart
// main.dart
runApp(
  MultiBlocProvider(
    providers: [
      BlocProvider(create: (_) => di.sl<AuthCubit>()..checkAuth()),
      BlocProvider(create: (_) => di.sl<HomeCubit>()..loadHome()),
      // Agregar futuros cubits aquí
    ],
    child: const App(),
  ),
);
```

- `AuthCubit` va aquí con `..checkAuth()` para restaurar sesión al arrancar
- Cada cubit de feature se agrega con su método de carga inicial si aplica
- El router (`app_router.dart`) y `app.dart` no proveen ningún cubit

## Widget Rules
- **Prefer `StatelessWidget` always.** Only use `StatefulWidget` when there is no other option: e.g., `WidgetsBindingObserver`, managing a `TextEditingController`/`AnimationController` that cannot live in a Cubit, or wrapping a third-party widget that requires it.
- State that affects the UI goes in a Cubit/Bloc — never in `setState`.
- If you find yourself reaching for `StatefulWidget`, first ask: can this live in the Cubit?

## iOS
- iOS folder scaffolded, deployment target: iOS 13.0
- Permissions in `ios/Runner/Info.plist`: location (when in use + always)
- Requires Xcode 14+ and CocoaPods
