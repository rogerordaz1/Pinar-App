import 'package:supabase_flutter/supabase_flutter.dart';
import 'negocio_detalle_datasource.dart';
import '../models/negocio_detalle_model.dart';

class SupabaseNegocioDetalleDataSource implements NegocioDetalleDataSource {
  final SupabaseClient _client;

  SupabaseNegocioDetalleDataSource(this._client);

  @override
  Future<NegocioDetalleModel> getNegocioDetalle(String id) async {
    final results = await Future.wait([
      _client.rpc('get_negocio_detalle', params: {
        'p_id': id,
        'lat': 22.4164,
        'lng': -83.6964,
      }),
      _client.rpc('get_productos_negocio', params: {'p_negocio_id': id}),
    ]);

    final negocioList =
        (results[0] as List).cast<Map<String, dynamic>>();
    if (negocioList.isEmpty) throw Exception('Negocio no encontrado');

    final productosList =
        (results[1] as List).cast<Map<String, dynamic>>();

    return NegocioDetalleModel.fromMaps(negocioList.first, productosList);
  }
}
