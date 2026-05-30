import '../../../busqueda/domain/entities/resultado_busqueda.dart';

sealed class CategoriaProductosState {
  const CategoriaProductosState();
}

final class CategoriaProductosInitial extends CategoriaProductosState {
  const CategoriaProductosInitial();
}

final class CategoriaProductosLoading extends CategoriaProductosState {
  const CategoriaProductosLoading();
}

final class CategoriaProductosLoaded extends CategoriaProductosState {
  final List<ResultadoBusqueda> productos;
  const CategoriaProductosLoaded(this.productos);
}

final class CategoriaProductosError extends CategoriaProductosState {
  final String message;
  const CategoriaProductosError(this.message);
}
