// lib/features/favoritos/data/repositories/productos_favoritos_repository_impl.dart
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/producto_favorito.dart';
import '../../domain/repositories/productos_favoritos_repository.dart';
import '../datasources/favoritos_datasource.dart';

class ProductosFavoritosRepositoryImpl implements ProductosFavoritosRepository {
  final FavoritosDataSource _dataSource;

  ProductosFavoritosRepositoryImpl(this._dataSource);

  @override
  Future<Either<Failure, List<ProductoFavorito>>> getProductos() async {
    try {
      final models = await _dataSource.getProductos();
      return Right(models.map((m) => m.toEntity()).toList());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> addProducto(
      String productoId, String negocioId) async {
    try {
      await _dataSource.addProducto(productoId, negocioId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> removeProducto(String productoId) async {
    try {
      await _dataSource.removeProducto(productoId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
