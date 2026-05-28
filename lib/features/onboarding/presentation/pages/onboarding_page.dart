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
      illustration: Image.asset(
        'assets/images/onboarding/slide_descubre.png',
        height: 220,
        fit: BoxFit.contain,
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

class _EncuentraIllustration extends StatefulWidget {
  const _EncuentraIllustration();

  @override
  State<_EncuentraIllustration> createState() => _EncuentraIllustrationState();
}

class _EncuentraIllustrationState extends State<_EncuentraIllustration>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<Offset> _slideAnim;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, -2.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut));
    _fadeAnim = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.0, 0.35, curve: Curves.easeIn),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

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

          // Ícono de bolsa — anima de arriba hacia abajo
          Positioned(
            top: 0,
            right: 0,
            child: SlideTransition(
              position: _slideAnim,
              child: FadeTransition(
                opacity: _fadeAnim,
                child: Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.14),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.shopping_bag,
                    color: AppColors.primary,
                    size: 28,
                  ),
                ),
              ),
            ),
          ),

          // Barra de búsqueda flotante en la parte inferior
          Positioned(
            bottom: 0,
            left: 12,
            right: 36,
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

// ── Ilustración slide 3: campana con chip de notificación ────────────────────

class _AlertasIllustration extends StatelessWidget {
  const _AlertasIllustration();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 140,
            height: 140,
            decoration: const BoxDecoration(
              color: AppColors.onPrimaryContainer,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.notifications_active_outlined,
              size: 72,
              color: AppColors.primary,
            ),
          ),
          Positioned(
            top: 24,
            right: 20,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary,
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
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
