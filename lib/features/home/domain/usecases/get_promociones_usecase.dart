import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/promocion.dart';
import '../repositories/home_repository.dart';

class GetPromocionesUseCase extends UseCase<List<Promocion>, NoParams> {
  final HomeRepository repository;
  GetPromocionesUseCase(this.repository);

  @override
  Future<Either<Failure, List<Promocion>>> call(NoParams params) =>
      repository.getPromociones();
}
