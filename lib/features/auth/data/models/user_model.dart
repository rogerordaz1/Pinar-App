import '../../domain/entities/user_entity.dart';

class UserModel {
  final String id;
  final String email;
  final String? nombre;
  final String? telefono;
  final String? avatarUrl;
  final bool esNegocio;

  const UserModel({
    required this.id,
    required this.email,
    this.nombre,
    this.telefono,
    this.avatarUrl,
    this.esNegocio = false,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as String,
      email: map['email'] as String,
      nombre: map['nombre'] as String?,
      telefono: map['telefono'] as String?,
      avatarUrl: map['avatar_url'] as String?,
      esNegocio: map['es_negocio'] as bool? ?? false,
    );
  }

  UserEntity toEntity() {
    return UserEntity(
      id: id,
      email: email,
      nombre: nombre,
      telefono: telefono,
      avatarUrl: avatarUrl,
      esNegocio: esNegocio,
    );
  }
}
