import 'package:flutter/material.dart';
import '../../../../../core/core.dart';

class SectionSeparator extends StatelessWidget {
  const SectionSeparator({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 8,
      child: ColoredBox(color: AppColors.surfaceContainerLow),
    );
  }
}
