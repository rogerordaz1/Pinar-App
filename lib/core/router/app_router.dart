// lib/core/router/app_router.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'route_names.dart';

class _PlaceholderPage extends StatelessWidget {
  final String name;
  const _PlaceholderPage(this.name);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(name)),
      body: Center(
        child: Text(
          name,
          style: Theme.of(context).textTheme.titleLarge,
        ),
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
        builder: (_, __) => const _PlaceholderPage('Splash'),
      ),
      GoRoute(
        path: RouteNames.onboarding,
        builder: (_, __) => const _PlaceholderPage('Onboarding'),
      ),
      GoRoute(
        path: RouteNames.login,
        builder: (_, __) => const _PlaceholderPage('Login'),
      ),
      GoRoute(
        path: RouteNames.register,
        builder: (_, __) => const _PlaceholderPage('Register'),
      ),
      GoRoute(
        path: RouteNames.home,
        builder: (_, __) => const _PlaceholderPage('Home'),
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
        builder: (_, __) => const _PlaceholderPage('Actualizar Disponibilidad'),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Ruta no encontrada: ${state.uri}'),
      ),
    ),
  );
}
