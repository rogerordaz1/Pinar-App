import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/buscar_productos_usecase.dart';
import '../../domain/usecases/get_negocios_recomendados_usecase.dart';
import 'busqueda_state.dart';

class BusquedaCubit extends Cubit<BusquedaState> {
  final BuscarProductosUseCase _buscarProductos;
  final GetNegociosRecomendadosUseCase _getRecomendados;
  Timer? _debounce;

  BusquedaCubit({
    required BuscarProductosUseCase buscarProductosUseCase,
    required GetNegociosRecomendadosUseCase getRecomendadosUseCase,
  })  : _buscarProductos = buscarProductosUseCase,
        _getRecomendados = getRecomendadosUseCase,
        super(BusquedaState.initial());

  Future<void> init() async {
    emit(state.copyWith(status: BusquedaStatus.loadingRecomendados));
    final result = await _getRecomendados(const NoParams());
    result.fold(
      (_) => emit(state.copyWith(status: BusquedaStatus.idle)),
      (recomendados) => emit(
        state.copyWith(
            status: BusquedaStatus.idle, recomendados: recomendados),
      ),
    );
  }

  void onTerminoChanged(String termino) {
    _debounce?.cancel();
    if (termino.isEmpty) {
      emit(state.copyWith(
          termino: termino,
          status: BusquedaStatus.idle,
          resultados: []));
      return;
    }
    emit(state.copyWith(termino: termino, status: BusquedaStatus.loading));
    _debounce =
        Timer(const Duration(milliseconds: 400), () => _buscar());
  }

  void setOrden(OrdenBusqueda orden) {
    if (state.orden == orden) return;
    emit(state.copyWith(orden: orden));
    if (state.termino.isNotEmpty) _buscar();
  }

  void toggleSoloAbiertos() {
    emit(state.copyWith(soloAbiertos: !state.soloAbiertos));
    if (state.termino.isNotEmpty) _buscar();
  }

  Future<void> _buscar() async {
    emit(state.copyWith(status: BusquedaStatus.loading));
    final params = BusquedaParams(
      termino: state.termino,
      soloAbiertos: state.soloAbiertos,
      orden: state.orden,
    );
    final result = await _buscarProductos(params);
    if (isClosed) return;
    result.fold(
      (failure) => emit(state.copyWith(
          status: BusquedaStatus.error, errorMessage: failure.message)),
      (resultados) => emit(
        state.copyWith(status: BusquedaStatus.loaded, resultados: resultados),
      ),
    );
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }
}
