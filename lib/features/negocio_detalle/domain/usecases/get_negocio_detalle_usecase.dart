import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/negocio_detalle.dart';
import '../repositories/negocio_detalle_repository.dart';

class GetNegocioDetalleUseCase extends UseCase<NegocioDetalle, String> {
  final NegocioDetalleRepository repository;

  GetNegocioDetalleUseCase(this.repository);

  @override
  Future<Either<Failure, NegocioDetalle>> call(String id) =>
      repository.getNegocioDetalle(id);
}
