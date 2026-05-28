import 'package:flutter/material.dart';

class OnboardingSlideData {
  final Widget illustration;
  final String title;
  final String description;
  const OnboardingSlideData({
    required this.illustration,
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
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          data.illustration,
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
