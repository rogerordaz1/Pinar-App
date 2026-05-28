import 'package:equatable/equatable.dart';

class ProductoNegocio extends Equatable {
  final String id;
  final String nombre;
  final double precio;
  final String unidad;
  final bool disponible;
  final String? imagenUrl;
  final String actualizadoHace;

  const ProductoNegocio({
    required this.id,
    required this.nombre,
    required this.precio,
    required this.unidad,
    required this.disponible,
    this.imagenUrl,
    required this.actualizadoHace,
  });

  @override
  List<Object?> get props =>
      [id, nombre, precio, unidad, disponible, imagenUrl, actualizadoHace];
}

class NegocioDetalle extends Equatable {
  final String id;
  final String nombre;
  final String categoria;
  final bool abierto;
  final double distanciaKm;
  final String? logoUrl;
  final String? heroImageUrl;
  final bool verificado;
  final double calificacion;
  final int totalResenas;
  final String direccion;
  final String? telefono;
  final String? whatsapp;
  final String? infoEntrega;
  final List<String> certificaciones;
  final List<ProductoNegocio> productos;

  const NegocioDetalle({
    required this.id,
    required this.nombre,
    required this.categoria,
    required this.abierto,
    required this.distanciaKm,
    this.logoUrl,
    this.heroImageUrl,
    this.verificado = false,
    required this.calificacion,
    required this.totalResenas,
    required this.direccion,
    this.telefono,
    this.whatsapp,
    this.infoEntrega,
    this.certificaciones = const [],
    this.productos = const [],
  });

  @override
  List<Object?> get props => [
        id,
        nombre,
        categoria,
        abierto,
        distanciaKm,
        logoUrl,
        heroImageUrl,
        verificado,
        calificacion,
        totalResenas,
        direccion,
        telefono,
        whatsapp,
        infoEntrega,
        certificaciones,
        productos,
      ];
}
