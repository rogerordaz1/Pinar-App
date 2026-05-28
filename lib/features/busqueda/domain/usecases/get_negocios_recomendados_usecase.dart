import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/negocio_recomendado.dart';
import '../repositories/busqueda_repository.dart';

class GetNegociosRecomendadosUseCase
    extends UseCase<List<NegocioRecomendado>, NoParams> {
  final BusquedaRepository repository;

  GetNegociosRecomendadosUseCase(this.repository);

  @override
  Future<Either<Failure, List<NegocioRecomendado>>> call(NoParams params) =>
      repository.getNegociosRecomendados();
}
