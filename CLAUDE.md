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

## iOS
- iOS folder scaffolded, deployment target: iOS 13.0
- Permissions in `ios/Runner/Info.plist`: location (when in use + always)
- Requires Xcode 14+ and CocoaPods
