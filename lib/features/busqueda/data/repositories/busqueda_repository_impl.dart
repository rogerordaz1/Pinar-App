import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/negocio_recomendado.dart';
import '../../domain/entities/resultado_busqueda.dart';
import '../../domain/repositories/busqueda_repository.dart';
import '../../domain/usecases/buscar_productos_usecase.dart';
import '../datasources/busqueda_datasource.dart';

class BusquedaRepositoryImpl implements BusquedaRepository {
  final BusquedaDataSource _dataSource;

  BusquedaRepositoryImpl(this._dataSource);

  @override
  Future<Either<Failure, List<ResultadoBusqueda>>> buscarProductos(
      BusquedaParams params) async {
    try {
      final models = await _dataSource.buscarProductos(params);
      return Right(models.map((m) => m.toEntity()).toList());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<NegocioRecomendado>>>
      getNegociosRecomendados() async {
    try {
      final models = await _dataSource.getNegociosRecomendados();
      return Right(models.map((m) => m.toEntity()).toList());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
