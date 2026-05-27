import 'package:equatable/equatable.dart';

class Promocion extends Equatable {
  final String id;
  final String titulo;
  final String nombreNegocio;
  final String negocioId;
  final String? imagenUrl;

  const Promocion({
    required this.id,
    required this.titulo,
    required this.nombreNegocio,
    required this.negocioId,
    this.imagenUrl,
  });

  @override
  List<Object?> get props => [id, titulo, nombreNegocio, negocioId, imagenUrl];
}
