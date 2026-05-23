import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pinar_app/core/errors/failures.dart';
import 'package:pinar_app/core/usecases/usecase.dart';
import 'package:pinar_app/features/auth/domain/entities/user_entity.dart';
import 'package:pinar_app/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:pinar_app/features/auth/domain/usecases/login_usecase.dart';
import 'package:pinar_app/features/auth/domain/usecases/logout_usecase.dart';
import 'package:pinar_app/features/auth/domain/usecases/register_usecase.dart';
import 'package:pinar_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:pinar_app/features/auth/presentation/cubit/auth_state.dart';

class MockLoginUseCase extends Mock implements LoginUseCase {}

class MockRegisterUseCase extends Mock implements RegisterUseCase {}

class MockLogoutUseCase extends Mock implements LogoutUseCase {}

class MockGetCurrentUserUseCase extends Mock implements GetCurrentUserUseCase {}

void main() {
  late AuthCubit cubit;
  late MockLoginUseCase mockLogin;
  late MockRegisterUseCase mockRegister;
  late MockLogoutUseCase mockLogout;
  late MockGetCurrentUserUseCase mockGetCurrentUser;

  const tUser = UserEntity(id: 'uid-1', email: 'test@test.com');

  setUp(() {
    mockLogin = MockLoginUseCase();
    mockRegister = MockRegisterUseCase();
    mockLogout = MockLogoutUseCase();
    mockGetCurrentUser = MockGetCurrentUserUseCase();
    cubit = AuthCubit(
      loginUseCase: mockLogin,
      registerUseCase: mockRegister,
      logoutUseCase: mockLogout,
      getCurrentUserUseCase: mockGetCurrentUser,
    );
    registerFallbackValue(const LoginParams(email: '', password: ''));
    registerFallbackValue(const RegisterParams(email: '', password: ''));
    registerFallbackValue(const NoParams());
  });

  tearDown(() => cubit.close());

  test('estado inicial es AuthInitial', () {
    expect(cubit.state, const AuthInitial());
  });

  group('checkAuth', () {
    blocTest<AuthCubit, AuthState>(
      'emite [AuthLoading, AuthAuthenticated] cuando hay sesión activa',
      build: () {
        when(() => mockGetCurrentUser(any()))
            .thenAnswer((_) async => const Right(tUser));
        return cubit;
      },
      act: (c) => c.checkAuth(),
      expect: () => [const AuthLoading(), const AuthAuthenticated(tUser)],
    );

    blocTest<AuthCubit, AuthState>(
      'emite [AuthLoading, AuthUnauthenticated] cuando no hay sesión',
      build: () {
        when(() => mockGetCurrentUser(any()))
            .thenAnswer((_) async => const Right(null));
        return cubit;
      },
      act: (c) => c.checkAuth(),
      expect: () => [const AuthLoading(), const AuthUnauthenticated()],
    );
  });

  group('login', () {
    blocTest<AuthCubit, AuthState>(
      'emite [AuthLoading, AuthAuthenticated] con credenciales válidas',
      build: () {
        when(() => mockLogin(any()))
            .thenAnswer((_) async => const Right(tUser));
        return cubit;
      },
      act: (c) => c.login(email: 'test@test.com', password: 'pass123'),
      expect: () => [const AuthLoading(), const AuthAuthenticated(tUser)],
    );

    blocTest<AuthCubit, AuthState>(
      'emite [AuthLoading, AuthError] con credenciales inválidas',
      build: () {
        when(() => mockLogin(any())).thenAnswer(
            (_) async => const Left(AuthFailure('Credenciales inválidas')));
        return cubit;
      },
      act: (c) => c.login(email: 'x@x.com', password: 'wrong'),
      expect: () =>
          [const AuthLoading(), const AuthError('Credenciales inválidas')],
    );
  });

  group('register', () {
    blocTest<AuthCubit, AuthState>(
      'emite [AuthLoading, AuthAuthenticated] con datos válidos',
      build: () {
        when(() => mockRegister(any()))
            .thenAnswer((_) async => const Right(tUser));
        return cubit;
      },
      act: (c) => c.register(email: 'nuevo@test.com', password: 'pass123'),
      expect: () => [const AuthLoading(), const AuthAuthenticated(tUser)],
    );
  });

  group('logout', () {
    blocTest<AuthCubit, AuthState>(
      'emite [AuthLoading, AuthUnauthenticated] al cerrar sesión',
      build: () {
        when(() => mockLogout(any()))
            .thenAnswer((_) async => const Right(null));
        return cubit;
      },
      act: (c) => c.logout(),
      expect: () => [const AuthLoading(), const AuthUnauthenticated()],
    );
  });
}
