import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/core.dart';
import '../../domain/entities/resultado_busqueda.dart';

class ResultadoCard extends StatelessWidget {
  final ResultadoBusqueda resultado;

  const ResultadoCard({super.key, required this.resultado});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImage(),
            const SizedBox(width: 12),
            Expanded(child: _buildContent(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    if (resultado.logoUrl != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: CachedNetworkImage(
          imageUrl: resultado.logoUrl!,
          width: 72,
          height: 72,
          fit: BoxFit.cover,
          placeholder: (_, __) => _imagePlaceholder(),
          errorWidget: (_, __, ___) => _imagePlaceholder(),
        ),
      );
    }
    return _imagePlaceholder();
  }

  Widget _imagePlaceholder() {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(Icons.store_outlined,
          color: AppColors.outline, size: 28),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                resultado.productoNombre,
                style: AppTextStyles.body
                    .copyWith(fontWeight: FontWeight.w600),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.favorite_border,
                size: 18, color: AppColors.outline),
          ],
        ),
        const SizedBox(height: 2),
        Row(
          children: [
            Flexible(
              child: Text(
                resultado.negocioNombre,
                style: AppTextStyles.caption
                    .copyWith(color: AppColors.onSurface),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (resultado.negocioVerificado) ...[
              const SizedBox(width: 3),
              Icon(Icons.verified, size: 13, color: AppColors.secondary),
            ],
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            _OpenBadge(abierto: resultado.negocioAbierto),
            const SizedBox(width: 6),
            Text(
              '${(resultado.distanciaMetros / 1000).toStringAsFixed(1)} km',
              style: AppTextStyles.caption,
            ),
            if (resultado.calificacion > 0) ...[
              const SizedBox(width: 6),
              Icon(Icons.star_rounded,
                  size: 12, color: AppColors.warning),
              Text(
                resultado.calificacion.toStringAsFixed(1),
                style: AppTextStyles.caption.copyWith(
                    fontWeight: FontWeight.w600),
              ),
            ],
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Text(
              'CUP ${resultado.precio.toStringAsFixed(0)}',
              style: AppTextStyles.body.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              resultado.actualizadoHace,
              style: AppTextStyles.caption,
            ),
          ],
        ),
        const SizedBox(height: 6),
        SizedBox(
          height: 28,
          child: OutlinedButton(
            onPressed: () => context.push('/negocio/${resultado.negocioId}'),
            style: OutlinedButton.styleFrom(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12),
              textStyle: AppTextStyles.caption
                  .copyWith(fontWeight: FontWeight.w600),
              side: BorderSide(color: AppColors.primary),
            ),
            child: const Text('Ver Detalles'),
          ),
        ),
      ],
    );
  }
}

class _OpenBadge extends StatelessWidget {
  final bool abierto;
  const _OpenBadge({required this.abierto});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: abierto
            ? AppColors.success.withOpacity(0.12)
            : AppColors.error.withOpacity(0.12),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        abierto ? 'Abierto' : 'Cerrado',
        style: AppTextStyles.caption.copyWith(
          color: abierto ? AppColors.success : AppColors.error,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
