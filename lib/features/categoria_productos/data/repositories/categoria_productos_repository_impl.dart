import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../busqueda/domain/entities/resultado_busqueda.dart';
import '../../domain/repositories/categoria_productos_repository.dart';
import '../../domain/usecases/get_productos_por_categoria_usecase.dart';
import '../datasources/categoria_productos_datasource.dart';

class CategoriaProductosRepositoryImpl
    implements CategoriaProductosRepository {
  final CategoriaProductosDataSource _dataSource;

  CategoriaProductosRepositoryImpl(this._dataSource);

  @override
  Future<Either<Failure, List<ResultadoBusqueda>>> getProductosPorCategoria(
      CategoriaParams params) async {
    try {
      final models = await _dataSource.getProductosPorCategoria(params);
      return Right(models.map((m) => m.toEntity()).toList());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
