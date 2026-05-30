import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/productos_favoritos_cubit.dart';
import '../cubit/productos_favoritos_state.dart';
import 'favoritos_empty_state.dart';
import 'favoritos_error_state.dart';
import 'producto_favorito_card.dart';

class ProductosTab extends StatelessWidget {
  const ProductosTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductosFavoritosCubit, ProductosFavoritosState>(
      builder: (context, state) => switch (state) {
        ProductosFavoritosInitial() ||
        ProductosFavoritosLoading() =>
          const Center(child: CircularProgressIndicator()),
        ProductosFavoritosLoaded(:final productos) when productos.isEmpty =>
          const FavoritosEmptyState(
              label: 'Aún no tienes productos favoritos'),
        ProductosFavoritosLoaded(:final productos) => ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: productos.length,
            itemBuilder: (_, i) =>
                ProductoFavoritoCard(favorito: productos[i]),
          ),
        ProductosFavoritosError(:final message) => FavoritosErrorState(
            message: message,
            onRetry: () =>
                context.read<ProductosFavoritosCubit>().loadFavoritos(),
          ),
      },
    );
  }
}
