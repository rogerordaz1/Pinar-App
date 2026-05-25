import 'package:equatable/equatable.dart';

class NegocioPreview extends Equatable {
  final String id;
  final String nombre;
  final String categoria;
  final double distanciaKm;
  final bool abierto;
  final String? logoUrl;
  final bool verificado;

  const NegocioPreview({
    required this.id,
    required this.nombre,
    required this.categoria,
    required this.distanciaKm,
    required this.abierto,
    this.logoUrl,
    this.verificado = false,
  });

  @override
  List<Object?> get props =>
      [id, nombre, categoria, distanciaKm, abierto, logoUrl, verificado];
}
