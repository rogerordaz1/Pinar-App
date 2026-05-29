import '../../domain/entities/producto_favorito.dart';

sealed class ProductosFavoritosState {
  const ProductosFavoritosState();
}

final class ProductosFavoritosInitial extends ProductosFavoritosState {
  const ProductosFavoritosInitial();
}

final class ProductosFavoritosLoading extends ProductosFavoritosState {
  const ProductosFavoritosLoading();
}

final class ProductosFavoritosLoaded extends ProductosFavoritosState {
  final List<ProductoFavorito> productos;
  final Set<String> productoIds;

  const ProductosFavoritosLoaded({
    required this.productos,
    required this.productoIds,
  });
}

final class ProductosFavoritosError extends ProductosFavoritosState {
  final String message;
  const ProductosFavoritosError(this.message);
}
