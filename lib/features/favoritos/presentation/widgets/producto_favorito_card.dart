import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/core.dart';
import '../../domain/entities/producto_favorito.dart';
import '../cubit/productos_favoritos_cubit.dart';

class ProductoFavoritoCard extends StatelessWidget {
  final ProductoFavorito favorito;

  const ProductoFavoritoCard({super.key, required this.favorito});

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
    if (favorito.imageUrl != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: CachedNetworkImage(
          imageUrl: favorito.imageUrl!,
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
      child: const Icon(Icons.fastfood_outlined,
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
                favorito.productoNombre,
                style: AppTextStyles.body
                    .copyWith(fontWeight: FontWeight.w600),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            GestureDetector(
              onTap: () => context
                  .read<ProductosFavoritosCubit>()
                  .toggleFavorito(favorito.productoId, favorito.negocioId),
              child: const Icon(Icons.favorite, size: 20, color: AppColors.error),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          favorito.negocioNombre,
          style: AppTextStyles.caption
              .copyWith(color: AppColors.onSurface),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Text(
              'CUP ${favorito.precio.toStringAsFixed(0)}',
              style: AppTextStyles.body.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
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
