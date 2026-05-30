import 'package:equatable/equatable.dart';

class NegocioRecomendado extends Equatable {
  final String id;
  final String nombre;
  final String? descripcion;
  final String? logoUrl;
  final double calificacion;
  final double distanciaKm;

  const NegocioRecomendado({
    required this.id,
    required this.nombre,
    this.descripcion,
    this.logoUrl,
    required this.calificacion,
    required this.distanciaKm,
  });

  @override
  List<Object?> get props =>
      [id, nombre, descripcion, logoUrl, calificacion, distanciaKm];
}
