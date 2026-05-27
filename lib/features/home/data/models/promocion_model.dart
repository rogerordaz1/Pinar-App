import '../../domain/entities/promocion.dart';

class PromocionModel {
  final String id;
  final String titulo;
  final String nombreNegocio;
  final String negocioId;
  final String? imagenUrl;

  const PromocionModel({
    required this.id,
    required this.titulo,
    required this.nombreNegocio,
    required this.negocioId,
    this.imagenUrl,
  });

  factory PromocionModel.fromMap(Map<String, dynamic> map) {
    return PromocionModel(
      id: map['id'] as String,
      titulo: map['titulo'] as String,
      nombreNegocio: map['nombre_negocio'] as String,
      negocioId: map['negocio_id'] as String,
      imagenUrl: map['imagen_url'] as String?,
    );
  }

  Promocion toEntity() => Promocion(
        id: id,
        titulo: titulo,
        nombreNegocio: nombreNegocio,
        negocioId: negocioId,
        imagenUrl: imagenUrl,
      );
}
