import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/productos_favoritos_repository.dart';

class ToggleProductoFavoritoParams extends Equatable {
  final String productoId;
  final String negocioId;
  final bool add;

  const ToggleProductoFavoritoParams({
    required this.productoId,
    required this.negocioId,
    required this.add,
  });

  @override
  List<Object> get props => [productoId, negocioId, add];
}

class ToggleProductoFavoritoUseCase
    extends UseCase<void, ToggleProductoFavoritoParams> {
  final ProductosFavoritosRepository repository;

  ToggleProductoFavoritoUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(ToggleProductoFavoritoParams params) =>
      params.add
          ? repository.addProducto(params.productoId, params.negocioId)
          : repository.removeProducto(params.productoId);
}
