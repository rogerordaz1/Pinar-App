import 'package:flutter/material.dart';
import '../../../../../core/core.dart';

class LogoCircle extends StatelessWidget {
  const LogoCircle({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 88,
      height: 88,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        border: Border.all(color: AppColors.surface, width: 4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Icon(
        Icons.storefront_outlined,
        color: AppColors.primary,
        size: 44,
      ),
    );
  }
}
