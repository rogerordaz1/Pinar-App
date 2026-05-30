import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/producto_favorito.dart';

abstract class ProductosFavoritosRepository {
  Future<Either<Failure, List<ProductoFavorito>>> getProductos();
  Future<Either<Failure, void>> addProducto(String productoId, String negocioId);
  Future<Either<Failure, void>> removeProducto(String productoId);
}
