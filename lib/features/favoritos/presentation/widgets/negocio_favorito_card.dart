import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/core.dart';
import '../../domain/entities/negocio_favorito.dart';
import '../cubit/negocios_favoritos_cubit.dart';

class NegocioFavoritoCard extends StatelessWidget {
  final NegocioFavorito favorito;

  const NegocioFavoritoCard({super.key, required this.favorito});

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
    if (favorito.logoUrl != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: CachedNetworkImage(
          imageUrl: favorito.logoUrl!,
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
                favorito.negocioNombre,
                style: AppTextStyles.body
                    .copyWith(fontWeight: FontWeight.w600),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            GestureDetector(
              onTap: () => context
                  .read<NegociosFavoritosCubit>()
                  .toggleFavorito(favorito.negocioId),
              child: const Icon(Icons.favorite, size: 20, color: AppColors.error),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            _OpenBadge(abierto: favorito.negocioAbierto),
            if (favorito.calificacion > 0) ...[
              const SizedBox(width: 6),
              const Icon(Icons.star_rounded, size: 12, color: AppColors.warning),
              Text(
                favorito.calificacion.toStringAsFixed(1),
                style: AppTextStyles.caption
                    .copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ],
        ),
        const SizedBox(height: 6),
        SizedBox(
          height: 28,
          child: OutlinedButton(
            onPressed: () =>
                context.push('/negocio/${favorito.negocioId}'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              textStyle: AppTextStyles.caption
                  .copyWith(fontWeight: FontWeight.w600),
              side: const BorderSide(color: AppColors.primary),
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
            ? AppColors.success.withValues(alpha: 0.12)
            : AppColors.error.withValues(alpha: 0.12),
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
