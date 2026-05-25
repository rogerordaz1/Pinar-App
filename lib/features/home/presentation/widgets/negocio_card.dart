import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/negocio_preview.dart';

class NegocioCard extends StatelessWidget {
  final NegocioPreview negocio;

  const NegocioCard({super.key, required this.negocio});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.go('/negocio/${negocio.id}'),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.store_outlined,
                    color: AppColors.onSurfaceVariant),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            negocio.nombre,
                            style: AppTextStyles.body,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (negocio.verificado) ...[
                          const SizedBox(width: 4),
                          Icon(Icons.verified,
                              size: 15, color: AppColors.secondary),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${negocio.categoria} · ${negocio.distanciaKm.toStringAsFixed(1)} km',
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: negocio.abierto
                      ? AppColors.success.withOpacity(0.12)
                      : AppColors.error.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
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
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right,
                  color: AppColors.onSurfaceVariant, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
