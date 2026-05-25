import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/categoria_negocio.dart';
import '../repositories/home_repository.dart';

class GetCategoriasUseCase extends UseCase<List<CategoriaNegocio>, NoParams> {
  final HomeRepository repository;
  GetCategoriasUseCase(this.repository);

  @override
  Future<Either<Failure, List<CategoriaNegocio>>> call(NoParams params) =>
      repository.getCategorias();
}
