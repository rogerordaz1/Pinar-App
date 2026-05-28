import 'package:flutter/material.dart';
import '../../../../core/core.dart';

class OnboardingDotsIndicator extends StatelessWidget {
  final int count;
  final int current;
  const OnboardingDotsIndicator({
    super.key,
    required this.count,
    required this.current,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(count, (i) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: i == current ? 20 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: i == current
                ? AppColors.primary
                : AppColors.onPrimaryContainer,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}
