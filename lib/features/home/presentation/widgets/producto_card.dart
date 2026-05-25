import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/producto_popular.dart';

class ProductoCard extends StatelessWidget {
  final ProductoPopular producto;

  const ProductoCard({super.key, required this.producto});

  IconData _fallbackIcon() {
    final nombre = producto.nombre.toLowerCase();
    if (nombre.contains('huevo')) return Icons.egg_outlined;
    if (nombre.contains('pan')) return Icons.bakery_dining;
    if (nombre.contains('aceite')) return Icons.water_drop_outlined;
    if (nombre.contains('pollo') || nombre.contains('carne')) {
      return Icons.set_meal_outlined;
    }
    if (nombre.contains('arroz') || nombre.contains('frijol')) {
      return Icons.rice_bowl_outlined;
    }
    if (nombre.contains('mg') ||
        nombre.contains('aspirina') ||
        nombre.contains('medicina')) {
      return Icons.medication_outlined;
    }
    return Icons.shopping_bag_outlined;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.go('/negocio/${producto.negocioId}'),
      child: Container(
        width: 140,
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
              child: producto.imagenUrl != null
                  ? CachedNetworkImage(
                      imageUrl: producto.imagenUrl!,
                      height: 100,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => _placeholder(),
                      errorWidget: (_, __, ___) => _placeholder(),
                    )
                  : _placeholder(),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    producto.nombre,
                    style: AppTextStyles.body
                        .copyWith(fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '\$${producto.precio.toStringAsFixed(0)} / ${producto.unidad}',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    producto.negocioNombre,
                    style: AppTextStyles.caption,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (!producto.disponible) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Agotado',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      height: 100,
      width: double.infinity,
      color: AppColors.primary.withOpacity(0.08),
      child: Icon(_fallbackIcon(), color: AppColors.primary, size: 36),
    );
  }
}
