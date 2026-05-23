import '../models/user_model.dart';

abstract class AuthDataSource {
  Future<UserModel> login({required String email, required String password});
  Future<UserModel> register({required String email, required String password});
  Future<void> logout();
  Future<UserModel?> getCurrentUser();
}
