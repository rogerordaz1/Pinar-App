import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/categoria_negocio.dart';
import '../../domain/entities/negocio_preview.dart';
import '../../domain/entities/promocion.dart';
import '../../domain/usecases/get_categorias_usecase.dart';
import '../../domain/usecases/get_negocios_cercanos_usecase.dart';
import '../../domain/usecases/get_promociones_usecase.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final GetNegociosCercanosUseCase getNegociosCercanosUseCase;
  final GetCategoriasUseCase getCategoriasUseCase;
  final GetPromocionesUseCase getPromocionesUseCase;

  HomeCubit({
    required this.getNegociosCercanosUseCase,
    required this.getCategoriasUseCase,
    required this.getPromocionesUseCase,
  }) : super(const HomeInitial());

  Future<void> loadHome() async {
    emit(const HomeLoading());

    final results = await Future.wait([
      getNegociosCercanosUseCase(const NoParams()),
      getCategoriasUseCase(const NoParams()),
      getPromocionesUseCase(const NoParams()),
    ]);

    final negociosEither =
        results[0] as Either<Failure, List<NegocioPreview>>;
    final categoriasEither =
        results[1] as Either<Failure, List<CategoriaNegocio>>;
    final promocionesEither =
        results[2] as Either<Failure, List<Promocion>>;

    String? errorMessage;
    negociosEither.fold((f) => errorMessage = f.message, (_) {});
    categoriasEither.fold((f) => errorMessage ??= f.message, (_) {});
    promocionesEither.fold((f) => errorMessage ??= f.message, (_) {});

    if (errorMessage != null) {
      emit(HomeError(errorMessage!));
      return;
    }

    emit(HomeLoaded(
      negocios: negociosEither.getOrElse(() => []),
      categorias: categoriasEither.getOrElse(() => []),
      promociones: promocionesEither.getOrElse(() => []),
    ));
  }
}
