import 'package:flutter/material.dart';
import '../../../../core/core.dart';

class OtpBox extends StatelessWidget {
  final String char;
  final bool isCurrent;

  const OtpBox({super.key, required this.char, required this.isCurrent});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: 36,
      height: 50,
      decoration: BoxDecoration(
        border: Border.all(
          color: isCurrent ? AppColors.primary : AppColors.outlineVariant,
          width: isCurrent ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(12),
        color: char.isNotEmpty
            ? AppColors.onPrimaryContainer
            : Colors.transparent,
      ),
      alignment: Alignment.center,
      child: Text(
        char,
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
      ),
    );
  }
}
