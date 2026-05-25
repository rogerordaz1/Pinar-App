import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../shell/main_shell.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/reset_password_page.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/auth/presentation/pages/verify_otp_page.dart';
import '../../features/home/presentation/cubit/home_cubit.dart';
import '../../features/home/presentation/pages/home_page.dart';
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

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: RouteNames.splash,
    debugLogDiagnostics: true,
    routes: [
      // ── Auth routes (outside shell) ──────────────────────────────
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
        path: RouteNames.forgotPassword,
        builder: (_, __) => BlocProvider(
          create: (_) => sl<AuthCubit>(),
          child: const ForgotPasswordPage(),
        ),
      ),
      GoRoute(
        path: RouteNames.verifyOtp,
        builder: (_, state) => BlocProvider(
          create: (_) => sl<AuthCubit>(),
          child: VerifyOtpPage(email: state.extra as String),
        ),
      ),
      GoRoute(
        path: RouteNames.resetPassword,
        builder: (_, __) => BlocProvider(
          create: (_) => sl<AuthCubit>(),
          child: const ResetPasswordPage(),
        ),
      ),

      // ── Negocio detail (sin bottom nav — se implementa en feature busqueda) ──
      GoRoute(
        path: '/negocio/:id',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return _PlaceholderPage('Negocio $id');
        },
      ),

      // ── Main shell (4 tabs) ──────────────────────────────────────
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => BlocProvider(
          create: (_) => sl<AuthCubit>(),
          child: MainShell(navigationShell: navigationShell),
        ),
        branches: [
          // Tab 0: Inicio
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteNames.home,
                builder: (context, state) => BlocProvider(
                  create: (_) => sl<HomeCubit>(),
                  child: const HomePage(),
                ),
              ),
            ],
          ),

          // Tab 1: Buscar
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteNames.busqueda,
                builder: (_, __) => const _PlaceholderPage('Buscar'),
              ),
            ],
          ),

          // Tab 2: Favoritos
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteNames.favoritos,
                builder: (_, __) => const _PlaceholderPage('Favoritos'),
              ),
            ],
          ),

          // Tab 3: Perfil
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteNames.perfil,
                builder: (_, __) => const _PlaceholderPage('Perfil'),
              ),
            ],
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('Ruta no encontrada: ${state.uri}')),
    ),
  );
}
