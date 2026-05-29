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
    registerFallbackValue(const UserEntity(id: 'id', email: 'e@e.com'));
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
    'save pasa lat, lng y avatarLocalPath al use case',
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
