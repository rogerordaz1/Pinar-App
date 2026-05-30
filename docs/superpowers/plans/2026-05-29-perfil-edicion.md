# Editar Perfil — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Permitir al usuario editar su nombre, foto de perfil y dirección (con GPS lat/lng) desde una página dedicada `/perfil/editar`.

**Architecture:** Nueva `EditProfilePage` fuera del shell con su propio `EditProfileCubit` (sealed states, sin freezed). Al guardar con éxito, `EditProfileCubit` llama `authCubit.updateUser(user)` para propagar el nuevo estado sin roundtrip extra. Todo dentro de la feature `auth` existente.

**Tech Stack:** Flutter BLoC/Cubit · Supabase (users table + Storage bucket `avatars`) · `image_picker` · `geolocator` (ya instalado) · `geocoding` · `get_it` `registerFactoryParam` · `go_router` · `cached_network_image` (ya instalado)

---

## File Map

| Archivo | Acción |
|---|---|
| `supabase/migrations/20260529000002_users_profile_columns.sql` | Crear |
| `pubspec.yaml` | Modificar — agregar `image_picker`, `geocoding` |
| `ios/Runner/Info.plist` | Modificar — permisos cámara y galería |
| `lib/features/auth/domain/entities/user_entity.dart` | Modificar — `direccion`, `lat`, `lng` |
| `lib/features/auth/data/models/user_model.dart` | Modificar — `direccion`, `lat`, `lng` |
| `lib/features/auth/domain/usecases/update_profile_usecase.dart` | Crear |
| `lib/features/auth/domain/repositories/auth_repository.dart` | Modificar — `updateProfile` |
| `lib/features/auth/data/datasources/auth_datasource.dart` | Modificar — `updateProfile` |
| `lib/features/auth/data/datasources/supabase_auth_datasource.dart` | Modificar — implementación |
| `lib/features/auth/data/repositories/auth_repository_impl.dart` | Modificar — implementación |
| `lib/features/auth/presentation/cubit/auth_cubit.dart` | Modificar — `updateUser` |
| `lib/features/auth/presentation/cubit/edit_profile_state.dart` | Crear |
| `lib/features/auth/presentation/cubit/edit_profile_cubit.dart` | Crear |
| `lib/features/auth/presentation/pages/edit_profile_page.dart` | Crear |
| `lib/features/auth/presentation/widgets/profile_header.dart` | Modificar — avatar + botón editar |
| `lib/features/auth/presentation/pages/profile_page.dart` | Modificar — pasar avatarUrl/direccion |
| `lib/core/router/route_names.dart` | Modificar — `editarPerfil` |
| `lib/core/router/app_router.dart` | Modificar — ruta `/perfil/editar` |
| `lib/injection_container.dart` | Modificar — `_registerEditProfile` |
| `lib/features/auth/auth.dart` | Modificar — exportar nuevos símbolos |
| `test/features/auth/data/repositories/auth_repository_impl_update_profile_test.dart` | Crear |
| `test/features/auth/presentation/cubit/edit_profile_cubit_test.dart` | Crear |

---

## Task 1: SQL Migration

**Files:**
- Create: `supabase/migrations/20260529000002_users_profile_columns.sql`

- [ ] **Step 1: Crear el archivo de migración**

```sql
-- supabase/migrations/20260529000002_users_profile_columns.sql

alter table public.users
  add column if not exists direccion text,
  add column if not exists lat       double precision,
  add column if not exists lng       double precision;
```

- [ ] **Step 2: Ejecutar en Supabase Dashboard**

Abrir el SQL Editor en el Dashboard de Supabase y ejecutar el contenido del archivo. Verificar que la tabla `users` muestra las tres columnas nuevas.

- [ ] **Step 3: Commit**

```bash
git add supabase/migrations/20260529000002_users_profile_columns.sql
git commit -m "chore(db): add direccion, lat, lng columns to users table"
```

---

## Task 2: Agregar paquetes + permisos iOS

**Files:**
- Modify: `pubspec.yaml`
- Modify: `ios/Runner/Info.plist`

- [ ] **Step 1: Agregar dependencias en pubspec.yaml**

En la sección `dependencies`, después de `geolocator: ^13.0.1`, agregar:

```yaml
  image_picker: ^1.1.2
  geocoding: ^3.0.0
```

- [ ] **Step 2: Correr flutter pub get**

```bash
flutter pub get
```

Expected: Resuelve dependencias sin conflictos.

- [ ] **Step 3: Agregar permisos en ios/Runner/Info.plist**

Antes de la línea `<key>UIApplicationSceneManifest</key>`, agregar:

```xml
	<key>NSCameraUsageDescription</key>
	<string>Para cambiar tu foto de perfil</string>
	<key>NSPhotoLibraryUsageDescription</key>
	<string>Para seleccionar tu foto de perfil</string>
	<key>NSPhotoLibraryAddUsageDescription</key>
	<string>Para guardar tu foto de perfil</string>
```

- [ ] **Step 4: Commit**

```bash
git add pubspec.yaml pubspec.lock ios/Runner/Info.plist
git commit -m "chore: add image_picker, geocoding deps and iOS camera permissions"
```

---

## Task 3: Extender UserEntity y UserModel

**Files:**
- Modify: `lib/features/auth/domain/entities/user_entity.dart`
- Modify: `lib/features/auth/data/models/user_model.dart`

