import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/negocio_detalle.dart';

abstract class NegocioDetalleRepository {
  Future<Either<Failure, NegocioDetalle>> getNegocioDetalle(String id);
}
