import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/utils/credential_storage.dart';
import 'core/utils/onboarding_service.dart';
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
import 'features/home/data/datasources/supabase_home_datasource.dart';
import 'features/home/data/repositories/home_repository_impl.dart';
import 'features/home/domain/repositories/home_repository.dart';
import 'features/home/domain/usecases/get_categorias_usecase.dart';
import 'features/home/domain/usecases/get_negocios_cercanos_usecase.dart';
import 'features/home/domain/usecases/get_promociones_usecase.dart';
import 'features/home/domain/usecases/get_productos_populares_usecase.dart';
import 'features/home/presentation/cubit/home_cubit.dart';
import 'features/negocio_detalle/data/datasources/negocio_detalle_datasource.dart';
import 'features/negocio_detalle/data/datasources/supabase_negocio_detalle_datasource.dart';
import 'features/negocio_detalle/data/repositories/negocio_detalle_repository_impl.dart';
import 'features/negocio_detalle/domain/repositories/negocio_detalle_repository.dart';
import 'features/negocio_detalle/domain/usecases/get_negocio_detalle_usecase.dart';
import 'features/negocio_detalle/presentation/cubit/negocio_detalle_cubit.dart';
import 'features/categoria_productos/data/datasources/categoria_productos_datasource.dart';
import 'features/categoria_productos/data/datasources/supabase_categoria_productos_datasource.dart';
import 'features/categoria_productos/data/repositories/categoria_productos_repository_impl.dart';
import 'features/categoria_productos/domain/repositories/categoria_productos_repository.dart';
import 'features/categoria_productos/domain/usecases/get_productos_por_categoria_usecase.dart';
import 'features/categoria_productos/presentation/cubit/categoria_productos_cubit.dart';
import 'features/favoritos/data/datasources/favoritos_datasource.dart';
import 'features/favoritos/data/datasources/supabase_favoritos_datasource.dart';
import 'features/favoritos/data/repositories/negocios_favoritos_repository_impl.dart';
import 'features/favoritos/data/repositories/productos_favoritos_repository_impl.dart';
import 'features/favoritos/domain/repositories/negocios_favoritos_repository.dart';
import 'features/favoritos/domain/repositories/productos_favoritos_repository.dart';
import 'features/favoritos/domain/usecases/get_negocios_favoritos_usecase.dart';
import 'features/favoritos/domain/usecases/get_productos_favoritos_usecase.dart';
import 'features/favoritos/domain/usecases/toggle_negocio_favorito_usecase.dart';
import 'features/favoritos/domain/usecases/toggle_producto_favorito_usecase.dart';
import 'features/favoritos/presentation/cubit/negocios_favoritos_cubit.dart';
import 'features/favoritos/presentation/cubit/productos_favoritos_cubit.dart';
import 'features/busqueda/data/datasources/busqueda_datasource.dart';
import 'features/busqueda/data/datasources/supabase_busqueda_datasource.dart';
import 'features/busqueda/data/repositories/busqueda_repository_impl.dart';
import 'features/busqueda/domain/repositories/busqueda_repository.dart';
import 'features/busqueda/domain/usecases/buscar_productos_usecase.dart';
import 'features/busqueda/domain/usecases/get_negocios_recomendados_usecase.dart';
import 'features/busqueda/presentation/cubit/busqueda_cubit.dart';

final sl = GetIt.instance;

Future<void> init() async {
  _registerExternal();
  await _registerFeatures();
}

void _registerExternal() {
  sl.registerLazySingleton<SupabaseClient>(
    () => Supabase.instance.client,
  );
  sl.registerLazySingleton(() => CredentialStorage());
  sl.registerLazySingleton(() => OnboardingService());
}

Future<void> _registerFeatures() async {
  await _registerAuth();
  _registerHome();
  _registerNegocioDetalle();
  _registerBusqueda();
  _registerCategoriaProductos();
  _registerFavoritos();
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
      credentialStorage: sl(),
      onboardingService: sl(),
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

  sl.registerLazySingleton<HomeDataSource>(
    () => SupabaseHomeDataSource(sl()),
  );
}

void _registerBusqueda() {
  sl.registerFactory(
    () => BusquedaCubit(
      buscarProductosUseCase: sl(),
      getRecomendadosUseCase: sl(),
    ),
  );
  sl.registerLazySingleton(() => BuscarProductosUseCase(sl()));
  sl.registerLazySingleton(() => GetNegociosRecomendadosUseCase(sl()));
  sl.registerLazySingleton<BusquedaRepository>(
    () => BusquedaRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<BusquedaDataSource>(
    () => SupabaseBusquedaDataSource(sl()),
  );
}

void _registerCategoriaProductos() {
  sl.registerFactory(
    () => CategoriaProductosCubit(getProductosPorCategoriaUseCase: sl()),
  );
  sl.registerLazySingleton(() => GetProductosPorCategoriaUseCase(sl()));
  sl.registerLazySingleton<CategoriaProductosRepository>(
    () => CategoriaProductosRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<CategoriaProductosDataSource>(
    () => SupabaseCategoriaProductosDataSource(sl()),
  );
}

void _registerNegocioDetalle() {
  sl.registerFactory(
    () => NegocioDetalleCubit(getNegocioDetalleUseCase: sl()),
  );
  sl.registerLazySingleton(() => GetNegocioDetalleUseCase(sl()));
  sl.registerLazySingleton<NegocioDetalleRepository>(
    () => NegocioDetalleRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<NegocioDetalleDataSource>(
    () => SupabaseNegocioDetalleDataSource(sl()),
  );
}

void _registerFavoritos() {
  sl.registerFactory(
    () => NegociosFavoritosCubit(
      getNegociosFavoritosUseCase: sl(),
      toggleNegocioFavoritoUseCase: sl(),
    ),
  );
  sl.registerFactory(
    () => ProductosFavoritosCubit(
      getProductosFavoritosUseCase: sl(),
      toggleProductoFavoritoUseCase: sl(),
    ),
  );
  sl.registerLazySingleton(() => GetNegociosFavoritosUseCase(sl()));
  sl.registerLazySingleton(() => ToggleNegocioFavoritoUseCase(sl()));
  sl.registerLazySingleton(() => GetProductosFavoritosUseCase(sl()));
  sl.registerLazySingleton(() => ToggleProductoFavoritoUseCase(sl()));
  sl.registerLazySingleton<NegociosFavoritosRepository>(
    () => NegociosFavoritosRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<ProductosFavoritosRepository>(
    () => ProductosFavoritosRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<FavoritosDataSource>(
    () => SupabaseFavoritosDataSource(sl()),
  );
}