- [ ] **Step 1: Actualizar UserEntity**

Reemplazar el contenido completo de `lib/features/auth/domain/entities/user_entity.dart`:

```dart
import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String email;
  final String? nombre;
  final String? telefono;
  final String? avatarUrl;
  final bool esNegocio;
  final String? direccion;
  final double? lat;
  final double? lng;

  const UserEntity({
    required this.id,
    required this.email,
    this.nombre,
    this.telefono,
    this.avatarUrl,
    this.esNegocio = false,
    this.direccion,
    this.lat,
    this.lng,
  });

  UserEntity copyWith({
    String? id,
    String? email,
    String? nombre,
    String? telefono,
    String? avatarUrl,
    bool? esNegocio,
    String? direccion,
    double? lat,
    double? lng,
  }) {
    return UserEntity(
      id: id ?? this.id,
      email: email ?? this.email,
      nombre: nombre ?? this.nombre,
      telefono: telefono ?? this.telefono,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      esNegocio: esNegocio ?? this.esNegocio,
      direccion: direccion ?? this.direccion,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
    );
  }

  @override
  List<Object?> get props =>
      [id, email, nombre, telefono, avatarUrl, esNegocio, direccion, lat, lng];
}
```

- [ ] **Step 2: Actualizar UserModel**

Reemplazar el contenido completo de `lib/features/auth/data/models/user_model.dart`:

```dart
import '../../domain/entities/user_entity.dart';

class UserModel {
  final String id;
  final String email;
  final String? nombre;
  final String? telefono;
  final String? avatarUrl;
  final bool esNegocio;
  final String? direccion;
  final double? lat;
  final double? lng;

  const UserModel({
    required this.id,
    required this.email,
    this.nombre,
    this.telefono,
    this.avatarUrl,
    this.esNegocio = false,
    this.direccion,
    this.lat,
    this.lng,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as String,
      email: map['email'] as String,
      nombre: map['nombre'] as String?,
      telefono: map['telefono'] as String?,
      avatarUrl: map['avatar_url'] as String?,
      esNegocio: map['es_negocio'] as bool? ?? false,
      direccion: map['direccion'] as String?,
      lat: (map['lat'] as num?)?.toDouble(),
      lng: (map['lng'] as num?)?.toDouble(),
    );
  }

  UserEntity toEntity() {
    return UserEntity(
      id: id,
      email: email,
      nombre: nombre,
      telefono: telefono,
      avatarUrl: avatarUrl,
      esNegocio: esNegocio,
      direccion: direccion,
      lat: lat,
      lng: lng,
    );
  }
}
```

- [ ] **Step 3: Verificar que no hay errores de compilación**

```bash
flutter analyze lib/features/auth/domain/entities/
flutter analyze lib/features/auth/data/models/
```

Expected: No errors.

- [ ] **Step 4: Commit**

```bash
git add lib/features/auth/domain/entities/user_entity.dart \
        lib/features/auth/data/models/user_model.dart
git commit -m "feat(auth): add direccion, lat, lng fields to UserEntity and UserModel"
```

---

## Task 4: Domain — UpdateProfileUseCase + interfaces

**Files:**
- Create: `lib/features/auth/domain/usecases/update_profile_usecase.dart`
- Modify: `lib/features/auth/domain/repositories/auth_repository.dart`
- Modify: `lib/features/auth/data/datasources/auth_datasource.dart`

- [ ] **Step 1: Crear UpdateProfileUseCase**

Crear `lib/features/auth/domain/usecases/update_profile_usecase.dart`:

```dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class UpdateProfileParams extends Equatable {
  final String nombre;
  final String? direccion;
  final double? lat;
  final double? lng;
  final String? avatarLocalPath;

  const UpdateProfileParams({
    required this.nombre,
    this.direccion,
    this.lat,
    this.lng,
    this.avatarLocalPath,
  });

  @override
  List<Object?> get props => [nombre, direccion, lat, lng, avatarLocalPath];
}

class UpdateProfileUseCase extends UseCase<UserEntity, UpdateProfileParams> {
  final AuthRepository repository;

  UpdateProfileUseCase(this.repository);

  @override
  Future<Either<Failure, UserEntity>> call(UpdateProfileParams params) {
    return repository.updateProfile(params);
  }
}
```

- [ ] **Step 2: Agregar updateProfile a AuthRepository**

Al final de `lib/features/auth/domain/repositories/auth_repository.dart`, antes del `}` de cierre:

```dart
  Future<Either<Failure, UserEntity>> updateProfile(UpdateProfileParams params);
```

El import de `UpdateProfileParams` también se agrega arriba del archivo (después de los imports existentes):

```dart
import '../usecases/update_profile_usecase.dart';
```

El archivo completo queda:

```dart
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user_entity.dart';
import '../usecases/update_profile_usecase.dart';

abstract class AuthRepository {
  Future<Either<Failure, UserEntity>> login({
    required String email,
    required String password,
  });

  Future<Either<Failure, UserEntity>> register({
    required String email,
    required String password,
    String? fullName,
  });

  Future<Either<Failure, void>> logout();

  Future<Either<Failure, UserEntity?>> getCurrentUser();

  Future<Either<Failure, void>> loginWithGoogle();
  Future<Either<Failure, void>> forgotPassword({required String email});

  Future<Either<Failure, void>> verifyResetOtp({
    required String email,
    required String token,
  });

  Future<Either<Failure, void>> resetPassword({required String newPassword});

  Future<Either<Failure, UserEntity>> updateProfile(UpdateProfileParams params);
}
```

