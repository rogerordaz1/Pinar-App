import '../../domain/entities/producto_popular.dart';

class ProductoPopularModel {
  final String id;
  final String nombre;
  final double precio;
  final String unidad;
  final String negocioNombre;
  final String negocioId;
  final bool disponible;
  final String? imagenUrl;

  const ProductoPopularModel({
    required this.id,
    required this.nombre,
    required this.precio,
    required this.unidad,
    required this.negocioNombre,
    required this.negocioId,
    this.disponible = true,
    this.imagenUrl,
  });

  factory ProductoPopularModel.fromMap(Map<String, dynamic> map) {
    return ProductoPopularModel(
      id: map['id'] as String,
      nombre: map['nombre'] as String,
      precio: (map['precio'] as num).toDouble(),
      unidad: map['unidad'] as String,
      negocioNombre: map['negocio_nombre'] as String,
      negocioId: map['negocio_id'] as String,
      disponible: map['disponible'] as bool? ?? true,
      imagenUrl: map['imagen_url'] as String?,
    );
  }

  ProductoPopular toEntity() => ProductoPopular(
        id: id,
        nombre: nombre,
        precio: precio,
        unidad: unidad,
        negocioNombre: negocioNombre,
        negocioId: negocioId,
        disponible: disponible,
        imagenUrl: imagenUrl,
      );
}
