// lib/core/constants/app_constants.dart
class AppConstants {
  static const String supabaseUrl =
      String.fromEnvironment('SUPABASE_URL', defaultValue: '');
  static const String supabaseAnonKey =
      String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: '');

  static const double defaultSearchRadiusMeters = 5000.0;
  static const int defaultPageSize = 20;
  static const Duration cacheExpiry = Duration(hours: 1);
  static const int gracePeriodDays = 7;
}