- [ ] **Step 3: Agregar updateProfile a AuthDataSource**

Al final de `lib/features/auth/data/datasources/auth_datasource.dart`, antes del `}` de cierre. El archivo completo:

```dart
import '../../domain/usecases/update_profile_usecase.dart';
import '../models/user_model.dart';

abstract class AuthDataSource {
  Future<UserModel> login({required String email, required String password});
  Future<UserModel> register({
    required String email,
    required String password,
    String? fullName,
  });
  Future<void> logout();
  Future<UserModel?> getCurrentUser();
  Future<void> loginWithGoogle();
  Future<void> forgotPassword({required String email});
  Future<void> verifyResetOtp({required String email, required String token});
  Future<void> resetPassword({required String newPassword});
  Future<UserModel> updateProfile(UpdateProfileParams params);
}
```

- [ ] **Step 4: Commit**

```bash
git add lib/features/auth/domain/usecases/update_profile_usecase.dart \
        lib/features/auth/domain/repositories/auth_repository.dart \
        lib/features/auth/data/datasources/auth_datasource.dart
git commit -m "feat(auth): add UpdateProfileUseCase and updateProfile to interfaces"
```

---

## Task 5: Data layer — implementación + tests (TDD)

**Files:**
- Create: `test/features/auth/data/repositories/auth_repository_impl_update_profile_test.dart`
- Modify: `lib/features/auth/data/datasources/supabase_auth_datasource.dart`
- Modify: `lib/features/auth/data/repositories/auth_repository_impl.dart`

- [ ] **Step 1: Escribir los tests primero**

Crear `test/features/auth/data/repositories/auth_repository_impl_update_profile_test.dart`:

```dart
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cubamap/core/errors/exceptions.dart';
import 'package:cubamap/core/errors/failures.dart';
import 'package:cubamap/features/auth/data/datasources/auth_datasource.dart';
import 'package:cubamap/features/auth/data/models/user_model.dart';
import 'package:cubamap/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:cubamap/features/auth/domain/usecases/update_profile_usecase.dart';

class MockAuthDataSource extends Mock implements AuthDataSource {}

void main() {
  late AuthRepositoryImpl repository;
  late MockAuthDataSource mockDataSource;

  setUpAll(() {
    registerFallbackValue(const UpdateProfileParams(nombre: ''));
  });

  setUp(() {
    mockDataSource = MockAuthDataSource();
    repository = AuthRepositoryImpl(mockDataSource);
  });

  const tParams = UpdateProfileParams(
    nombre: 'Roger',
    direccion: 'Calle 10, Pinar del Río',
    lat: 22.4167,
    lng: -83.6833,
  );

  final tUserModel = UserModel(
    id: 'user-id',
    email: 'roger@test.com',
    nombre: 'Roger',
    direccion: 'Calle 10, Pinar del Río',
    lat: 22.4167,
    lng: -83.6833,
  );

  group('updateProfile', () {
    test('devuelve Right(UserEntity) cuando el datasource tiene éxito',
        () async {
      when(() => mockDataSource.updateProfile(tParams))
          .thenAnswer((_) async => tUserModel);

      final result = await repository.updateProfile(tParams);

      expect(result, Right(tUserModel.toEntity()));
    });

    test('llama al datasource con los params correctos', () async {
      when(() => mockDataSource.updateProfile(tParams))
          .thenAnswer((_) async => tUserModel);

      await repository.updateProfile(tParams);

      verify(() => mockDataSource.updateProfile(tParams)).called(1);
    });

    test('devuelve Left(ServerFailure) cuando datasource lanza ServerException',
        () async {
      when(() => mockDataSource.updateProfile(any()))
          .thenThrow(const ServerException('Error de servidor'));

      final result = await repository.updateProfile(tParams);

      expect(result, const Left(ServerFailure('Error de servidor')));
    });

    test('devuelve Left(ServerFailure) cuando datasource lanza Exception genérica',
        () async {
      when(() => mockDataSource.updateProfile(any()))
          .thenThrow(Exception('Error desconocido'));

      final result = await repository.updateProfile(tParams);

      expect(result.isLeft(), true);
    });
  });
}
```

- [ ] **Step 2: Correr los tests — verificar que fallan**

```bash
flutter test test/features/auth/data/repositories/auth_repository_impl_update_profile_test.dart
```

Expected: FAIL — `The method 'updateProfile' is not defined`.

- [ ] **Step 3: Implementar updateProfile en AuthRepositoryImpl**

Al final de `lib/features/auth/data/repositories/auth_repository_impl.dart`, antes del `}` de cierre:

```dart
  @override
  Future<Either<Failure, UserEntity>> updateProfile(
      UpdateProfileParams params) async {
    try {
      final model = await dataSource.updateProfile(params);
      return Right(model.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
```

Agregar el import al inicio del archivo:
```dart
import '../../domain/usecases/update_profile_usecase.dart';
```

- [ ] **Step 4: Implementar updateProfile en SupabaseAuthDataSource**

Agregar los imports necesarios al inicio de `lib/features/auth/data/datasources/supabase_auth_datasource.dart`:

