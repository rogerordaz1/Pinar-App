import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../features/auth/presentation/cubit/auth_state.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../injection_container.dart';
import 'route_names.dart';

class _PlaceholderPage extends StatelessWidget {
  final String name;
  const _PlaceholderPage(this.name);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(name)),
      body: Center(
        child: Text(name, style: Theme.of(context).textTheme.titleLarge),
      ),
    );
  }
}

class _TempHomePage extends StatelessWidget {
  const _TempHomePage();

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          context.go(RouteNames.login);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Home'),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Cerrar sesión',
              onPressed: () => context.read<AuthCubit>().logout(),
            ),
          ],
        ),
        body: const Center(child: Text('Home — próximamente')),
      ),
    );
  }
}

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: RouteNames.splash,
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: RouteNames.splash,
        builder: (_, __) => BlocProvider(
          create: (_) => sl<AuthCubit>(),
          child: const SplashPage(),
        ),
      ),
      GoRoute(
        path: RouteNames.login,
        builder: (_, __) => BlocProvider(
          create: (_) => sl<AuthCubit>(),
          child: const LoginPage(),
        ),
      ),
      GoRoute(
        path: RouteNames.register,
        builder: (_, __) => BlocProvider(
          create: (_) => sl<AuthCubit>(),
          child: const RegisterPage(),
        ),
      ),
      GoRoute(
        path: RouteNames.onboarding,
        builder: (_, __) => const _PlaceholderPage('Onboarding'),
      ),
      GoRoute(
        path: RouteNames.home,
        builder: (_, __) => BlocProvider(
          create: (_) => sl<AuthCubit>(),
          child: const _TempHomePage(),
        ),
      ),
      GoRoute(
        path: RouteNames.busqueda,
        builder: (_, __) => const _PlaceholderPage('Búsqueda'),
      ),
      GoRoute(
        path: RouteNames.resultados,
        builder: (_, __) => const _PlaceholderPage('Resultados'),
      ),
      GoRoute(
        path: RouteNames.favoritos,
        builder: (_, __) => const _PlaceholderPage('Favoritos'),
      ),
      GoRoute(
        path: RouteNames.perfil,
        builder: (_, __) => const _PlaceholderPage('Perfil'),
      ),
      GoRoute(
        path: RouteNames.negocioDetalle,
        builder: (_, __) => const _PlaceholderPage('Negocio Detalle'),
      ),
      GoRoute(
        path: RouteNames.registrarNegocio,
        builder: (_, __) => const _PlaceholderPage('Registrar Negocio'),
      ),
      GoRoute(
        path: RouteNames.negocioDashboard,
        builder: (_, __) => const _PlaceholderPage('Dashboard Negocio'),
      ),
      GoRoute(
        path: RouteNames.negocioProductos,
        builder: (_, __) => const _PlaceholderPage('Productos Negocio'),
      ),
      GoRoute(
        path: RouteNames.negocioAgregarProducto,
        builder: (_, __) => const _PlaceholderPage('Agregar Producto'),
      ),
      GoRoute(
        path: RouteNames.negocioMiNegocio,
        builder: (_, __) => const _PlaceholderPage('Mi Negocio'),
      ),
      GoRoute(
        path: RouteNames.negocioSuscripcion,
        builder: (_, __) => const _PlaceholderPage('Suscripción'),
      ),
      GoRoute(
        path: RouteNames.negocioActualizarDisponibilidad,
        builder: (_, __) =>
            const _PlaceholderPage('Actualizar Disponibilidad'),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('Ruta no encontrada: ${state.uri}')),
    ),
  );
}
