import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/negocio_favorito_model.dart';
import '../models/producto_favorito_model.dart';
import 'favoritos_datasource.dart';

class SupabaseFavoritosDataSource implements FavoritosDataSource {
  final SupabaseClient _client;

  SupabaseFavoritosDataSource(this._client);

  @override
  Future<List<NegocioFavoritoModel>> getNegocios() async {
    final data = await _client
        .from('negocios_favoritos')
        .select('*, negocios(nombre, logo_url, abierto, calificacion_cache, verificado)')
        .order('created_at', ascending: false) as List<dynamic>;
    return data
        .cast<Map<String, dynamic>>()
        .map(NegocioFavoritoModel.fromMap)
        .toList();
  }

  @override
  Future<void> addNegocio(String negocioId) async {
    final userId = _client.auth.currentUser!.id;
    await _client.from('negocios_favoritos').insert({
      'user_id': userId,
      'negocio_id': negocioId,
    });
  }

  @override
  Future<void> removeNegocio(String negocioId) async {
    await _client
        .from('negocios_favoritos')
        .delete()
        .eq('negocio_id', negocioId);
  }

  @override
  Future<List<ProductoFavoritoModel>> getProductos() async {
    final data = await _client
        .from('productos_favoritos')
        .select('*, productos(nombre, precio, imagen_url, negocios(nombre, abierto))')
        .order('created_at', ascending: false) as List<dynamic>;
    return data
        .cast<Map<String, dynamic>>()
        .map(ProductoFavoritoModel.fromMap)
        .toList();
  }

  @override
  Future<void> addProducto(String productoId, String negocioId) async {
    final userId = _client.auth.currentUser!.id;
    await _client.from('productos_favoritos').insert({
      'user_id': userId,
      'producto_id': productoId,
      'negocio_id': negocioId,
    });
  }

  @override
  Future<void> removeProducto(String productoId) async {
    await _client
        .from('productos_favoritos')
        .delete()
        .eq('producto_id', productoId);
  }
}
