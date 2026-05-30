import '../models/negocio_favorito_model.dart';
import '../models/producto_favorito_model.dart';

abstract class FavoritosDataSource {
  Future<List<NegocioFavoritoModel>> getNegocios();
  Future<void> addNegocio(String negocioId);
  Future<void> removeNegocio(String negocioId);
  Future<List<ProductoFavoritoModel>> getProductos();
  Future<void> addProducto(String productoId, String negocioId);
  Future<void> removeProducto(String productoId);
}
