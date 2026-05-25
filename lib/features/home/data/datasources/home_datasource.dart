import '../models/negocio_preview_model.dart';
import '../models/categoria_negocio_model.dart';
import '../models/promocion_model.dart';
import '../models/producto_popular_model.dart';

abstract class HomeDataSource {
  Future<List<NegocioPreviewModel>> getNegociosCercanos();
  Future<List<CategoriaNegocioModel>> getCategorias();
  Future<List<PromocionModel>> getPromociones();
  Future<List<ProductoPopularModel>> getProductosPopulares();
}
