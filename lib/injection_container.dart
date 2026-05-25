import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'features/auth/data/datasources/auth_datasource.dart';
import 'features/auth/data/datasources/supabase_auth_datasource.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/domain/usecases/get_current_user_usecase.dart';
import 'features/auth/domain/usecases/login_usecase.dart';
import 'features/auth/domain/usecases/logout_usecase.dart';
import 'features/auth/domain/usecases/register_usecase.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';
import 'features/home/data/datasources/home_datasource.dart';
import 'features/home/data/datasources/mock_home_datasource.dart';
import 'features/home/data/repositories/home_repository_impl.dart';
import 'features/home/domain/repositories/home_repository.dart';
import 'features/home/domain/usecases/get_categorias_usecase.dart';
import 'features/home/domain/usecases/get_negocios_cercanos_usecase.dart';
import 'features/home/domain/usecases/get_promociones_usecase.dart';
import 'features/home/domain/usecases/get_productos_populares_usecase.dart';
import 'features/home/presentation/cubit/home_cubit.dart';

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
  await _registerAuth();
  _registerHome();
}

Future<void> _registerAuth() async {
  // Cubit
  sl.registerFactory(
    () => AuthCubit(
      loginUseCase: sl(),
      registerUseCase: sl(),
      logoutUseCase: sl(),
      getCurrentUserUseCase: sl(),
      authRepository: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => RegisterUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));
  sl.registerLazySingleton(() => GetCurrentUserUseCase(sl()));

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl()),
  );

  // Data source
  sl.registerLazySingleton<AuthDataSource>(
    () => SupabaseAuthDataSource(sl()),
  );
}

void _registerHome() {
  // Cubit
  sl.registerFactory(
    () => HomeCubit(
      getNegociosCercanosUseCase: sl(),
      getCategoriasUseCase: sl(),
      getPromocionesUseCase: sl(),
      getProductosPopularesUseCase: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetNegociosCercanosUseCase(sl()));
  sl.registerLazySingleton(() => GetCategoriasUseCase(sl()));
  sl.registerLazySingleton(() => GetPromocionesUseCase(sl()));
  sl.registerLazySingleton(() => GetProductosPopularesUseCase(sl()));

  // Repository
  sl.registerLazySingleton<HomeRepository>(
    () => HomeRepositoryImpl(sl()),
  );

  // Data source — swap MockHomeDataSource → SupabaseHomeDataSource cuando esté listo
  sl.registerLazySingleton<HomeDataSource>(
    () => MockHomeDataSource(),
  );
}
