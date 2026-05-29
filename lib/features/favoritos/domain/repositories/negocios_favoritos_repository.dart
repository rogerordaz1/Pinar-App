import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/negocio_favorito.dart';

abstract class NegociosFavoritosRepository {
  Future<Either<Failure, List<NegocioFavorito>>> getNegocios();
  Future<Either<Failure, void>> addNegocio(String negocioId);
  Future<Either<Failure, void>> removeNegocio(String negocioId);
}
