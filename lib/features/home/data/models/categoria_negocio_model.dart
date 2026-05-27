import '../../domain/entities/categoria_negocio.dart';

class CategoriaNegocioModel {
  final String id;
  final String nombre;
  final String icono;

  const CategoriaNegocioModel({
    required this.id,
    required this.nombre,
    required this.icono,
  });

  factory CategoriaNegocioModel.fromMap(Map<String, dynamic> map) {
    return CategoriaNegocioModel(
      id: map['id'] as String,
      nombre: map['nombre'] as String,
      icono: map['icono'] as String,
    );
  }

  CategoriaNegocio toEntity() =>
      CategoriaNegocio(id: id, nombre: nombre, icono: icono);
}
