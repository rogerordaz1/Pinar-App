import 'package:equatable/equatable.dart';

class NegocioFavorito extends Equatable {
  final String id;
  final String negocioId;
  final String negocioNombre;
  final String? logoUrl;
  final bool negocioAbierto;
  final double calificacion;
  final bool negocioVerificado;
  final DateTime createdAt;

  const NegocioFavorito({
    required this.id,
    required this.negocioId,
    required this.negocioNombre,
    this.logoUrl,
    required this.negocioAbierto,
    required this.calificacion,
    required this.negocioVerificado,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id, negocioId, negocioNombre, logoUrl,
        negocioAbierto, calificacion, negocioVerificado, createdAt,
      ];
}
