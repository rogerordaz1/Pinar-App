import '../models/negocio_detalle_model.dart';

abstract class NegocioDetalleDataSource {
  Future<NegocioDetalleModel> getNegocioDetalle(String id);
}
