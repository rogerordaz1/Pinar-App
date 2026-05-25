import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/negocio_preview.dart';
import '../../domain/entities/categoria_negocio.dart';
import '../../domain/entities/promocion.dart';
import '../../domain/repositories/home_repository.dart';
import '../datasources/home_datasource.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeDataSource dataSource;

  HomeRepositoryImpl(this.dataSource);

  @override
  Future<Either<Failure, List<NegocioPreview>>> getNegociosCercanos() async {
    try {
      final models = await dataSource.getNegociosCercanos();
      return Right(models.map((m) => m.toEntity()).toList());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<CategoriaNegocio>>> getCategorias() async {
    try {
      final models = await dataSource.getCategorias();
      return Right(models.map((m) => m.toEntity()).toList());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Promocion>>> getPromociones() async {
    try {
      final models = await dataSource.getPromociones();
      return Right(models.map((m) => m.toEntity()).toList());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
