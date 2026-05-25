import '../../domain/entities/producto_popular.dart';

class ProductoPopularModel {
  final String id;
  final String nombre;
  final double precio;
  final String unidad;
  final String negocioNombre;
  final String negocioId;
  final bool disponible;

  const ProductoPopularModel({
    required this.id,
    required this.nombre,
    required this.precio,
    required this.unidad,
    required this.negocioNombre,
    required this.negocioId,
    this.disponible = true,
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
      );
}