```dart
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/errors/exceptions.dart' as app;
import '../../domain/usecases/update_profile_usecase.dart';
import '../models/user_model.dart';
import 'auth_datasource.dart';
```

Agregar el método al final de la clase `SupabaseAuthDataSource`, antes del `}` de cierre:

```dart
  @override
  Future<UserModel> updateProfile(UpdateProfileParams params) async {
    try {
      final userId = client.auth.currentUser!.id;

      String? newAvatarUrl;
      if (params.avatarLocalPath != null) {
        final file = File(params.avatarLocalPath!);
        await client.storage.from('avatars').upload(
              '$userId/avatar.jpg',
              file,
              fileOptions: const FileOptions(upsert: true),
            );
        newAvatarUrl =
            client.storage.from('avatars').getPublicUrl('$userId/avatar.jpg');
      }

      final updates = <String, dynamic>{
        'nombre': params.nombre,
        if (params.direccion != null) 'direccion': params.direccion,
        if (params.lat != null) 'lat': params.lat,
        if (params.lng != null) 'lng': params.lng,
        if (newAvatarUrl != null) 'avatar_url': newAvatarUrl,
      };

      final data = await client
          .from('users')
          .update(updates)
          .eq('id', userId)
          .select()
          .single();

      // Sync auth metadata (best-effort)
      try {
        await client.auth.updateUser(
          UserAttributes(data: {'nombre': params.nombre}),
        );
      } catch (_) {}

      return UserModel.fromMap(data);
    } catch (e) {
      throw app.ServerException(_extractMessage(e));
    }
  }
```

- [ ] **Step 5: Correr los tests — verificar que pasan**

```bash
flutter test test/features/auth/data/repositories/auth_repository_impl_update_profile_test.dart
```

Expected: `+4: All tests passed!`

- [ ] **Step 6: Commit**

```bash
git add lib/features/auth/data/datasources/supabase_auth_datasource.dart \
        lib/features/auth/data/repositories/auth_repository_impl.dart \
        test/features/auth/data/repositories/auth_repository_impl_update_profile_test.dart
git commit -m "feat(auth): implement updateProfile in datasource and repository"
```

---

## Task 6: AuthCubit — agregar updateUser

**Files:**
- Modify: `lib/features/auth/presentation/cubit/auth_cubit.dart`

- [ ] **Step 1: Agregar el método updateUser**

Al final de la clase `AuthCubit`, antes de `@override Future<void> close()`:

```dart
  void updateUser(UserEntity user) {
    if (state is AuthAuthenticated) {
      emit(AuthAuthenticated(user: user));
    }
  }
```

- [ ] **Step 2: Verificar que compila**

```bash
flutter analyze lib/features/auth/presentation/cubit/auth_cubit.dart
```

Expected: No errors.

- [ ] **Step 3: Commit**

```bash
git add lib/features/auth/presentation/cubit/auth_cubit.dart
git commit -m "feat(auth): add updateUser method to AuthCubit"
```

---

## Task 7: EditProfileState + EditProfileCubit + tests (TDD)

**Files:**
- Create: `lib/features/auth/presentation/cubit/edit_profile_state.dart`
- Create: `lib/features/auth/presentation/cubit/edit_profile_cubit.dart`
- Create: `test/features/auth/presentation/cubit/edit_profile_cubit_test.dart`

- [ ] **Step 1: Crear EditProfileState**

Crear `lib/features/auth/presentation/cubit/edit_profile_state.dart`:

```dart
import '../../domain/entities/user_entity.dart';

sealed class EditProfileState {
  const EditProfileState();
}

final class EditProfileIdle extends EditProfileState {
  const EditProfileIdle();
}

final class EditProfileSaving extends EditProfileState {
  const EditProfileSaving();
}

final class EditProfileSuccess extends EditProfileState {
  final UserEntity user;
  const EditProfileSuccess(this.user);
}

final class EditProfileError extends EditProfileState {
  final String message;
  const EditProfileError(this.message);
}
```

- [ ] **Step 2: Escribir los tests del cubit primero**

Crear `test/features/auth/presentation/cubit/edit_profile_cubit_test.dart`:

