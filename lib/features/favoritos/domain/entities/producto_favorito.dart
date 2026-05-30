import 'package:equatable/equatable.dart';

class ProductoFavorito extends Equatable {
  final String id;
  final String productoId;
  final String productoNombre;
  final String negocioId;
  final String negocioNombre;
  final double precio;
  final String? imageUrl;
  final bool negocioAbierto;
  final DateTime createdAt;

  const ProductoFavorito({
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

  @override
  List<Object?> get props => [
        id, productoId, productoNombre, negocioId, negocioNombre,
        precio, imageUrl, negocioAbierto, createdAt,
      ];
}
