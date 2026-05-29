import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/get_productos_favoritos_usecase.dart';
import '../../domain/usecases/toggle_producto_favorito_usecase.dart';
import 'productos_favoritos_state.dart';

class ProductosFavoritosCubit extends Cubit<ProductosFavoritosState> {
  final GetProductosFavoritosUseCase _get;
  final ToggleProductoFavoritoUseCase _toggle;

  ProductosFavoritosCubit({
    required GetProductosFavoritosUseCase getProductosFavoritosUseCase,
    required ToggleProductoFavoritoUseCase toggleProductoFavoritoUseCase,
  })  : _get = getProductosFavoritosUseCase,
        _toggle = toggleProductoFavoritoUseCase,
        super(const ProductosFavoritosInitial());

  Future<void> loadFavoritos() async {
    emit(const ProductosFavoritosLoading());
    final result = await _get(const NoParams());
    if (isClosed) return;
    result.fold(
      (failure) => emit(ProductosFavoritosError(failure.message)),
      (productos) => emit(ProductosFavoritosLoaded(
        productos: productos,
        productoIds: productos.map((p) => p.productoId).toSet(),
      )),
    );
  }

  Future<void> toggleFavorito(String productoId, String negocioId) async {
    final current = state;
    if (current is! ProductosFavoritosLoaded) return;

    final isAdding = !current.productoIds.contains(productoId);
    final optimisticIds = Set<String>.from(current.productoIds);
    if (isAdding) {
      optimisticIds.add(productoId);
    } else {
      optimisticIds.remove(productoId);
    }
    final optimisticProductos = isAdding
        ? current.productos
        : current.productos
            .where((p) => p.productoId != productoId)
            .toList();
    emit(ProductosFavoritosLoaded(
        productos: optimisticProductos, productoIds: optimisticIds));

    final result = await _toggle(ToggleProductoFavoritoParams(
      productoId: productoId,
      negocioId: negocioId,
      add: isAdding,
    ));
    if (isClosed) return;
    result.fold(
      (_) => emit(current),
      (_) => loadFavoritos(),
    );
  }

  bool isFavorito(String productoId) {
    final s = state;
    return s is ProductosFavoritosLoaded && s.productoIds.contains(productoId);
  }
}
