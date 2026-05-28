import 'package:equatable/equatable.dart';
import '../../domain/entities/negocio_recomendado.dart';
import '../../domain/entities/resultado_busqueda.dart';
import '../../domain/usecases/buscar_productos_usecase.dart';

enum BusquedaStatus { idle, loadingRecomendados, loading, loaded, error }

class BusquedaState extends Equatable {
  final BusquedaStatus status;
  final String termino;
  final List<ResultadoBusqueda> resultados;
  final List<NegocioRecomendado> recomendados;
  final OrdenBusqueda orden;
  final bool soloAbiertos;
  final String? errorMessage;

  const BusquedaState({
    required this.status,
    required this.termino,
    required this.resultados,
    required this.recomendados,
    required this.orden,
    required this.soloAbiertos,
    this.errorMessage,
  });

  factory BusquedaState.initial() => const BusquedaState(
        status: BusquedaStatus.idle,
        termino: '',
        resultados: [],
        recomendados: [],
        orden: OrdenBusqueda.distancia,
        soloAbiertos: false,
      );

  BusquedaState copyWith({
    BusquedaStatus? status,
    String? termino,
    List<ResultadoBusqueda>? resultados,
    List<NegocioRecomendado>? recomendados,
    OrdenBusqueda? orden,
    bool? soloAbiertos,
    String? errorMessage,
  }) {
    return BusquedaState(
      status: status ?? this.status,
      termino: termino ?? this.termino,
      resultados: resultados ?? this.resultados,
      recomendados: recomendados ?? this.recomendados,
      orden: orden ?? this.orden,
      soloAbiertos: soloAbiertos ?? this.soloAbiertos,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        termino,
        resultados,
        recomendados,
        orden,
        soloAbiertos,
        errorMessage,
      ];
}
