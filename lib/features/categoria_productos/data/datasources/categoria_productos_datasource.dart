import '../../../busqueda/data/models/resultado_busqueda_model.dart';
import '../../domain/usecases/get_productos_por_categoria_usecase.dart';

abstract class CategoriaProductosDataSource {
  Future<List<ResultadoBusquedaModel>> getProductosPorCategoria(
      CategoriaParams params);
}
