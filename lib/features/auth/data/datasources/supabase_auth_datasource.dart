import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/errors/exceptions.dart' as app;
import '../models/user_model.dart';
import 'auth_datasource.dart';

class SupabaseAuthDataSource implements AuthDataSource {
  final SupabaseClient client;

  SupabaseAuthDataSource(this.client);

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      if (response.user == null) {
        throw const app.AuthException('Login fallido');
      }
      try {
        return await _fetchUserProfile(response.user!.id);
      } catch (_) {
        return UserModel(id: response.user!.id, email: response.user!.email ?? email);
      }
    } on app.AuthException {
      rethrow;
    } catch (e) {
      throw app.AuthException(_extractMessage(e));
    }
  }

  @override
  Future<UserModel> register({
    required String email,
    required String password,
    String? fullName,
  }) async {
    try {
      final response = await client.auth.signUp(
        email: email,
        password: password,
        data: fullName != null ? {'nombre': fullName} : null,
      );
      if (response.user == null) {
        throw const app.AuthException('Registro fallido');
      }
      try {
        return await _fetchUserProfile(response.user!.id);
      } catch (_) {
        return UserModel(
          id: response.user!.id,
          email: email,
          nombre: fullName,
        );
      }
    } on app.AuthException {
      rethrow;
    } catch (e) {
      throw app.AuthException(_extractMessage(e));
    }
  }

  @override
  Future<void> logout() async {
    try {
      await client.auth.signOut();
    } catch (e) {
      throw app.ServerException(_extractMessage(e));
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final authUser = client.auth.currentUser;
    if (authUser == null) return null;
    try {
      return await _fetchUserProfile(authUser.id);
    } catch (_) {
      return UserModel(id: authUser.id, email: authUser.email ?? '');
    }
  }

  @override
  Future<void> loginWithGoogle() async {
    try {
      await client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'com.cubamap.app://login-callback',
      );
    } catch (e) {
      throw app.AuthException(_extractMessage(e));
    }
  }

  @override
  Future<void> forgotPassword({required String email}) async {
    try {
      await client.auth.resetPasswordForEmail(email);
    } catch (e) {
      throw app.AuthException(_extractMessage(e));
    }
  }

  @override
  Future<void> verifyResetOtp({
    required String email,
    required String token,
  }) async {
    try {
      await client.auth.verifyOTP(
        email: email,
        token: token,
        type: OtpType.recovery,
      );
    } catch (e) {
      throw app.AuthException(_extractMessage(e));
    }
  }

  @override
  Future<void> resetPassword({required String newPassword}) async {
    try {
      await client.auth.updateUser(UserAttributes(password: newPassword));
    } catch (e) {
      throw app.AuthException(_extractMessage(e));
    }
  }

  Future<UserModel> _fetchUserProfile(String userId) async {
    final data = await client
        .from('users')
        .select()
        .eq('id', userId)
        .single();
    return UserModel.fromMap(data);
  }

  String _extractMessage(Object e) =>
      e.toString().replaceFirst(RegExp(r'^[A-Za-z]+Exception: '), '');
}
