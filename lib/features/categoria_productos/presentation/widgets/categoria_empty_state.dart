import 'package:flutter/material.dart';
import '../../../../../core/core.dart';

class CategoriaEmptyState extends StatelessWidget {
  final String categoriaNombre;
  const CategoriaEmptyState({super.key, required this.categoriaNombre});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.inventory_2_outlined,
              size: 56, color: AppColors.outline),
          const SizedBox(height: 12),
          Text(
            'Sin productos disponibles\nen "$categoriaNombre"',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySmall,
          ),
        ],
      ),
    );
  }
}
