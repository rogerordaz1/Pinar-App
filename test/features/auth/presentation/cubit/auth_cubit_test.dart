import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cubamap/core/errors/failures.dart';
import 'package:cubamap/core/usecases/usecase.dart';
import 'package:cubamap/core/utils/credential_storage.dart';
import 'package:cubamap/core/utils/onboarding_service.dart';
import 'package:cubamap/features/auth/domain/entities/user_entity.dart';
import 'package:cubamap/features/auth/domain/repositories/auth_repository.dart';
import 'package:cubamap/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:cubamap/features/auth/domain/usecases/login_usecase.dart';
import 'package:cubamap/features/auth/domain/usecases/logout_usecase.dart';
import 'package:cubamap/features/auth/domain/usecases/register_usecase.dart';
import 'package:cubamap/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:cubamap/features/auth/presentation/cubit/auth_state.dart';

class MockLoginUseCase extends Mock implements LoginUseCase {}

class MockRegisterUseCase extends Mock implements RegisterUseCase {}

class MockLogoutUseCase extends Mock implements LogoutUseCase {}

class MockGetCurrentUserUseCase extends Mock implements GetCurrentUserUseCase {}

class MockAuthRepository extends Mock implements AuthRepository {}

class MockCredentialStorage extends Mock implements CredentialStorage {}

class MockOnboardingService extends Mock implements OnboardingService {}

void main() {
  late AuthCubit cubit;
  late MockLoginUseCase mockLogin;
  late MockRegisterUseCase mockRegister;
  late MockLogoutUseCase mockLogout;
  late MockGetCurrentUserUseCase mockGetCurrentUser;
  late MockAuthRepository mockAuthRepository;
  late MockCredentialStorage mockCredentialStorage;
  late MockOnboardingService mockOnboardingService;

  const tUser = UserEntity(id: 'uid-1', email: 'test@test.com');

  setUp(() {
    mockLogin = MockLoginUseCase();
    mockRegister = MockRegisterUseCase();
    mockLogout = MockLogoutUseCase();
    mockGetCurrentUser = MockGetCurrentUserUseCase();
    mockAuthRepository = MockAuthRepository();
    mockCredentialStorage = MockCredentialStorage();
    mockOnboardingService = MockOnboardingService();
    when(() => mockCredentialStorage.save(email: any(named: 'email'), password: any(named: 'password')))
        .thenAnswer((_) async {});
    cubit = AuthCubit(
      loginUseCase: mockLogin,
      registerUseCase: mockRegister,
      logoutUseCase: mockLogout,
      getCurrentUserUseCase: mockGetCurrentUser,
      authRepository: mockAuthRepository,
      credentialStorage: mockCredentialStorage,
      onboardingService: mockOnboardingService,
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
      expect: () => [const AuthLoading(), const AuthAuthenticated(user: tUser)],
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
      expect: () => [const AuthLoading(), const AuthAuthenticated(user: tUser)],
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
          [const AuthLoading(), const AuthError(message: 'Credenciales inválidas')],
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
      expect: () => [const AuthLoading(), const AuthAuthenticated(user: tUser)],
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

  group('forgotPassword', () {
    blocTest<AuthCubit, AuthState>(
      'emite [AuthLoading, AuthPasswordResetEmailSent] cuando el email existe',
      build: () {
        when(() => mockAuthRepository.forgotPassword(
              email: any(named: 'email'),
            )).thenAnswer((_) async => const Right(null));
        return cubit;
      },
      act: (c) => c.forgotPassword(email: 'test@test.com'),
      expect: () =>
          [const AuthLoading(), const AuthPasswordResetEmailSent()],
    );

    blocTest<AuthCubit, AuthState>(
      'emite [AuthLoading, AuthError] cuando el correo no está registrado',
      build: () {
        when(() => mockAuthRepository.forgotPassword(
              email: any(named: 'email'),
            )).thenAnswer(
                (_) async => const Left(AuthFailure('Correo no encontrado')));
        return cubit;
      },
      act: (c) => c.forgotPassword(email: 'noexiste@test.com'),
      expect: () =>
          [const AuthLoading(), const AuthError(message: 'Correo no encontrado')],
    );
  });

  group('verifyResetOtp', () {
    blocTest<AuthCubit, AuthState>(
      'emite [AuthLoading, AuthOtpVerified] cuando el código es correcto',
      build: () {
        when(() => mockAuthRepository.verifyResetOtp(
              email: any(named: 'email'),
              token: any(named: 'token'),
            )).thenAnswer((_) async => const Right(null));
        return cubit;
      },
      act: (c) =>
          c.verifyResetOtp(email: 'test@test.com', token: '123456'),
      expect: () => [const AuthLoading(), const AuthOtpVerified()],
    );

    blocTest<AuthCubit, AuthState>(
      'emite [AuthLoading, AuthError] cuando el código es inválido',
      build: () {
        when(() => mockAuthRepository.verifyResetOtp(
              email: any(named: 'email'),
              token: any(named: 'token'),
            )).thenAnswer(
                (_) async => const Left(AuthFailure('Código inválido')));
        return cubit;
      },
      act: (c) =>
          c.verifyResetOtp(email: 'test@test.com', token: '000000'),
      expect: () =>
          [const AuthLoading(), const AuthError(message: 'Código inválido')],
    );
  });

  group('resetPassword', () {
    blocTest<AuthCubit, AuthState>(
      'emite [AuthLoading, AuthPasswordResetSuccess] cuando la contraseña se actualiza',
      build: () {
        when(() => mockAuthRepository.resetPassword(
              newPassword: any(named: 'newPassword'),
            )).thenAnswer((_) async => const Right(null));
        return cubit;
      },
      act: (c) => c.resetPassword(newPassword: 'NuevaPass123'),
      expect: () =>
          [const AuthLoading(), const AuthPasswordResetSuccess()],
    );

    blocTest<AuthCubit, AuthState>(
      'emite [AuthLoading, AuthError] cuando falla el reset',
      build: () {
        when(() => mockAuthRepository.resetPassword(
              newPassword: any(named: 'newPassword'),
            )).thenAnswer(
                (_) async => const Left(AuthFailure('Sesión expirada')));
        return cubit;
      },
      act: (c) => c.resetPassword(newPassword: 'NuevaPass123'),
      expect: () =>
          [const AuthLoading(), const AuthError(message: 'Sesión expirada')],
    );
  });
}
