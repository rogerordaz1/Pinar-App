# Design Spec: Feature — Editar Perfil

**Date:** 2026-05-29
**Status:** Approved
**Branch:** feat/perfil (desde dev)

---

## 1. Goal

Permitir al usuario autenticado editar su nombre, foto de perfil y dirección. La dirección almacena coordenadas GPS (lat/lng) como base para futuras funciones de proximidad y mapa.

---

## 2. Architecture

Clean Architecture dentro de la feature `auth` existente — no se crea una nueva feature folder. Se añaden: una migración SQL, campos nuevos en `UserEntity`/`UserModel`, un use case `UpdateProfileUseCase`, un método nuevo en el datasource, y un `EditProfileCubit` con su página `EditProfilePage`.

**Paquete nuevo:** `image_picker` (para cámara/galería).

---

## 3. Database (Supabase)

Migración: `supabase/migrations/20260529000002_users_profile_columns.sql`

```sql
alter table public.users
  add column if not exists direccion text,
  add column if not exists lat       double precision,
  add column if not exists lng       double precision;
```

`avatar_url` ya existe. `lat`/`lng` son opcionales — se rellenan solo cuando el usuario toca "Usar mi ubicación actual". Alimentarán el mapa en una iteración futura.

---

## 4. Domain

### UserEntity (modificación)

Añadir tres campos al `UserEntity` existente y a `UserModel`:

```dart
final String? direccion;
final double? lat;
final double? lng;
```

`copyWith` y `props` se actualizan en consecuencia.

### Use Case

**`UpdateProfileUseCase`** — `UseCase<UserEntity, UpdateProfileParams>`

```dart
class UpdateProfileParams extends Equatable {
  final String nombre;
  final String? direccion;
  final double? lat;
  final double? lng;
  final String? avatarLocalPath; // ruta local del archivo si el usuario cambió la foto
}
```

Devuelve `Either<Failure, UserEntity>` con la entidad actualizada (construida desde los datos confirmados por Supabase).

### Repository (abstract)

`AuthRepository` gana:

```dart
Future<Either<Failure, UserEntity>> updateProfile(UpdateProfileParams params);
```

---

## 5. Data

### Datasource

`AuthDataSource` gana `updateProfile(UpdateProfileParams params) → Future<UserModel>`.

`SupabaseAuthDataSource.updateProfile`:
1. Si `avatarLocalPath != null`: sube el archivo a Storage bucket `avatars` con path `{userId}/avatar.jpg` (upsert), obtiene la URL pública.
2. `client.from('users').update({nombre, direccion, lat, lng, avatar_url}).eq('id', userId).select().single()` — devuelve la fila actualizada.
3. `client.auth.updateUser(UserAttributes(data: {'nombre': nombre}))` — sincroniza el metadata de auth (en paralelo con `Future.wait`, no bloquea el update principal).
4. Retorna `UserModel.fromMap(data)`.

### UserModel (modificación)

`fromMap` lee `direccion`, `lat`, `lng` de la respuesta. `toEntity()` los mapea.

### Repository Impl

`AuthRepositoryImpl.updateProfile` — llama datasource en try/catch, retorna `Right(model.toEntity())` o `Left(ServerFailure)`.

---

## 6. Presentation

### Estado (sealed, sin freezed)

```dart
sealed class EditProfileState { const EditProfileState(); }
final class EditProfileIdle    extends EditProfileState { const EditProfileIdle(); }
final class EditProfileSaving  extends EditProfileState { const EditProfileSaving(); }
final class EditProfileSuccess extends EditProfileState {
  final UserEntity user;
  const EditProfileSuccess(this.user);
}
final class EditProfileError   extends EditProfileState {
  final String message;
  const EditProfileError(this.message);
}
```

### EditProfileCubit

```dart
class EditProfileCubit extends Cubit<EditProfileState> {
  final UpdateProfileUseCase updateProfileUseCase;
  final AuthCubit authCubit;     // recibido por constructor
}
```

**Métodos:**
- `save({required String nombre, String? direccion, double? lat, double? lng, String? avatarLocalPath})` — emite `EditProfileSaving` → llama use case → en éxito: llama `authCubit.updateUser(user)` y emite `EditProfileSuccess(user)`; en error: emite `EditProfileError(msg)`.
- No hay estado persistente del form en el cubit — los valores viven en `TextEditingController`s de la página.

### AuthCubit (modificación mínima)

Añadir método:
```dart
void updateUser(UserEntity user) {
  if (state is AuthAuthenticated) {
    emit(AuthAuthenticated(user: user));
  }
}
```

### EditProfilePage

Ruta: `/perfil/editar` — fuera del shell (sin bottom nav), igual que `NegocioDetallePage`.

`StatefulWidget` (necesita `TextEditingController`s para nombre y dirección, y `_avatarFile` local para la preview).

