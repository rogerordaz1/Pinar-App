import 'package:flutter/material.dart';
import '../../../../core/core.dart';

class OnboardingSlideData {
  final String? assetPath;
  final String title;
  final String description;
  const OnboardingSlideData({
    this.assetPath,
    required this.title,
    required this.description,
  });
}

class OnboardingSlideWidget extends StatelessWidget {
  final OnboardingSlideData data;
  const OnboardingSlideWidget({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (data.assetPath != null)
            Image.asset(
              data.assetPath!,
              height: 220,
              fit: BoxFit.contain,
            )
          else
            const _AlertasIllustration(),
          const SizedBox(height: 48),
          Text(
            data.title,
            style: theme.textTheme.displayMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            data.description,
            style: theme.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

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
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
