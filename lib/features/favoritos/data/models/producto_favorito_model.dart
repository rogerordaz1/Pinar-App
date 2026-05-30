import '../../domain/entities/producto_favorito.dart';

class ProductoFavoritoModel {
  final String id;
  final String productoId;
  final String productoNombre;
  final String negocioId;
  final String negocioNombre;
  final double precio;
  final String? imageUrl;
  final bool negocioAbierto;
  final DateTime createdAt;

  const ProductoFavoritoModel({
    required this.id,
    required this.productoId,
    required this.productoNombre,
    required this.negocioId,
    required this.negocioNombre,
    required this.precio,
    this.imageUrl,
    required this.negocioAbierto,
    required this.createdAt,
  });

  factory ProductoFavoritoModel.fromMap(Map<String, dynamic> map) {
    final producto = map['productos'] as Map<String, dynamic>;
    final negocio = producto['negocios'] as Map<String, dynamic>;
    return ProductoFavoritoModel(
      id: map['id'] as String,
      productoId: map['producto_id'] as String,
      productoNombre: producto['nombre'] as String,
      negocioId: map['negocio_id'] as String,
      negocioNombre: negocio['nombre'] as String,
      precio: (producto['precio'] as num).toDouble(),
      imageUrl: producto['imagen_url'] as String?,
      negocioAbierto: negocio['abierto'] as bool? ?? false,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  ProductoFavorito toEntity() => ProductoFavorito(
        id: id,
        productoId: productoId,
        productoNombre: productoNombre,
        negocioId: negocioId,
        negocioNombre: negocioNombre,
        precio: precio,
        imageUrl: imageUrl,
        negocioAbierto: negocioAbierto,
        createdAt: createdAt,
      );
}
