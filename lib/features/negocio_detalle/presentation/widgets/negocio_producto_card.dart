import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../../../core/core.dart';
import '../../domain/entities/negocio_detalle.dart';

class NegocioProductoCard extends StatelessWidget {
  final ProductoNegocio producto;
  const NegocioProductoCard({super.key, required this.producto});

  static const _cardWidth = 160.0;

  Color _color() {
    final name = producto.nombre.toLowerCase();
    if (name.contains('huevo')) return const Color(0xFFF9A825);
    if (name.contains('pollo')) return const Color(0xFFE65100);
    if (name.contains('miel')) return const Color(0xFFFF8F00);
    if (name.contains('carne') || name.contains('cerdo')) {
      return const Color(0xFFB71C1C);
    }
    return AppColors.primary;
  }

  IconData _icon() {
    final name = producto.nombre.toLowerCase();
    if (name.contains('huevo')) return Icons.egg_outlined;
    if (name.contains('pollo') || name.contains('carne')) {
      return Icons.set_meal_outlined;
    }
    if (name.contains('pan') || name.contains('bizcocho')) {
      return Icons.bakery_dining;
    }
    if (name.contains('mg') || name.contains('aspirina')) {
      return Icons.medication_outlined;
    }
    if (name.contains('arroz') || name.contains('frijol')) {
      return Icons.rice_bowl_outlined;
    }
    return Icons.shopping_basket_outlined;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _color();
    return SizedBox(
      width: _cardWidth,
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: AppColors.surfaceContainerLowest,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
              child: Stack(
                children: [
                  if (producto.imagenUrl != null)
                    CachedNetworkImage(
                      imageUrl: producto.imagenUrl!,
                      height: 100,
                      width: _cardWidth,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => _imagePlaceholder(color),
                      errorWidget: (_, __, ___) => _imagePlaceholder(color),
                    )
                  else
                    _imagePlaceholder(color),
                  if (producto.disponible)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.success,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Disponible',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    producto.nombre,
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${producto.precio.toInt()} / ${producto.unidad}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Actualizado: ${producto.actualizadoHace}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 10,
                      color: AppColors.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imagePlaceholder(Color color) => Container(
        height: 100,
        width: _cardWidth,
        color: color.withValues(alpha: 0.12),
        child: Center(child: Icon(_icon(), color: color, size: 40)),
      );
}
