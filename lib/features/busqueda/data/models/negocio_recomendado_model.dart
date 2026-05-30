import '../../domain/entities/negocio_recomendado.dart';

class NegocioRecomendadoModel {
  final String id;
  final String nombre;
  final String? descripcion;
  final String? logoUrl;
  final double calificacion;
  final double distanciaKm;

  const NegocioRecomendadoModel({
    required this.id,
    required this.nombre,
    this.descripcion,
    this.logoUrl,
    required this.calificacion,
    required this.distanciaKm,
  });

  factory NegocioRecomendadoModel.fromMap(Map<String, dynamic> map) {
    return NegocioRecomendadoModel(
      id: map['id'] as String,
      nombre: map['nombre'] as String,
      descripcion: map['descripcion'] as String?,
      logoUrl: map['logo_url'] as String?,
      calificacion: (map['calificacion'] as num?)?.toDouble() ?? 0.0,
      distanciaKm: (map['distancia_km'] as num).toDouble(),
    );
  }

  NegocioRecomendado toEntity() => NegocioRecomendado(
        id: id,
        nombre: nombre,
        descripcion: descripcion,
        logoUrl: logoUrl,
        calificacion: calificacion,
        distanciaKm: distanciaKm,
      );
}
