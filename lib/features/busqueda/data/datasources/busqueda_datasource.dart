import '../models/negocio_recomendado_model.dart';
import '../models/resultado_busqueda_model.dart';
import '../../domain/usecases/buscar_productos_usecase.dart';

abstract class BusquedaDataSource {
  Future<List<ResultadoBusquedaModel>> buscarProductos(BusquedaParams params);
  Future<List<NegocioRecomendadoModel>> getNegociosRecomendados();
}
