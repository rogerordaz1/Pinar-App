import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/resultado_busqueda.dart';
import '../repositories/busqueda_repository.dart';

enum OrdenBusqueda { distancia, precio, calificacion }

class BusquedaParams extends Equatable {
  final String termino;
  final bool soloAbiertos;
  final OrdenBusqueda orden;

  const BusquedaParams({
    required this.termino,
    this.soloAbiertos = false,
    this.orden = OrdenBusqueda.distancia,
  });

  @override
  List<Object?> get props => [termino, soloAbiertos, orden];
}

class BuscarProductosUseCase
    extends UseCase<List<ResultadoBusqueda>, BusquedaParams> {
  final BusquedaRepository repository;

  BuscarProductosUseCase(this.repository);

  @override
  Future<Either<Failure, List<ResultadoBusqueda>>> call(BusquedaParams params) =>
      repository.buscarProductos(params);
}
