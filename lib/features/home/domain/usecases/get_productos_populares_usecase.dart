import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/producto_popular.dart';
import '../repositories/home_repository.dart';

class GetProductosPopularesUseCase
    implements UseCase<List<ProductoPopular>, NoParams> {
  final HomeRepository repository;
  GetProductosPopularesUseCase(this.repository);

  @override
  Future<Either<Failure, List<ProductoPopular>>> call(NoParams params) =>
      repository.getProductosPopulares();
}
