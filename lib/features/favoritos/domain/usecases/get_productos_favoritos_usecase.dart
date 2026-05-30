import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/producto_favorito.dart';
import '../repositories/productos_favoritos_repository.dart';

class GetProductosFavoritosUseCase
    extends UseCase<List<ProductoFavorito>, NoParams> {
  final ProductosFavoritosRepository repository;

  GetProductosFavoritosUseCase(this.repository);

  @override
  Future<Either<Failure, List<ProductoFavorito>>> call(NoParams params) =>
      repository.getProductos();
}
