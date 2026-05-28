import 'package:equatable/equatable.dart';

class ResultadoBusqueda extends Equatable {
  final String negocioId;
  final String negocioNombre;
  final String negocioDireccion;
  final bool negocioAbierto;
  final bool negocioVerificado;
  final String? logoUrl;
  final String productoId;
  final String productoNombre;
  final double precio;
  final bool disponible;
  final String actualizadoHace;
  final double distanciaMetros;
  final double calificacion;

  const ResultadoBusqueda({
    required this.negocioId,
    required this.negocioNombre,
    required this.negocioDireccion,
    required this.negocioAbierto,
    required this.negocioVerificado,
    this.logoUrl,
    required this.productoId,
    required this.productoNombre,
    required this.precio,
    required this.disponible,
    required this.actualizadoHace,
    required this.distanciaMetros,
    required this.calificacion,
  });

  @override
  List<Object?> get props => [
        negocioId,
        negocioNombre,
        negocioDireccion,
        negocioAbierto,
        negocioVerificado,
        logoUrl,
        productoId,
        productoNombre,
        precio,
        disponible,
        actualizadoHace,
        distanciaMetros,
        calificacion,
      ];
}
