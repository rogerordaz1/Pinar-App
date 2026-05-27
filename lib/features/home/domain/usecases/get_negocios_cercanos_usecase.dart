import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/negocio_preview.dart';
import '../repositories/home_repository.dart';

class GetNegociosCercanosUseCase
    extends UseCase<List<NegocioPreview>, NoParams> {
  final HomeRepository repository;
  GetNegociosCercanosUseCase(this.repository);

  @override
  Future<Either<Failure, List<NegocioPreview>>> call(NoParams params) =>
      repository.getNegociosCercanos();
}
