import 'package:flutter/material.dart';
import '../../../../core/core.dart';

class OnboardingSlideData {
  final IconData icon;
  final String title;
  final String description;
  const OnboardingSlideData({
    required this.icon,
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
          Container(
            width: 120,
            height: 120,
            decoration: const BoxDecoration(
              color: AppColors.onPrimaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(data.icon, size: 60, color: AppColors.primary),
          ),
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
