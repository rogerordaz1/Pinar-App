import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/core.dart';
import '../../domain/entities/negocio_recomendado.dart';

class RecomendadoCard extends StatelessWidget {
  final NegocioRecomendado negocio;

  const RecomendadoCard({super.key, required this.negocio});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push('/negocio/${negocio.id}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImageWithBadge(),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      negocio.nombre,
                      style: AppTextStyles.body
                          .copyWith(fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (negocio.descripcion != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        negocio.descripcion!,
                        style: AppTextStyles.caption,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const Spacer(),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined,
                            size: 12, color: AppColors.outline),
                        const SizedBox(width: 2),
                        Text(
                          '${negocio.distanciaKm.toStringAsFixed(1)} km',
                          style: AppTextStyles.caption,
                        ),
                        if (negocio.calificacion > 0) ...[
                          const SizedBox(width: 6),
                          const Icon(Icons.star_rounded,
                              size: 12, color: AppColors.warning),
                          Text(
                            negocio.calificacion.toStringAsFixed(1),
                            style: AppTextStyles.caption
                                .copyWith(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      height: 30,
                      child: ElevatedButton(
                        onPressed: () =>
                            context.push('/negocio/${negocio.id}'),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.zero,
                          textStyle: AppTextStyles.caption
                              .copyWith(fontWeight: FontWeight.w600),
                        ),
                        child: const Text('Explorar'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageWithBadge() {
    return Stack(
      children: [
        _buildImage(),
        Positioned(
          top: 8,
          left: 8,
          child: _RecomendadoBadge(),
        ),
      ],
    );
  }

  Widget _buildImage() {
    if (negocio.logoUrl != null) {
      return CachedNetworkImage(
        imageUrl: negocio.logoUrl!,
        height: 110,
        width: double.infinity,
        fit: BoxFit.cover,
        placeholder: (_, __) => _imagePlaceholder(),
        errorWidget: (_, __, ___) => _imagePlaceholder(),
      );
    }
    return _imagePlaceholder();
  }

  Widget _imagePlaceholder() {
    return Container(
      height: 110,
      width: double.infinity,
      color: AppColors.primary.withValues(alpha: 0.1),
      child: const Icon(Icons.store_outlined,
          color: AppColors.primary, size: 32),
    );
  }
}

class _RecomendadoBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        'RECOMENDADO',
        style: AppTextStyles.caption.copyWith(
          color: AppColors.onPrimary,
          fontWeight: FontWeight.w700,
          fontSize: 9,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
