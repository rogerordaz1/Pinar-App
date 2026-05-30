import 'package:flutter/material.dart';
import '../../../../../core/core.dart';

class FavoritosErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const FavoritosErrorState({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            message,
            style: AppTextStyles.body.copyWith(color: AppColors.error),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: onRetry,
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }
}
