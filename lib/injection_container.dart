// lib/injection_container.dart
import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final sl = GetIt.instance;

Future<void> init() async {
  _registerExternal();
  await _registerFeatures();
}

void _registerExternal() {
  sl.registerLazySingleton<SupabaseClient>(
    () => Supabase.instance.client,
  );
}

Future<void> _registerFeatures() async {
  // Features registered here in Phases 1 and 2
}
