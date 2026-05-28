import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../injection_container.dart' as di;
import '../shell/main_shell.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/reset_password_page.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/auth/presentation/pages/verify_otp_page.dart';
import '../../features/auth/presentation/pages/profile_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/negocio_detalle/negocio_detalle.dart';
import '../../features/onboarding/presentation/pages/onboarding_page.dart';
import 'route_names.dart';

class _PlaceholderPage extends StatelessWidget {
  final String name;
  const _PlaceholderPage(this.name);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(name, style: Theme.of(context).textTheme.titleLarge),
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
        builder: (_, __) => const SplashPage(),
      ),
      GoRoute(
        path: RouteNames.onboarding,
        builder: (_, __) => const OnboardingPage(),
      ),
      GoRoute(
        path: RouteNames.login,
        builder: (_, __) => const LoginPage(),
      ),
      GoRoute(
        path: RouteNames.register,
        builder: (_, __) => const RegisterPage(),
      ),
      GoRoute(
        path: RouteNames.forgotPassword,
        builder: (_, __) => const ForgotPasswordPage(),
      ),
      GoRoute(
        path: RouteNames.verifyOtp,
        builder: (_, state) => VerifyOtpPage(email: state.extra as String),
      ),
      GoRoute(
        path: RouteNames.resetPassword,
        builder: (_, __) => const ResetPasswordPage(),
      ),

      // ── Negocio detail (sin bottom nav) ──────────────────────────────────
      GoRoute(
        path: '/negocio/:id',
        builder: (_, state) {
          final id = state.pathParameters['id'] ?? '';
          return BlocProvider(
            create: (_) =>
                di.sl<NegocioDetalleCubit>()..loadNegocio(id),
            child: NegocioDetallePage(negocioId: id),
          );
        },
      ),

      // ── Main shell (4 tabs) ──────────────────────────────────────
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            MainShell(navigationShell: navigationShell),
        branches: [
          // Tab 0: Inicio
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteNames.home,
                builder: (_, __) => const HomePage(),
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
                builder: (_, __) => const ProfilePage(),
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
