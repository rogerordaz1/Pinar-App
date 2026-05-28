import 'package:supabase_flutter/supabase_flutter.dart';
import 'home_datasource.dart';
import '../models/negocio_preview_model.dart';
import '../models/categoria_negocio_model.dart';
import '../models/promocion_model.dart';
import '../models/producto_popular_model.dart';

class SupabaseHomeDataSource implements HomeDataSource {
  final SupabaseClient _client;

  SupabaseHomeDataSource(this._client);

  @override
  Future<List<NegocioPreviewModel>> getNegociosCercanos() async {
    final data = await _client.rpc('get_negocios_home', params: {
      'lat': 22.4164,
      'lng': -83.6964,
    }) as List<dynamic>;
    return data
        .cast<Map<String, dynamic>>()
        .map(NegocioPreviewModel.fromMap)
        .toList();
  }

  @override
  Future<List<CategoriaNegocioModel>> getCategorias() async {
    final data = await _client
        .from('categorias_negocio')
        .select('id, nombre, icono')
        .limit(12) as List<dynamic>;
    return data
        .cast<Map<String, dynamic>>()
        .map(CategoriaNegocioModel.fromMap)
        .toList();
  }

  @override
  Future<List<PromocionModel>> getPromociones() async {
    final data =
        await _client.rpc('get_promociones_home') as List<dynamic>;
    return data
        .cast<Map<String, dynamic>>()
        .map(PromocionModel.fromMap)
        .toList();
  }

  @override
  Future<List<ProductoPopularModel>> getProductosPopulares() async {
    final data =
        await _client.rpc('get_productos_populares') as List<dynamic>;
    return data
        .cast<Map<String, dynamic>>()
        .map(ProductoPopularModel.fromMap)
        .toList();
  }
}
