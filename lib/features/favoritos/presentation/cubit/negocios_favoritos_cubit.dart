import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/get_negocios_favoritos_usecase.dart';
import '../../domain/usecases/toggle_negocio_favorito_usecase.dart';
import 'negocios_favoritos_state.dart';

class NegociosFavoritosCubit extends Cubit<NegociosFavoritosState> {
  final GetNegociosFavoritosUseCase _get;
  final ToggleNegocioFavoritoUseCase _toggle;

  NegociosFavoritosCubit({
    required GetNegociosFavoritosUseCase getNegociosFavoritosUseCase,
    required ToggleNegocioFavoritoUseCase toggleNegocioFavoritoUseCase,
  })  : _get = getNegociosFavoritosUseCase,
        _toggle = toggleNegocioFavoritoUseCase,
        super(const NegociosFavoritosInitial());

  Future<void> loadFavoritos() async {
    emit(const NegociosFavoritosLoading());
    final result = await _get(const NoParams());
    if (isClosed) return;
    result.fold(
      (failure) => emit(NegociosFavoritosError(failure.message)),
      (negocios) => emit(NegociosFavoritosLoaded(
        negocios: negocios,
        negocioIds: negocios.map((n) => n.negocioId).toSet(),
      )),
    );
  }

  Future<void> toggleFavorito(String negocioId) async {
    final current = state;
    if (current is! NegociosFavoritosLoaded) return;

    final isAdding = !current.negocioIds.contains(negocioId);
    final optimisticIds = Set<String>.from(current.negocioIds);
    if (isAdding) {
      optimisticIds.add(negocioId);
    } else {
      optimisticIds.remove(negocioId);
    }
    final optimisticNegocios = isAdding
        ? current.negocios
        : current.negocios.where((n) => n.negocioId != negocioId).toList();
    emit(NegociosFavoritosLoaded(
        negocios: optimisticNegocios, negocioIds: optimisticIds));

    final result = await _toggle(ToggleNegocioFavoritoParams(
      negocioId: negocioId,
      add: isAdding,
    ));
    if (isClosed) return;
    result.fold(
      (_) => emit(current),
      (_) => loadFavoritos(),
    );
  }

  bool isFavorito(String negocioId) {
    final s = state;
    return s is NegociosFavoritosLoaded && s.negocioIds.contains(negocioId);
  }
}
