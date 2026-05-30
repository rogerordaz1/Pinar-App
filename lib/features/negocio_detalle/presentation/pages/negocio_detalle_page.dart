import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/core.dart';
import '../../negocio_detalle.dart';
import '../../../favoritos/favoritos.dart';
import '../widgets/negocio_content.dart';

class NegocioDetallePage extends StatelessWidget {
  final String negocioId;
  const NegocioDetallePage({super.key, required this.negocioId});

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceContainerLowest,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => context.pop(),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.storefront_outlined,
                color: AppColors.primary,
                size: 18,
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'Pinar Market',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
                fontSize: 20,
              ),
            ),
          ],
        ),
        actions: [
          BlocBuilder<NegociosFavoritosCubit, NegociosFavoritosState>(
            builder: (context, _) {
              final isFav = context
                  .read<NegociosFavoritosCubit>()
                  .isFavorito(negocioId);
              return IconButton(
                icon: Icon(
                  isFav ? Icons.favorite : Icons.favorite_border,
                  color: isFav ? AppColors.error : AppColors.primary,
                ),
                onPressed: () => context
                    .read<NegociosFavoritosCubit>()
                    .toggleFavorito(negocioId),
              );
            },
          ),
          IconButton(
            icon: const Icon(
                Icons.notifications_outlined, color: AppColors.primary),
            onPressed: () {},
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: BlocBuilder<NegocioDetalleCubit, NegocioDetalleState>(
        builder: (context, state) => switch (state) {
          NegocioDetalleInitial() || NegocioDetalleLoading() =>
            const Center(child: CircularProgressIndicator()),
          NegocioDetalleLoaded(:final negocio) =>
            NegocioContent(negocio: negocio, bottomPadding: bottom),
          NegocioDetalleError(:final message) => Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline,
                        size: 48, color: AppColors.error),
                    const SizedBox(height: 16),
                    Text(message, textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => context
                          .read<NegocioDetalleCubit>()
                          .loadNegocio(negocioId),
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
            ),
        },
      ),
    );
  }
}
