import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/negocio_favorito.dart';
import '../repositories/negocios_favoritos_repository.dart';

class GetNegociosFavoritosUseCase
    extends UseCase<List<NegocioFavorito>, NoParams> {
  final NegociosFavoritosRepository repository;

  GetNegociosFavoritosUseCase(this.repository);

  @override
  Future<Either<Failure, List<NegocioFavorito>>> call(NoParams params) =>
      repository.getNegocios();
}
