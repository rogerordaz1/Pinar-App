import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/negocio_detalle.dart';
import '../../domain/repositories/negocio_detalle_repository.dart';
import '../datasources/negocio_detalle_datasource.dart';

class NegocioDetalleRepositoryImpl implements NegocioDetalleRepository {
  final NegocioDetalleDataSource dataSource;

  NegocioDetalleRepositoryImpl(this.dataSource);

  @override
  Future<Either<Failure, NegocioDetalle>> getNegocioDetalle(String id) async {
    try {
      final model = await dataSource.getNegocioDetalle(id);
      return Right(model.toEntity());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
