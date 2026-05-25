import 'package:equatable/equatable.dart';

class CategoriaNegocio extends Equatable {
  final String id;
  final String nombre;
  final String icono;

  const CategoriaNegocio({
    required this.id,
    required this.nombre,
    required this.icono,
  });

  @override
  List<Object> get props => [id, nombre, icono];
}
