import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../busqueda/domain/entities/resultado_busqueda.dart';
import '../usecases/get_productos_por_categoria_usecase.dart';

abstract class CategoriaProductosRepository {
  Future<Either<Failure, List<ResultadoBusqueda>>> getProductosPorCategoria(
      CategoriaParams params);
}