```dart
import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cubamap/core/errors/failures.dart';
import 'package:cubamap/features/auth/domain/entities/user_entity.dart';
import 'package:cubamap/features/auth/domain/usecases/update_profile_usecase.dart';
import 'package:cubamap/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:cubamap/features/auth/presentation/cubit/edit_profile_cubit.dart';
import 'package:cubamap/features/auth/presentation/cubit/edit_profile_state.dart';

class MockUpdateProfileUseCase extends Mock implements UpdateProfileUseCase {}

class MockAuthCubit extends Mock implements AuthCubit {}

void main() {
  late EditProfileCubit cubit;
  late MockUpdateProfileUseCase mockUseCase;
  late MockAuthCubit mockAuthCubit;

  setUpAll(() {
    registerFallbackValue(const UpdateProfileParams(nombre: ''));
    registerFallbackValue(
      const UserEntity(id: 'id', email: 'e@e.com'),
    );
  });

  setUp(() {
    mockUseCase = MockUpdateProfileUseCase();
    mockAuthCubit = MockAuthCubit();
    cubit = EditProfileCubit(
      updateProfileUseCase: mockUseCase,
      authCubit: mockAuthCubit,
    );
  });

  tearDown(() => cubit.close());

  const tUser = UserEntity(id: 'uid', email: 'roger@test.com', nombre: 'Roger');

  test('estado inicial es EditProfileIdle', () {
    expect(cubit.state, const EditProfileIdle());
  });

  blocTest<EditProfileCubit, EditProfileState>(
    'save emite [EditProfileSaving, EditProfileSuccess] en éxito',
    build: () {
      when(() => mockUseCase(any())).thenAnswer((_) async => const Right(tUser));
      when(() => mockAuthCubit.updateUser(any())).thenReturn(null);
      return cubit;
    },
    act: (c) => c.save(nombre: 'Roger'),
    expect: () => [const EditProfileSaving(), const EditProfileSuccess(tUser)],
  );

  blocTest<EditProfileCubit, EditProfileState>(
    'save llama authCubit.updateUser con el UserEntity actualizado',
    build: () {
      when(() => mockUseCase(any())).thenAnswer((_) async => const Right(tUser));
      when(() => mockAuthCubit.updateUser(any())).thenReturn(null);
      return cubit;
    },
    act: (c) => c.save(nombre: 'Roger'),
    verify: (_) => verify(() => mockAuthCubit.updateUser(tUser)).called(1),
  );

  blocTest<EditProfileCubit, EditProfileState>(
    'save emite [EditProfileSaving, EditProfileError] en fallo',
    build: () {
      when(() => mockUseCase(any()))
          .thenAnswer((_) async => const Left(ServerFailure('Error de red')));
      return cubit;
    },
    act: (c) => c.save(nombre: 'Roger'),
    expect: () => [
      const EditProfileSaving(),
      const EditProfileError('Error de red'),
    ],
  );

  blocTest<EditProfileCubit, EditProfileState>(
    'save NO llama authCubit.updateUser en fallo',
    build: () {
      when(() => mockUseCase(any()))
          .thenAnswer((_) async => const Left(ServerFailure('Error')));
      return cubit;
    },
    act: (c) => c.save(nombre: 'Roger'),
    verify: (_) => verifyNever(() => mockAuthCubit.updateUser(any())),
  );

  blocTest<EditProfileCubit, EditProfileState>(
    'save incluye lat, lng y avatarLocalPath en los params al use case',
    build: () {
      when(() => mockUseCase(any())).thenAnswer((_) async => const Right(tUser));
      when(() => mockAuthCubit.updateUser(any())).thenReturn(null);
      return cubit;
    },
    act: (c) => c.save(
      nombre: 'Roger',
      direccion: 'Calle 10',
      lat: 22.4167,
      lng: -83.6833,
      avatarLocalPath: '/tmp/avatar.jpg',
    ),
    verify: (_) => verify(
      () => mockUseCase(const UpdateProfileParams(
        nombre: 'Roger',
        direccion: 'Calle 10',
        lat: 22.4167,
        lng: -83.6833,
        avatarLocalPath: '/tmp/avatar.jpg',
      )),
    ).called(1),
  );
}
```

- [ ] **Step 3: Correr los tests — verificar que fallan**

```bash
flutter test test/features/auth/presentation/cubit/edit_profile_cubit_test.dart
```

Expected: FAIL — `Target of URI doesn't exist: edit_profile_cubit.dart`.

- [ ] **Step 4: Crear EditProfileCubit**

Crear `lib/features/auth/presentation/cubit/edit_profile_cubit.dart`:

```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/update_profile_usecase.dart';
import 'auth_cubit.dart';
import 'edit_profile_state.dart';

class EditProfileCubit extends Cubit<EditProfileState> {
  final UpdateProfileUseCase updateProfileUseCase;
  final AuthCubit authCubit;

  EditProfileCubit({
    required this.updateProfileUseCase,
    required this.authCubit,
  }) : super(const EditProfileIdle());

  Future<void> save({
    required String nombre,
    String? direccion,
    double? lat,
    double? lng,
    String? avatarLocalPath,
  }) async {
    emit(const EditProfileSaving());
    final result = await updateProfileUseCase(
      UpdateProfileParams(
        nombre: nombre,
        direccion: direccion,
        lat: lat,
        lng: lng,
        avatarLocalPath: avatarLocalPath,
      ),
    );
    result.fold(
      (failure) => emit(EditProfileError(failure.message)),
      (user) {
        authCubit.updateUser(user);
        emit(EditProfileSuccess(user));
      },
    );
  }
}
```

- [ ] **Step 5: Correr los tests — verificar que pasan**

```bash
flutter test test/features/auth/presentation/cubit/edit_profile_cubit_test.dart
```

Expected: `+5: All tests passed!`

- [ ] **Step 6: Commit**

```bash
git add lib/features/auth/presentation/cubit/edit_profile_state.dart \
        lib/features/auth/presentation/cubit/edit_profile_cubit.dart \
        test/features/auth/presentation/cubit/edit_profile_cubit_test.dart
git commit -m "feat(auth): add EditProfileCubit with sealed states and tests"
```

---

## Task 8: EditProfilePage

**Files:**
- Create: `lib/features/auth/presentation/pages/edit_profile_page.dart`

- [ ] **Step 1: Crear EditProfilePage**

Crear `lib/features/auth/presentation/pages/edit_profile_page.dart`:

