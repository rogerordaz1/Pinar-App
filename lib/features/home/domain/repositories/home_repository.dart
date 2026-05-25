import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/negocio_preview.dart';
import '../entities/categoria_negocio.dart';
import '../entities/promocion.dart';

abstract class HomeRepository {
  Future<Either<Failure, List<NegocioPreview>>> getNegociosCercanos();
  Future<Either<Failure, List<CategoriaNegocio>>> getCategorias();
  Future<Either<Failure, List<Promocion>>> getPromociones();
}
