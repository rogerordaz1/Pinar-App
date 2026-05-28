import '../../domain/entities/negocio_detalle.dart';

sealed class NegocioDetalleState {
  const NegocioDetalleState();
}

final class NegocioDetalleInitial extends NegocioDetalleState {
  const NegocioDetalleInitial();
}

final class NegocioDetalleLoading extends NegocioDetalleState {
  const NegocioDetalleLoading();
}

final class NegocioDetalleLoaded extends NegocioDetalleState {
  final NegocioDetalle negocio;
  const NegocioDetalleLoaded(this.negocio);
}

final class NegocioDetalleError extends NegocioDetalleState {
  final String message;
  const NegocioDetalleError(this.message);
}
