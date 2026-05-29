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
