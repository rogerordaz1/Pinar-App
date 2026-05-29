import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/negocios_favoritos_repository.dart';

class ToggleNegocioFavoritoParams extends Equatable {
  final String negocioId;
  final bool add;

  const ToggleNegocioFavoritoParams({
    required this.negocioId,
    required this.add,
  });

  @override
  List<Object> get props => [negocioId, add];
}

class ToggleNegocioFavoritoUseCase
    extends UseCase<void, ToggleNegocioFavoritoParams> {
  final NegociosFavoritosRepository repository;

  ToggleNegocioFavoritoUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(ToggleNegocioFavoritoParams params) =>
      params.add
          ? repository.addNegocio(params.negocioId)
          : repository.removeNegocio(params.negocioId);
}
