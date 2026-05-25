import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/negocio_preview.dart';

class NegocioCard extends StatelessWidget {
  final NegocioPreview negocio;

  const NegocioCard({super.key, required this.negocio});

  Color _headerColor() {
    return switch (negocio.categoria) {
      'Panadería' => const Color(0xFFF59E0B),
      'Cafetería' => const Color(0xFF6F4E37),
      'Farmacia' => const Color(0xFF0D9488),
      'Agropecuario' => const Color(0xFF16A34A),
      'Restaurante' => const Color(0xFFDC2626),
      'Tienda' => const Color(0xFF7C3AED),
      'Ferretería' => const Color(0xFF92400E),
      _ => AppColors.primary,
    };
  }

  IconData _icon() {
    return switch (negocio.categoria) {
      'Panadería' => Icons.bakery_dining,
      'Cafetería' => Icons.coffee,
      'Farmacia' => Icons.local_pharmacy,
      'Agropecuario' => Icons.grass,
      'Restaurante' => Icons.restaurant,
      'Tienda' => Icons.store,
      'Ferretería' => Icons.hardware,
      _ => Icons.store_outlined,
    };
  }

  @override
  Widget build(BuildContext context) {
    final color = _headerColor();
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push('/negocio/${negocio.id}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 72,
              width: double.infinity,
              color: color.withOpacity(0.15),
              child: Icon(_icon(), color: color, size: 36),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          negocio.nombre,
                          style: AppTextStyles.body
                              .copyWith(fontWeight: FontWeight.w600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (negocio.verificado) ...[
                        const SizedBox(width: 4),
                        Icon(Icons.verified, size: 15, color: AppColors.secondary),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (negocio.calificacion > 0) ...[
                        Icon(Icons.star_rounded,
                            size: 14, color: AppColors.warning),
                        const SizedBox(width: 2),
                        Text(
                          negocio.calificacion.toStringAsFixed(1),
                          style: AppTextStyles.caption.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.onSurface,
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Expanded(
                        child: Text(
                          '${negocio.categoria} · ${negocio.distanciaKm.toStringAsFixed(1)} km',
                          style: AppTextStyles.caption,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: negocio.abierto
                              ? AppColors.success.withOpacity(0.12)
                              : AppColors.error.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          negocio.abierto ? 'Abierto' : 'Cerrado',
                          style: AppTextStyles.caption.copyWith(
                            color: negocio.abierto
                                ? AppColors.success
                                : AppColors.error,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
