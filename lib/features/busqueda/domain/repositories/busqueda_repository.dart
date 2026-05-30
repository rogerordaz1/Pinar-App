import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/negocio_recomendado.dart';
import '../entities/resultado_busqueda.dart';
import '../usecases/buscar_productos_usecase.dart';

abstract class BusquedaRepository {
  Future<Either<Failure, List<ResultadoBusqueda>>> buscarProductos(
      BusquedaParams params);

  Future<Either<Failure, List<NegocioRecomendado>>> getNegociosRecomendados();
}
