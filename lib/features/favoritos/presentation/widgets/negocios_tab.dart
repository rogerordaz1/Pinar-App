import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/negocios_favoritos_cubit.dart';
import '../cubit/negocios_favoritos_state.dart';
import 'favoritos_empty_state.dart';
import 'favoritos_error_state.dart';
import 'negocio_favorito_card.dart';

class NegociosTab extends StatelessWidget {
  const NegociosTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NegociosFavoritosCubit, NegociosFavoritosState>(
      builder: (context, state) => switch (state) {
        NegociosFavoritosInitial() ||
        NegociosFavoritosLoading() =>
          const Center(child: CircularProgressIndicator()),
        NegociosFavoritosLoaded(:final negocios) when negocios.isEmpty =>
          const FavoritosEmptyState(label: 'Aún no tienes negocios favoritos'),
        NegociosFavoritosLoaded(:final negocios) => ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: negocios.length,
            itemBuilder: (_, i) => NegocioFavoritoCard(favorito: negocios[i]),
          ),
        NegociosFavoritosError(:final message) => FavoritosErrorState(
            message: message,
            onRetry: () =>
                context.read<NegociosFavoritosCubit>().loadFavoritos(),
          ),
      },
    );
  }
}
