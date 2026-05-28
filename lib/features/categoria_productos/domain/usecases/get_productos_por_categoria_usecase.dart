import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../busqueda/domain/entities/resultado_busqueda.dart';
import '../repositories/categoria_productos_repository.dart';

class CategoriaParams extends Equatable {
  final String categoriaId;
  final String categoriaNombre;

  const CategoriaParams({
    required this.categoriaId,
    required this.categoriaNombre,
  });

  @override
  List<Object?> get props => [categoriaId, categoriaNombre];
}

class GetProductosPorCategoriaUseCase
    extends UseCase<List<ResultadoBusqueda>, CategoriaParams> {
  final CategoriaProductosRepository repository;

  GetProductosPorCategoriaUseCase(this.repository);

  @override
  Future<Either<Failure, List<ResultadoBusqueda>>> call(
          CategoriaParams params) =>
      repository.getProductosPorCategoria(params);
}
