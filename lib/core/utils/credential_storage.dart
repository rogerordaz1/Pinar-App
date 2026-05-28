import 'package:shared_preferences/shared_preferences.dart';

class CredentialStorage {
  static const _emailKey = 'saved_email';
  static const _passwordKey = 'saved_password';

  Future<void> save({required String email, required String password}) async {
    final prefs = await SharedPreferences.getInstance();
    await Future.wait([
      prefs.setString(_emailKey, email),
      prefs.setString(_passwordKey, password),
    ]);
  }

  Future<({String email, String password})?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString(_emailKey);
    final password = prefs.getString(_passwordKey);
    if (email == null || password == null) return null;
    return (email: email, password: password);
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await Future.wait([
      prefs.remove(_emailKey),
      prefs.remove(_passwordKey),
    ]);
  }
}
