import '../../domain/entities/negocio_favorito.dart';

class NegocioFavoritoModel {
  final String id;
  final String negocioId;
  final String negocioNombre;
  final String? logoUrl;
  final bool negocioAbierto;
  final double calificacion;
  final bool negocioVerificado;
  final DateTime createdAt;

  const NegocioFavoritoModel({
    required this.id,
    required this.negocioId,
    required this.negocioNombre,
    this.logoUrl,
    required this.negocioAbierto,
    required this.calificacion,
    required this.negocioVerificado,
    required this.createdAt,
  });

  factory NegocioFavoritoModel.fromMap(Map<String, dynamic> map) {
    final negocio = map['negocios'] as Map<String, dynamic>;
    return NegocioFavoritoModel(
      id: map['id'] as String,
      negocioId: map['negocio_id'] as String,
      negocioNombre: negocio['nombre'] as String,
      logoUrl: negocio['logo_url'] as String?,
      negocioAbierto: negocio['abierto'] as bool? ?? false,
      calificacion:
          (negocio['calificacion_cache'] as num?)?.toDouble() ?? 0.0,
      negocioVerificado: negocio['verificado'] as bool? ?? false,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  NegocioFavorito toEntity() => NegocioFavorito(
        id: id,
        negocioId: negocioId,
        negocioNombre: negocioNombre,
        logoUrl: logoUrl,
        negocioAbierto: negocioAbierto,
        calificacion: calificacion,
        negocioVerificado: negocioVerificado,
        createdAt: createdAt,
      );
}
