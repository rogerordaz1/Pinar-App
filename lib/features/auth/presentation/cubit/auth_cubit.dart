import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/credential_storage.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final LogoutUseCase logoutUseCase;
  final GetCurrentUserUseCase getCurrentUserUseCase;
  final AuthRepository authRepository;
  final CredentialStorage credentialStorage;

  StreamSubscription<supabase.AuthState>? _googleAuthSub;

  AuthCubit({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.logoutUseCase,
    required this.getCurrentUserUseCase,
    required this.authRepository,
    required this.credentialStorage,
  }) : super(const AuthInitial());

  Future<void> checkAuth() async {
    emit(const AuthLoading());
    final result = await getCurrentUserUseCase(const NoParams());
    result.fold(
      (_) => emit(const AuthUnauthenticated()),
      (user) => user != null
          ? emit(AuthAuthenticated(user: user))
          : emit(const AuthUnauthenticated()),
    );
  }

  Future<void> login({required String email, required String password}) async {
    emit(const AuthLoading());
    final result =
        await loginUseCase(LoginParams(email: email, password: password));
    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (user) {
        credentialStorage.save(email: email, password: password);
        emit(AuthAuthenticated(user: user));
      },
    );
  }

  Future<({String email, String password})?> getSavedCredentials() =>
      credentialStorage.load();

  Future<void> register({
    required String email,
    required String password,
    String? fullName,
  }) async {
    emit(const AuthLoading());
    final result = await registerUseCase(
        RegisterParams(email: email, password: password, fullName: fullName));
    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (user) => emit(AuthAuthenticated(user: user)),
    );
  }

  Future<void> logout() async {
    emit(const AuthLoading());
    final result = await logoutUseCase(const NoParams());
    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (_) => emit(const AuthUnauthenticated()),
    );
  }

  Future<void> loginWithGoogle() async {
    emit(const AuthLoading());

    // Suscripción en el cubit (capa de presentación) — no en el datasource.
    // Se activa cuando supabase_flutter procesa el deep link de vuelta.
    _googleAuthSub?.cancel();
    _googleAuthSub = supabase.Supabase.instance.client.auth.onAuthStateChange
        .listen((data) {
      if (data.session != null && !isClosed && state is AuthLoading) {
        _googleAuthSub?.cancel();
        _googleAuthSub = null;
        final u = data.session!.user;
        emit(AuthAuthenticated(user: UserEntity(
          id: u.id,
          email: u.email ?? '',
          nombre: u.userMetadata?['full_name'] as String?,
        )));
      }
    });

    final result = await authRepository.loginWithGoogle();
    if (isClosed) {
      _googleAuthSub?.cancel();
      return;
    }

    result.fold(
      (failure) {
        _googleAuthSub?.cancel();
        _googleAuthSub = null;
        emit(AuthError(message: failure.message));
      },
      (_) {
        // Browser abierto — _googleAuthSub maneja el resultado
      },
    );
  }

  Future<void> forgotPassword({required String email}) async {
    emit(const AuthLoading());
    final result = await authRepository.forgotPassword(email: email);
    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (_) => emit(const AuthPasswordResetEmailSent()),
    );
  }

  Future<void> verifyResetOtp({
    required String email,
    required String token,
  }) async {
    emit(const AuthLoading());
    final result =
        await authRepository.verifyResetOtp(email: email, token: token);
    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (_) => emit(const AuthOtpVerified()),
    );
  }

  Future<void> resetPassword({required String newPassword}) async {
    emit(const AuthLoading());
    final result =
        await authRepository.resetPassword(newPassword: newPassword);
    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (_) => emit(const AuthPasswordResetSuccess()),
    );
  }

  @override
  Future<void> close() {
    _googleAuthSub?.cancel();
    return super.close();
  }
}
