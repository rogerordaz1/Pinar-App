import '../../domain/entities/negocio_preview.dart';

class NegocioPreviewModel {
  final String id;
  final String nombre;
  final String categoria;
  final double distanciaKm;
  final bool abierto;
  final String? logoUrl;
  final bool verificado;
  final double calificacion;

  const NegocioPreviewModel({
    required this.id,
    required this.nombre,
    required this.categoria,
    required this.distanciaKm,
    required this.abierto,
    this.logoUrl,
    this.verificado = false,
    this.calificacion = 0.0,
  });

  factory NegocioPreviewModel.fromMap(Map<String, dynamic> map) {
    return NegocioPreviewModel(
      id: map['id'] as String,
      nombre: map['nombre'] as String,
      categoria: map['categoria'] as String,
      distanciaKm: (map['distancia_km'] as num).toDouble(),
      abierto: map['abierto'] as bool,
      logoUrl: map['logo_url'] as String?,
      verificado: map['verificado'] as bool? ?? false,
      calificacion: (map['calificacion'] as num?)?.toDouble() ?? 0.0,
    );
  }

  NegocioPreview toEntity() => NegocioPreview(
        id: id,
        nombre: nombre,
        categoria: categoria,
        distanciaKm: distanciaKm,
        abierto: abierto,
        logoUrl: logoUrl,
        verificado: verificado,
        calificacion: calificacion,
      );
}
