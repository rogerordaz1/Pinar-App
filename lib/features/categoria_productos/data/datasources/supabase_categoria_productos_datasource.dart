import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../busqueda/data/models/resultado_busqueda_model.dart';
import '../../domain/usecases/get_productos_por_categoria_usecase.dart';
import 'categoria_productos_datasource.dart';

const _lat = 22.4164;
const _lng = -83.6964;

class SupabaseCategoriaProductosDataSource
    implements CategoriaProductosDataSource {
  final SupabaseClient _client;

  SupabaseCategoriaProductosDataSource(this._client);

  @override
  Future<List<ResultadoBusquedaModel>> getProductosPorCategoria(
      CategoriaParams params) async {
    final data = await _client.rpc('get_productos_por_categoria', params: {
      'p_categoria_id': params.categoriaId,
      'lat': _lat,
      'lng': _lng,
    }) as List<dynamic>;

    return data
        .cast<Map<String, dynamic>>()
        .map(ResultadoBusquedaModel.fromMap)
        .toList();
  }
}
