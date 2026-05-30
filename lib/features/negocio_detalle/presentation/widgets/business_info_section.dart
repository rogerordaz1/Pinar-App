import 'package:flutter/material.dart';
import '../../../../../core/core.dart';
import '../../domain/entities/negocio_detalle.dart';
import 'status_badge.dart';

class BusinessInfoSection extends StatelessWidget {
  final NegocioDetalle negocio;
  const BusinessInfoSection({super.key, required this.negocio});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  negocio.nombre,
                  style: theme.textTheme.headlineMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                  textAlign: TextAlign.center,
                ),
              ),
              if (negocio.verificado) ...[
                const SizedBox(width: 6),
                const Icon(Icons.verified, color: AppColors.secondary, size: 22),
              ],
            ],
          ),
          const SizedBox(height: 8),
          StatusBadge(abierto: negocio.abierto),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.star_rounded, color: AppColors.warning, size: 18),
              const SizedBox(width: 4),
              Text(
                negocio.calificacion.toStringAsFixed(1),
                style: theme.textTheme.bodyMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(width: 4),
              Text(
                '(${negocio.totalResenas} reseñas)',
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: AppColors.onSurfaceVariant),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.location_on_outlined,
                  size: 16, color: AppColors.onSurfaceVariant),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  negocio.direccion,
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: AppColors.onSurfaceVariant),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'A ${negocio.distanciaKm.toStringAsFixed(1)} km de tu ubicación',
            style: theme.textTheme.bodySmall
                ?.copyWith(color: AppColors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
