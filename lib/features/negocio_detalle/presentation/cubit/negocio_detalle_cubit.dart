import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_negocio_detalle_usecase.dart';
import 'negocio_detalle_state.dart';

class NegocioDetalleCubit extends Cubit<NegocioDetalleState> {
  final GetNegocioDetalleUseCase _getNegocioDetalle;

  NegocioDetalleCubit({required GetNegocioDetalleUseCase getNegocioDetalleUseCase})
      : _getNegocioDetalle = getNegocioDetalleUseCase,
        super(const NegocioDetalleInitial());

  Future<void> loadNegocio(String id) async {
    emit(const NegocioDetalleLoading());
    final result = await _getNegocioDetalle(id);
    result.fold(
      (failure) => emit(NegocioDetalleError(failure.message)),
      (negocio) => emit(NegocioDetalleLoaded(negocio)),
    );
  }
}
