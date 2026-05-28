import 'package:flutter/material.dart';
import '../../../../core/core.dart';

class HomeSectionHeader extends StatelessWidget {
  final String titulo;
  final VoidCallback? onVerTodos;
  const HomeSectionHeader({super.key, required this.titulo, this.onVerTodos});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 8, 8),
      child: Row(
        children: [
          Expanded(child: Text(titulo, style: AppTextStyles.heading3)),
          if (onVerTodos != null)
            TextButton(
              onPressed: onVerTodos,
              child: Text(
                'Ver todos',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
