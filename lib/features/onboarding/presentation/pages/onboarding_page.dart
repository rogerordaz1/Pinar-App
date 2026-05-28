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

  static const _slides = [
    OnboardingSlideData(
      assetPath: 'assets/images/onboarding/slide_descubre.png',
      title: 'Explora Pinar del Río',
      description:
          'Mira qué tiendas tienen lo que buscas en el mapa interactivo.',
    ),
    OnboardingSlideData(
      assetPath: 'assets/images/onboarding/slide_encuentra.png',
      title: 'Encuentra lo que necesitas',
      description:
          'Localiza productos en tiempo real en los negocios de tu barrio.',
    ),
    OnboardingSlideData(
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
