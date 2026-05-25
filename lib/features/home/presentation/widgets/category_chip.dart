import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/categoria_negocio.dart';

class CategoryChip extends StatelessWidget {
  final CategoriaNegocio categoria;
  final VoidCallback onTap;

  const CategoryChip({
    super.key,
    required this.categoria,
    required this.onTap,
  });

  IconData _icon() {
    return switch (categoria.icono) {
      'coffee' => Icons.coffee,
      'grass' => Icons.grass,
      'local_pharmacy' => Icons.local_pharmacy,
      'bakery_dining' => Icons.bakery_dining,
      'store' => Icons.store,
      'health_and_safety' => Icons.health_and_safety,
      'hardware' => Icons.hardware,
      'restaurant' => Icons.restaurant,
      _ => Icons.category,
    };
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 72,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(_icon(), color: AppColors.primary, size: 26),
            ),
            const SizedBox(height: 4),
            Text(
              categoria.nombre,
              style: AppTextStyles.caption,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
