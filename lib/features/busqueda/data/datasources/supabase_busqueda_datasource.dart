import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/usecases/buscar_productos_usecase.dart';
import '../models/negocio_recomendado_model.dart';
import '../models/resultado_busqueda_model.dart';
import 'busqueda_datasource.dart';

const _lat = 22.4164;
const _lng = -83.6964;

class SupabaseBusquedaDataSource implements BusquedaDataSource {
  final SupabaseClient _client;

  SupabaseBusquedaDataSource(this._client);

  @override
  Future<List<ResultadoBusquedaModel>> buscarProductos(
      BusquedaParams params) async {
    final orden = switch (params.orden) {
      OrdenBusqueda.precio => 'precio',
      OrdenBusqueda.calificacion => 'calificacion',
      OrdenBusqueda.distancia => 'distancia',
    };

    final data = await _client.rpc('buscar_productos', params: {
      'termino': params.termino,
      'lat': _lat,
      'lng': _lng,
      'solo_abierto': params.soloAbiertos,
      'orden': orden,
    }) as List<dynamic>;

    return data
        .cast<Map<String, dynamic>>()
        .map(ResultadoBusquedaModel.fromMap)
        .toList();
  }

  @override
  Future<List<NegocioRecomendadoModel>> getNegociosRecomendados() async {
    final data = await _client.rpc('get_negocios_recomendados', params: {
      'lat': _lat,
      'lng': _lng,
    }) as List<dynamic>;

    return data
        .cast<Map<String, dynamic>>()
        .map(NegocioRecomendadoModel.fromMap)
        .toList();
  }
}
