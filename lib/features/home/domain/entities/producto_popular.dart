import 'package:equatable/equatable.dart';

class ProductoPopular extends Equatable {
  final String id;
  final String nombre;
  final double precio;
  final String unidad;
  final String negocioNombre;
  final String negocioId;
  final bool disponible;

  const ProductoPopular({
    required this.id,
    required this.nombre,
    required this.precio,
    required this.unidad,
    required this.negocioNombre,
    required this.negocioId,
    this.disponible = true,
  });

  @override
  List<Object?> get props =>
      [id, nombre, precio, unidad, negocioNombre, negocioId, disponible];
}
