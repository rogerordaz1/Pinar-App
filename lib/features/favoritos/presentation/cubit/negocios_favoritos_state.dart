import '../../domain/entities/negocio_favorito.dart';

sealed class NegociosFavoritosState {
  const NegociosFavoritosState();
}

final class NegociosFavoritosInitial extends NegociosFavoritosState {
  const NegociosFavoritosInitial();
}

final class NegociosFavoritosLoading extends NegociosFavoritosState {
  const NegociosFavoritosLoading();
}

final class NegociosFavoritosLoaded extends NegociosFavoritosState {
  final List<NegocioFavorito> negocios;
  final Set<String> negocioIds;

  const NegociosFavoritosLoaded({
    required this.negocios,
    required this.negocioIds,
  });
}

final class NegociosFavoritosError extends NegociosFavoritosState {
  final String message;
  const NegociosFavoritosError(this.message);
}
