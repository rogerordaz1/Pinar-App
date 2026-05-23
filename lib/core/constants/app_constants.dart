class AppConstants {
  // La anon key es pública por diseño — va en el binario del APK.
  // En CI/CD pasar vía --dart-define-from-file para override.
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://cjcsqrynqmxysfkgpnie.supabase.co',
  );
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNqY3NxcnlucW14eXNma2dwbmllIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzk0ODkzMzcsImV4cCI6MjA5NTA2NTMzN30.rSTdyEP9owZhqAm7_9Nd5bmHjAcbbwsSOULBxM6T9fE',
  );

  static const double defaultSearchRadiusMeters = 5000.0;
  static const int defaultPageSize = 20;
  static const Duration cacheExpiry = Duration(hours: 1);
  static const int gracePeriodDays = 7;
}