```dart
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/core.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';
import '../cubit/edit_profile_cubit.dart';
import '../cubit/edit_profile_state.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late final TextEditingController _nombreController;
  late final TextEditingController _direccionController;
  double? _lat;
  double? _lng;
  File? _avatarFile;
  bool _loadingLocation = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthCubit>().state.maybeMap(
          authenticated: (s) => s.user,
          orElse: () => null,
        );
    _nombreController = TextEditingController(text: user?.nombre ?? '');
    _direccionController = TextEditingController(text: user?.direccion ?? '');
    _lat = user?.lat;
    _lng = user?.lng;
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _direccionController.dispose();
    super.dispose();
  }

  Future<void> _useCurrentLocation() async {
    setState(() => _loadingLocation = true);
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Permiso de ubicación denegado')),
          );
        }
        return;
      }
      final position = await Geolocator.getCurrentPosition();
      if (!mounted) return;
      setState(() {
        _lat = position.latitude;
        _lng = position.longitude;
      });
      // Reverse geocoding (best-effort)
      try {
        final placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );
        if (placemarks.isNotEmpty && mounted) {
          final p = placemarks.first;
          final parts = [p.street, p.locality, p.administrativeArea]
              .where((s) => s != null && s!.isNotEmpty)
              .map((s) => s!)
              .toList();
          if (parts.isNotEmpty) {
            _direccionController.text = parts.join(', ');
          }
        }
      } catch (_) {
        // Geocoding falló — lat/lng se guardaron, campo de texto sin cambios
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al obtener ubicación: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loadingLocation = false);
    }
  }

  Future<void> _showAvatarPicker() async {
    final picker = ImagePicker();
    await showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Cámara'),
              onTap: () async {
                Navigator.of(ctx).pop();
                final picked = await picker.pickImage(
                  source: ImageSource.camera,
                  imageQuality: 70,
                );
                if (picked != null && mounted) {
                  setState(() => _avatarFile = File(picked.path));
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Galería'),
              onTap: () async {
                Navigator.of(ctx).pop();
                final picked = await picker.pickImage(
                  source: ImageSource.gallery,
                  imageQuality: 70,
                );
                if (picked != null && mounted) {
                  setState(() => _avatarFile = File(picked.path));
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _save() {
    final nombre = _nombreController.text.trim();
    if (nombre.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El nombre no puede estar vacío')),
      );
      return;
    }
    final direccion = _direccionController.text.trim();
    context.read<EditProfileCubit>().save(
          nombre: nombre,
          direccion: direccion.isEmpty ? null : direccion,
          lat: _lat,
          lng: _lng,
          avatarLocalPath: _avatarFile?.path,
        );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = context.read<AuthCubit>().state.maybeMap(
          authenticated: (s) => s.user,
          orElse: () => null,
        );

    return BlocListener<EditProfileCubit, EditProfileState>(
      listener: (context, state) {
        if (state is EditProfileSuccess) {
          context.pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Perfil actualizado correctamente'),
              backgroundColor: AppColors.primary,
            ),
          );
        } else if (state is EditProfileError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      child: BlocBuilder<EditProfileCubit, EditProfileState>(
        builder: (context, state) {
          final isSaving = state is EditProfileSaving;
          return Scaffold(
            appBar: AppBar(
              backgroundColor: AppColors.surfaceContainerLowest,
              elevation: 0,
              scrolledUnderElevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: AppColors.primary),
                onPressed: isSaving ? null : () => context.pop(),
              ),
              title: const Text(
                'Editar Perfil',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
            ),
            body: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              children: [
                // Avatar
                Center(
                  child: GestureDetector(
                    onTap: isSaving ? null : _showAvatarPicker,
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 44,
                          backgroundColor: AppColors.primary,
                          backgroundImage: _avatarFile != null
                              ? FileImage(_avatarFile!)
                              : (currentUser?.avatarUrl != null
                                  ? CachedNetworkImageProvider(
                                      currentUser!.avatarUrl!)
                                  : null) as ImageProvider?,
                          child: (_avatarFile == null &&
                                  currentUser?.avatarUrl == null)
                              ? Text(
                                  (currentUser?.nombre?.isNotEmpty == true
                                          ? currentUser!.nombre![0]
                                          : 'U')
                                      .toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                )
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: AppColors.surfaceContainerLowest,
                                  width: 2),
                            ),
                            child: const Icon(Icons.camera_alt,
                                size: 14, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: TextButton(
                    onPressed: isSaving ? null : _showAvatarPicker,
                    child: const Text('Cambiar foto'),
                  ),
                ),
                const SizedBox(height: 20),
                // Formulario
                Material(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Nombre
                        Text('Nombre',
                            style: Theme.of(context)
                                .textTheme
                                .labelMedium
                                ?.copyWith(
                                    color: AppColors.onSurfaceVariant,
                                    fontWeight: FontWeight.w600)),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _nombreController,
                          enabled: !isSaving,
                          textCapitalization: TextCapitalization.words,
                          decoration: InputDecoration(
                            hintText: 'Tu nombre',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10)),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 12),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Email (read-only)
                        Text('Email',
                            style: Theme.of(context)
                                .textTheme
                                .labelMedium
                                ?.copyWith(
                                    color: AppColors.onSurfaceVariant,
                                    fontWeight: FontWeight.w600)),
                        const SizedBox(height: 6),
                        TextField(
                          controller: TextEditingController(
                              text: currentUser?.email ?? ''),
                          enabled: false,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10)),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 12),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Dirección
                        Text('Dirección',
                            style: Theme.of(context)
                                .textTheme
                                .labelMedium
                                ?.copyWith(
                                    color: AppColors.onSurfaceVariant,
                                    fontWeight: FontWeight.w600)),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _direccionController,
                          enabled: !isSaving,
                          decoration: InputDecoration(
                            hintText: 'Ej: Calle Martí #12, Pinar del Río',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10)),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 12),
                          ),
                        ),
                        const SizedBox(height: 10),
                        // Botón GPS
                        OutlinedButton.icon(
                          onPressed:
                              (isSaving || _loadingLocation) ? null : _useCurrentLocation,
                          icon: _loadingLocation
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2),
                                )
                              : const Icon(Icons.my_location_outlined,
                                  size: 18),
                          label: Text(_loadingLocation
                              ? 'Detectando...'
                              : 'Usar mi ubicación actual'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            side:
                                const BorderSide(color: AppColors.primary),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            minimumSize: const Size(double.infinity, 44),
                          ),
                        ),
                        if (_lat != null && _lng != null) ...[
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(Icons.check_circle_outline,
                                  size: 14, color: AppColors.primary),
                              const SizedBox(width: 4),
                              Text(
                                'Ubicación guardada',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(color: AppColors.primary),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Botón guardar
                ElevatedButton(
                  onPressed: isSaving ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Guardar cambios',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
```

