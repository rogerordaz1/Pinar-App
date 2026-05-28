import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/core.dart';
import '../../../auth/auth.dart';
import '../widgets/onboarding_dots_indicator.dart';
import '../widgets/onboarding_slide.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  static final _slides = [
    OnboardingSlideData(
      illustration: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Image.asset(
          'assets/images/onboarding/slide_descubre.png',
          height: 242,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
      ),
      title: 'Explora Pinar del Río',
      description:
          'Mira qué tiendas tienen lo que buscas en el mapa interactivo.',
    ),
    const OnboardingSlideData(
      illustration: _EncuentraIllustration(),
      title: 'Encuentra lo que necesitas',
      description:
          'Localiza productos en tiempo real en los negocios de tu barrio.',
    ),
    const OnboardingSlideData(
      illustration: _AlertasIllustration(),
      title: 'Recibe alertas',
      description:
          'Te avisamos al instante cuando llegue el producto que tanto buscas.',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    await context.read<AuthCubit>().markOnboardingSeen();
    if (mounted) context.go(RouteNames.login);
  }

  void _next() {
    if (_currentPage < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _finish();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLast = _currentPage == _slides.length - 1;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: _finish,
                child: Text(
                  'Saltar',
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: AppColors.onSurfaceVariant),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemCount: _slides.length,
                itemBuilder: (_, i) => OnboardingSlideWidget(data: _slides[i]),
              ),
            ),
            OnboardingDotsIndicator(
              count: _slides.length,
              current: _currentPage,
            ),
            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ElevatedButton(
                onPressed: _next,
                child: Text(isLast ? 'Comenzar' : 'Siguiente'),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

// ── Ilustración slide 2: imagen con ícono animado y barra de búsqueda ───────

class _EncuentraIllustration extends StatelessWidget {
  const _EncuentraIllustration();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 270,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Imagen principal con esquinas redondeadas
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            bottom: 28,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Image.asset(
                'assets/images/onboarding/slide_encuentra.png',
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Ícono de bolsa — glass, cae de arriba una sola vez, un poco arriba del borde
          Positioned(
            top: -16,
            right: 0,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: -64.0, end: 0.0),
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOutBack,
              builder: (_, dy, child) =>
                  Transform.translate(offset: Offset(0, dy), child: child),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                  child: Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.4),
                        width: 1,
                      ),
                    ),
                    child: const Icon(
                      Icons.shopping_bag,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Barra de búsqueda — blanco sólido, anclada abajo a la izquierda
          Positioned(
            bottom: 0,
            left: 12,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.search,
                      color: AppColors.onSurfaceVariant, size: 18),
                  const SizedBox(width: 8),
                  const Text(
                    'Harina de Trigo',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Ilustración slide 3: mockup de teléfono con campana y chip ───────────────

class _AlertasIllustration extends StatelessWidget {
  const _AlertasIllustration();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 280,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          // Teléfono
          Container(
            width: 175,
            height: 270,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(36),
              border: Border.all(color: Colors.black87, width: 2.5),
            ),
            child: Column(
              children: [
                const SizedBox(height: 14),
                // Dynamic Island / notch
                Container(
                  width: 52,
                  height: 13,
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(height: 22),
                // Filas de contenido
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 10,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 10,
                        width: 100,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Burbuja de mensaje
                      Container(
                        height: 60,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerHigh,
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Círculo gris con campana — superpuesto al lado derecho del teléfono
          Positioned(
            right: 20,
            top: 60,
            child: Container(
              width: 76,
              height: 76,
              decoration: const BoxDecoration(
                color: AppColors.surfaceContainerHighest,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.notifications_active,
                color: AppColors.primary,
                size: 38,
              ),
            ),
          ),

          // Chip "¡Aceite llegó!" azul — superpuesto al lado izquierdo
          Positioned(
            left: 12,
            top: 120,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: AppColors.secondary,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Text(
                '¡Aceite llegó!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
