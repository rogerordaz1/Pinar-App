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
      return await _fetchUserProfile(response.user!.id);
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
  }) async {
    try {
      final response = await client.auth.signUp(
        email: email,
        password: password,
      );
      if (response.user == null) {
        throw const app.AuthException('Registro fallido');
      }
      // El trigger crea el perfil en public.users; lo buscamos
      try {
        return await _fetchUserProfile(response.user!.id);
      } catch (_) {
        // Perfil aún no creado por el trigger — devolvemos mínimo
        return UserModel(id: response.user!.id, email: email);
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
      return null;
    }
  }

  Future<UserModel> _fetchUserProfile(String userId) async {
    final data = await client
        .from('users')
        .select()
        .eq('id', userId)
        .single();
    return UserModel.fromMap(data as Map<String, dynamic>);
  }

  String _extractMessage(Object e) =>
      e.toString().replaceFirst(RegExp(r'^[A-Za-z]+Exception: '), '');
}
