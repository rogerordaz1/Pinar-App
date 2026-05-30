import 'package:flutter/material.dart';
import '../../../../../core/core.dart';

class FavoritosEmptyState extends StatelessWidget {
  final String label;
  const FavoritosEmptyState({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.favorite_border,
              size: 64, color: AppColors.outline),
          const SizedBox(height: 16),
          Text(
            label,
            style:
                AppTextStyles.body.copyWith(color: AppColors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
