// lib/features/favoritos/data/repositories/negocios_favoritos_repository_impl.dart
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/negocio_favorito.dart';
import '../../domain/repositories/negocios_favoritos_repository.dart';
import '../datasources/favoritos_datasource.dart';

class NegociosFavoritosRepositoryImpl implements NegociosFavoritosRepository {
  final FavoritosDataSource _dataSource;

  NegociosFavoritosRepositoryImpl(this._dataSource);

  @override
  Future<Either<Failure, List<NegocioFavorito>>> getNegocios() async {
    try {
      final models = await _dataSource.getNegocios();
      return Right(models.map((m) => m.toEntity()).toList());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> addNegocio(String negocioId) async {
    try {
      await _dataSource.addNegocio(negocioId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> removeNegocio(String negocioId) async {
    try {
      await _dataSource.removeNegocio(negocioId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
