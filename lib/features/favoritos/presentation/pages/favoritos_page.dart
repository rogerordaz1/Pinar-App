import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/core.dart';
import '../cubit/negocios_favoritos_cubit.dart';
import '../cubit/negocios_favoritos_state.dart';
import '../cubit/productos_favoritos_cubit.dart';
import '../cubit/productos_favoritos_state.dart';
import '../widgets/negocio_favorito_card.dart';
import '../widgets/producto_favorito_card.dart';

class FavoritosPage extends StatelessWidget {
  final int initialTabIndex;

  const FavoritosPage({super.key, this.initialTabIndex = 0});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      initialIndex: initialTabIndex,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.surfaceContainerLowest,
          elevation: 0,
          scrolledUnderElevation: 0,
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
          bottom: const TabBar(
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.outline,
            indicatorColor: AppColors.primary,
            tabs: [
              Tab(text: 'Negocios'),
              Tab(text: 'Productos'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _NegociosTab(),
            _ProductosTab(),
          ],
        ),
      ),
    );
  }
}

class _NegociosTab extends StatelessWidget {
  const _NegociosTab();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NegociosFavoritosCubit, NegociosFavoritosState>(
      builder: (context, state) => switch (state) {
        NegociosFavoritosInitial() ||
        NegociosFavoritosLoading() =>
          const Center(child: CircularProgressIndicator()),
        NegociosFavoritosLoaded(:final negocios) when negocios.isEmpty =>
          const _EmptyState(label: 'Aún no tienes negocios favoritos'),
        NegociosFavoritosLoaded(:final negocios) => ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: negocios.length,
            itemBuilder: (_, i) =>
                NegocioFavoritoCard(favorito: negocios[i]),
          ),
        NegociosFavoritosError(:final message) => _ErrorState(
            message: message,
            onRetry: () =>
                context.read<NegociosFavoritosCubit>().loadFavoritos(),
          ),
      },
    );
  }
}

class _ProductosTab extends StatelessWidget {
  const _ProductosTab();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductosFavoritosCubit, ProductosFavoritosState>(
      builder: (context, state) => switch (state) {
        ProductosFavoritosInitial() ||
        ProductosFavoritosLoading() =>
          const Center(child: CircularProgressIndicator()),
        ProductosFavoritosLoaded(:final productos) when productos.isEmpty =>
          const _EmptyState(label: 'Aún no tienes productos favoritos'),
        ProductosFavoritosLoaded(:final productos) => ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: productos.length,
            itemBuilder: (_, i) =>
                ProductoFavoritoCard(favorito: productos[i]),
          ),
        ProductosFavoritosError(:final message) => _ErrorState(
            message: message,
            onRetry: () =>
                context.read<ProductosFavoritosCubit>().loadFavoritos(),
          ),
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String label;
  const _EmptyState({required this.label});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.favorite_border, size: 64, color: AppColors.outline),
          const SizedBox(height: 16),
          Text(label,
              style: AppTextStyles.body
                  .copyWith(color: AppColors.onSurfaceVariant)),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message,
              style:
                  AppTextStyles.body.copyWith(color: AppColors.error)),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: onRetry, child: const Text('Reintentar')),
        ],
      ),
    );
  }
}