**Layout:**
- `AppBar` verde con título "Editar Perfil" y back button.
- `ListView` con:
  - **Avatar section**: círculo con foto/inicial, badge 📷. Tap → `showModalBottomSheet` con opciones "Cámara" y "Galería" → `image_picker`. Preview local inmediata (no espera a Supabase).
  - **Card de formulario**: campo Nombre (editable), campo Email (read-only, estilo gris), campo Dirección (editable) + botón "📍 Usar mi ubicación actual".
  - **Botón Guardar**: verde, ancho completo. Muestra `CircularProgressIndicator` en estado `EditProfileSaving`.

**"Usar mi ubicación actual":**
- Llama `geolocator.getCurrentPosition()`.
- Intenta reverse geocoding con el paquete `geocoding` para rellenar el campo de texto (best-effort; si falla, el campo queda vacío pero lat/lng se guardan igual).
- Guarda lat/lng en variables locales del widget para incluirlos en `save()`.

**BlocListener en EditProfilePage:**
- `EditProfileSuccess` → `context.pop()` + `ScaffoldMessenger.of(context).showSnackBar(...)` verde "Perfil actualizado correctamente".
- `EditProfileError` → SnackBar rojo con el mensaje.

### ProfileHeader (modificación)

Añadir `avatarUrl` a `ProfileHeader`: si está presente, muestra `CachedNetworkImage` en lugar de la inicial. Ya existe `cached_network_image` en el proyecto.

### ProfilePage (modificación)

Añadir ícono ✏️ como `actions` en el AppBar del shell cuando el tab activo es Perfil — o alternativamente un botón "Editar perfil" en el `ProfileHeader`. Se implementa como un `IconButton` en el `ProfileHeader` que llama `context.push(RouteNames.editarPerfil)`.

---

## 7. Navigation

```dart
// route_names.dart
static const String editarPerfil = '/perfil/editar';
```

Nueva ruta en `app_router.dart` fuera del shell:
```dart
GoRoute(
  path: '/perfil/editar',
  builder: (context, _) => BlocProvider(
    create: (_) => di.sl.get<EditProfileCubit>(param1: context.read<AuthCubit>()),
    child: const EditProfilePage(),
  ),
),
```

El `context.read<AuthCubit>()` en el builder captura la instancia global del `MultiBlocProvider`, garantizando que `EditProfileCubit` opera sobre el mismo estado de autenticación que el resto de la app.

---

## 8. Dependency Injection

```dart
void _registerEditProfile() {
  // authCubit NO se inyecta desde get_it — se pasa desde el árbol de widgets
  // para garantizar que sea la misma instancia del MultiBlocProvider global.
  sl.registerFactoryParam<EditProfileCubit, AuthCubit, void>(
    (authCubit, _) => EditProfileCubit(
      updateProfileUseCase: sl(),
      authCubit: authCubit,
    ),
  );
  sl.registerLazySingleton(() => UpdateProfileUseCase(sl()));
  // AuthRepository y AuthDataSource ya están registrados
}
```

`_registerEditProfile()` se llama desde `_registerFeatures()`.

---

## 9. Barrel

`lib/features/auth/auth.dart` exporta `EditProfileCubit`, `EditProfileState` y `EditProfilePage`.

---

## 10. Nuevos paquetes

`pubspec.yaml`:
```yaml
image_picker: ^1.1.2
geocoding: ^3.0.0
```

`ios/Runner/Info.plist` — permisos ya tiene location; añadir:
```xml
<key>NSCameraUsageDescription</key>
<string>Para cambiar tu foto de perfil</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>Para seleccionar tu foto de perfil</string>
```

---

## 11. Tests

- `test/features/auth/data/repositories/auth_repository_impl_updateprofile_test.dart`
  - `updateProfile` devuelve `Right(UserEntity)` cuando datasource tiene éxito
  - `updateProfile` devuelve `Left(ServerFailure)` cuando datasource lanza excepción
  - Llama datasource con los params correctos

- `test/features/auth/presentation/cubit/edit_profile_cubit_test.dart`
  - Estado inicial es `EditProfileIdle`
  - `save` emite `[EditProfileSaving, EditProfileSuccess]` en éxito
  - `EditProfileSuccess` contiene el `UserEntity` actualizado
  - `save` llama `authCubit.updateUser(user)` en éxito
  - `save` emite `[EditProfileSaving, EditProfileError]` en fallo
  - `authCubit.updateUser` NO se llama en fallo

---

## 12. Acceptance Criteria

1. `ProfilePage` muestra avatar (foto real si existe, inicial si no), nombre, email y dirección actual.
2. Tap ✏️ navega a `/perfil/editar` con los datos pre-llenados.
3. El usuario puede cambiar nombre y dirección con el formulario.
4. Tap 📷 abre bottom sheet con Cámara / Galería; la foto se previsualiza de inmediato.
5. Tap "Usar mi ubicación actual" rellena el campo dirección y guarda lat/lng.
6. Tap "Guardar" muestra spinner, luego SnackBar verde en éxito o rojo en error.
7. Tras guardar exitosamente, `ProfilePage` muestra los datos actualizados sin recargar.
8. Los cambios persisten tras cerrar y reabrir la app.
9. `flutter test` pasa sin errores nuevos.
10. `flutter analyze` sin errores nuevos.