- [ ] **Step 2: Verificar que compila**

```bash
flutter analyze lib/features/auth/presentation/pages/edit_profile_page.dart
```

Expected: Solo info-level hints, sin errores.

- [ ] **Step 3: Commit**

```bash
git add lib/features/auth/presentation/pages/edit_profile_page.dart
git commit -m "feat(auth): add EditProfilePage with avatar picker and GPS location"
```

---

## Task 9: Actualizar ProfileHeader y ProfilePage

**Files:**
- Modify: `lib/features/auth/presentation/widgets/profile_header.dart`
- Modify: `lib/features/auth/presentation/pages/profile_page.dart`

- [ ] **Step 1: Actualizar ProfileHeader**

Reemplazar el contenido completo de `lib/features/auth/presentation/widgets/profile_header.dart`:

```dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../../core/core.dart';

class ProfileHeader extends StatelessWidget {
  final String inicial;
  final String nombre;
  final String email;
  final String? avatarUrl;
  final String? direccion;
  final VoidCallback? onEditTap;

  const ProfileHeader({
    super.key,
    required this.inicial,
    required this.nombre,
    required this.email,
    this.avatarUrl,
    this.direccion,
    this.onEditTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            CircleAvatar(
              radius: 36,
              backgroundColor: AppColors.primary,
              backgroundImage: avatarUrl != null
                  ? CachedNetworkImageProvider(avatarUrl!)
                  : null,
              child: avatarUrl == null
                  ? Text(
                      inicial,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nombre,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.onSurface,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    email,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (direccion != null && direccion!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined,
                            size: 12, color: AppColors.onSurfaceVariant),
                        const SizedBox(width: 2),
                        Expanded(
                          child: Text(
                            direccion!,
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppColors.onSurfaceVariant,
                                    ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            if (onEditTap != null)
              IconButton(
                icon: const Icon(Icons.edit_outlined,
                    color: AppColors.primary, size: 20),
                tooltip: 'Editar perfil',
                onPressed: onEditTap,
              ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Actualizar ProfilePage**

Reemplazar el contenido completo de `lib/features/auth/presentation/pages/profile_page.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/core.dart';
import '../../auth.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthCubit>().state.maybeMap(
          authenticated: (s) => s.user,
          orElse: () => null,
        );
    final nombre = user?.nombre ?? user?.email.split('@').first ?? 'Usuario';
    final email = user?.email ?? '';
    final inicial = nombre.isNotEmpty ? nombre[0].toUpperCase() : 'U';

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      children: [
        ProfileHeader(
          inicial: inicial,
          nombre: nombre,
          email: email,
          avatarUrl: user?.avatarUrl,
          direccion: user?.direccion,
          onEditTap: () => context.push(RouteNames.editarPerfil),
        ),
        const SizedBox(height: 24),
        ProfileSectionCard(
          title: 'Mi Actividad',
          items: [
            ProfileTile(
              icon: Icons.favorite_outline,
              label: 'Mis Favoritos',
              onTap: () => context.go(RouteNames.favoritos),
            ),
            ProfileTile(
              icon: Icons.bookmark_outline,
              label: 'Productos Guardados',
              onTap: () => context.go(RouteNames.favoritos, extra: 1),
            ),
            ProfileTile(
              icon: Icons.history,
              label: 'Historial de Búsqueda',
              onTap: null,
              showDivider: false,
            ),
          ],
        ),
        const SizedBox(height: 16),
        ProfileSectionCard(
          title: 'Preferencias',
          items: [
            ProfileTile(
              icon: Icons.settings_outlined,
              label: 'Configuración',
              onTap: null,
            ),
            ProfileTile(
              icon: Icons.notifications_outlined,
              label: 'Configurar Notificaciones',
              onTap: null,
              showDivider: false,
            ),
          ],
        ),
        const SizedBox(height: 16),
        ProfileSectionCard(
          items: [
            ProfileTile(
              icon: Icons.logout,
              label: 'Cerrar Sesión',
              iconColor: AppColors.error,
              labelColor: AppColors.error,
              showChevron: false,
              showDivider: false,
              onTap: () => context.read<AuthCubit>().logout(),
            ),
          ],
        ),
        const SizedBox(height: 32),
        Center(
          child: Text(
            'Pinar Cerca v1.0.0',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
```

- [ ] **Step 3: Verificar que compila**

```bash
flutter analyze lib/features/auth/presentation/
```

Expected: Solo info-level hints, sin errores.

- [ ] **Step 4: Commit**

```bash
git add lib/features/auth/presentation/widgets/profile_header.dart \
        lib/features/auth/presentation/pages/profile_page.dart
git commit -m "feat(auth): update ProfileHeader with avatar/direccion and edit button"
```

---

## Task 10: Wiring — RouteNames + Router + DI + Barrel

**Files:**
- Modify: `lib/core/router/route_names.dart`
- Modify: `lib/core/router/app_router.dart`
- Modify: `lib/injection_container.dart`
- Modify: `lib/features/auth/auth.dart`

- [ ] **Step 1: Agregar RouteNames.editarPerfil**

En `lib/core/router/route_names.dart`, después de `static const String perfil = '/perfil';`:

```dart
  static const String editarPerfil = '/perfil/editar';
```

- [ ] **Step 2: Agregar la ruta en app_router.dart**

En `lib/core/router/app_router.dart`, agregar el import:
```dart
import '../../features/auth/presentation/cubit/edit_profile_cubit.dart';
```

Agregar la ruta después del bloque de `GoRoute` para `/negocio/:id` y antes del `StatefulShellRoute`:

```dart
      // ── Edit Profile (sin bottom nav) ────────────────────────────────────
      GoRoute(
        path: RouteNames.editarPerfil,
        builder: (context, _) => BlocProvider(
          create: (_) => di.sl<EditProfileCubit>(
            param1: context.read<AuthCubit>(),
          ),
          child: const EditProfilePage(),
        ),
      ),
```

Agregar también estos imports donde están los demás imports de features auth:
```dart
import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../features/auth/presentation/pages/edit_profile_page.dart';
```

- [ ] **Step 3: Registrar en injection_container.dart**

Agregar los imports necesarios al inicio de `lib/injection_container.dart` (junto a los demás imports de auth):
```dart
import 'features/auth/domain/usecases/update_profile_usecase.dart';
import 'features/auth/presentation/cubit/edit_profile_cubit.dart';
```

Agregar la llamada en `_registerFeatures()`, después de `await _registerAuth();`:
```dart
  _registerEditProfile();
```

Agregar la función al final del archivo:
```dart
void _registerEditProfile() {
  sl.registerFactoryParam<EditProfileCubit, AuthCubit, void>(
    (authCubit, _) => EditProfileCubit(
      updateProfileUseCase: sl(),
      authCubit: authCubit,
    ),
  );
  sl.registerLazySingleton(() => UpdateProfileUseCase(sl()));
  // AuthRepository y AuthDataSource ya están registrados en _registerAuth
}
```

- [ ] **Step 4: Actualizar barrel auth.dart**

Reemplazar el contenido de `lib/features/auth/auth.dart`:

```dart
export 'domain/entities/user_entity.dart';
export 'presentation/cubit/auth_cubit.dart';
export 'presentation/cubit/auth_state.dart';
export 'presentation/cubit/edit_profile_cubit.dart';
export 'presentation/cubit/edit_profile_state.dart';
export 'presentation/pages/edit_profile_page.dart';
export 'presentation/widgets/otp_box.dart';
export 'presentation/widgets/password_strength_indicator.dart';
export 'presentation/widgets/profile_header.dart';
export 'presentation/widgets/profile_section_card.dart';
```

- [ ] **Step 5: Verificar que compila**

```bash
flutter analyze lib/
```

Expected: Solo info-level hints, sin errores nuevos.

- [ ] **Step 6: Commit**

```bash
git add lib/core/router/route_names.dart \
        lib/core/router/app_router.dart \
        lib/injection_container.dart \
        lib/features/auth/auth.dart
git commit -m "feat(auth): wire EditProfilePage — routes, DI, barrel"
```

---

## Task 11: Verificación final

- [ ] **Step 1: Correr todos los tests**

```bash
flutter test
```

Expected: Todos los tests pasan (120+ existentes + ~9 nuevos).

- [ ] **Step 2: Correr flutter analyze**

```bash
flutter analyze
```

Expected: Sin errores nuevos (solo info-level hints preexistentes).

- [ ] **Step 3: Checklist de smoke test manual**

Antes de probar, ejecutar la migración SQL en Supabase Dashboard si no se hizo en Task 1.

| Paso | Qué verificar |
|------|--------------|
| 1 | ProfilePage muestra el ícono ✏️ en el header |
| 2 | Tap ✏️ → navega a `/perfil/editar` con nombre pre-llenado |
| 3 | Cambiar nombre → Guardar → SnackBar verde, ProfilePage muestra el nuevo nombre |
| 4 | Tap "Usar mi ubicación" → pide permiso → rellena campo dirección → "Ubicación guardada" aparece |
| 5 | Tap 📷 → bottom sheet con Cámara/Galería → seleccionar imagen → previsualiza en avatar |
| 6 | Guardar con foto → ProfilePage muestra la nueva foto |
| 7 | Cerrar y reabrir la app → datos persisten |
| 8 | Forzar error de red → SnackBar rojo con mensaje |
