import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class SearchBarTap extends StatelessWidget {
  const SearchBarTap({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: GestureDetector(
        onTap: () => context.go(RouteNames.busqueda),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: AppColors.outlineVariant),
          ),
          child: Row(
            children: [
              Icon(Icons.search, color: AppColors.onSurfaceVariant),
              const SizedBox(width: 12),
              Text(
                'Buscar productos o negocios...',
                style: AppTextStyles.body
                    .copyWith(color: AppColors.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
